module FluxxGrantWorkflowEvent
  def self.included(base)
    base.send :include, ::FluxxWorkflowEvent
    base.extend(ModelClassMethods)
    base.class_eval do
      include ModelInstanceMethods
    end
  end
  
  module ModelClassMethods
    #
    # Here is a way to calculate the time spent in each step of the workflow
    #
    def workflow_funnel request_ids, funnel_allowed_states, funnel_not_allowed_old_states, sent_back_state_mapping_to_workflow, return_swe_diff_export=false
      WorkflowEvent.connection.execute "drop temporary table if exists swe"

      WorkflowEvent.connection.execute WorkflowEvent.send(:sanitize_sql, ["create temporary table swe select we.workflowable_id, we.workflowable_type, created_at, new_state, 
      if(old_state = 'new', (select request_received_at from requests where id = workflowable_id),
      (select created_at from workflow_events twe where twe.workflowable_id = we.workflowable_id and twe.workflowable_type = we.workflowable_type and twe.id < we.id order by twe.id desc limit 1)) old_created_at, 
      old_state from workflow_events we where we.workflowable_type in ('GrantRequest', 'FipRequest') and workflowable_id in (?) and new_state in (?) ", 
        request_ids, (funnel_allowed_states.map{|stsym| stsym.to_s})])

      WorkflowEvent.connection.execute "drop temporary table if exists swediff"
      WorkflowEvent.connection.execute "create temporary table swediff select *, time_to_sec(TIMEDIFF(created_at, old_created_at)) time_lag from swe where old_created_at is not null"

      swe_diffs = if return_swe_diff_export
        results = WorkflowEvent.connection.execute "select workflowable_type, old_created_at, old_state, created_at, new_state, (time_lag/86400) days, (select base_request_id from requests where requests.id = workflowable_id) request_id from swediff"
        swediffs = (1..results.num_rows).map do
         results.fetch_row
        end
        swediffs.map do |swediff|
          workflowable_type, old_created_at, old_state, new_created_at, new_state, days, request_id = swediff
          {:workflowable_type => workflowable_type, :old_created_at => old_created_at, :old_state => old_state, 
            :new_created_at => new_created_at, :new_state => new_state, :days => days, :request_id => request_id}
        end
      end

      # Now rename the states that are sent_back states to their sister state (:sent_back_to_po => :pending_po_approval, etc.)
      sent_back_state_mapping_to_workflow.keys.map do |sent_back_state| 
        workflow_state = sent_back_state_mapping_to_workflow[sent_back_state]
        WorkflowEvent.connection.execute WorkflowEvent.send(:sanitize_sql, ["UPDATE swediff SET old_state = ? WHERE old_state = ?",workflow_state.to_s, sent_back_state.to_s]) 
        WorkflowEvent.connection.execute WorkflowEvent.send(:sanitize_sql, ["UPDATE swediff SET new_state = ? WHERE new_state = ?",workflow_state.to_s, sent_back_state.to_s]) 
      end

      WorkflowEvent.connection.execute "drop temporary table if exists swediff_visits"
      WorkflowEvent.connection.execute WorkflowEvent.send(:sanitize_sql, ["create temporary table swediff_visits select old_state, count(*) num_visits, workflowable_id, sum(time_lag) time_lag 
          from swediff
          where old_state not in (?)
          group by old_state, workflowable_id", (funnel_not_allowed_old_states.map{|stsym| stsym.to_s})])

      results = WorkflowEvent.connection.execute "select avg(time_lag) avg_time_lag, avg(num_visits) avg_num_visits_per_request, count(*) total_visits, 
          count(distinct(workflowable_id)) total_workflowable_ids, old_state 
          from swediff_visits group by old_state"
      workflows = (1..results.num_rows).map do
       results.fetch_row
      end
      workflow_results = workflows.inject({}) do |acc, workflow|
        avg_time_lag, avg_num_visits_per_request, total_visits, total_workflowable_ids, old_state = workflow
        acc[old_state] = {:avg_time_lag => (avg_time_lag ? avg_time_lag.to_i : 0), 
           :avg_num_visits_per_request => (avg_num_visits_per_request ? avg_num_visits_per_request.to_i : 0), 
           :total_visits => (total_visits ? total_visits.to_i : 0), :total_workflowable_ids => (total_workflowable_ids ? total_workflowable_ids.to_i : 0), 
           :old_state => old_state}
        acc
      end

      total_workflowables = WorkflowEvent.connection.execute("select count(distinct(workflowable_id)) grant_count from swe").fetch_row.first
      avg_total_time_per_workflowable = WorkflowEvent.connection.execute("select avg(time_lag_total) 
          from (select sum(time_lag) time_lag_total, workflowable_id from swediff group by workflowable_id) avg_timelag_by_workflowable_id").fetch_row.first
      avg_time_per_step = WorkflowEvent.connection.execute("select avg(time_lag) avg_step from swediff").fetch_row.first

      {:workflow_results => workflow_results, :total_workflowables => (total_workflowables.blank? ? 0 : total_workflowables.to_i),
        :avg_total_time_per_workflowable => avg_total_time_per_workflowable, :avg_time_per_step => avg_time_per_step, :swe_diffs => swe_diffs}
    end
  end
  
  module ModelInstanceMethods
  end
end