class FluxxGrantPopulateOriginalRequestAmendments < ActiveRecord::Migration
  def self.normalize_attributes(attrs)
    return {} if attrs.is_a?(String)

    attrs["start_date"] ||= attrs["grant_begins_at"]
    attrs["end_date"]   ||= attrs["grant_closed_at"]
    attrs["duration"]   ||= attrs["duration_in_months"]
    
    attrs.reject { |k,v| v.nil? or not %w[end_date duration amount_recommended].include?(k.to_s) }
  end

  def self.up
    RequestAmendment.delete_all
    Request.connection.execute "drop temporary table if exists amendsss"
    
    # Get the id of the first audit record for each request where the state switched to granted; every change after that will be potentially considered an amendment
    Request.connection.execute "create temporary table amendsss select * from audits where auditable_type = 'Request' and audit_changes like '%- granted%' and audit_changes like '%state: %' group by auditable_id order by id"
    Request.connection.execute "create index amendsss_auditable_id on amendsss(auditable_id)"
    
    
    Request.where(:granted => 1).each do |request|
      # Note: we cannot count on audits to be in numerically ascending order by id; use created_at instead
      request.audits.where('audits.created_at > (select created_at from amendsss where amendsss.auditable_id = audits.auditable_id)').order('created_at asc, id asc').each do |audit|
        changes = audit.audit_changes
        changes = normalize_attributes(changes)
        first_changes = audit.audit_changes
        first_changes = normalize_attributes(first_changes)
        first_changes.each { |k,v| first_changes[k] = v.first if v && v.is_a?(Array) }
        changes.each { |k,v| changes[k] = v.last if v && v.is_a?(Array) }
        
        unless changes.empty?
          if request.request_amendments.empty?
            # Need to insert the original amendment record.  This should be the first instance of each end_date, duration, amount_recommended in the history descending from the first granted state
            
            original_amendment = request.request_amendments.build(first_changes.merge(:original => 1, :created_at => audit.created_at, :updated_at => audit.created_at))
            original_amendment.save
          end
          amendment = request.request_amendments.build(changes.merge(:original => 0, :created_at => audit.created_at, :updated_at => audit.created_at))
          amendment.save
        end
      end
    end
  end

  def self.down
    RequestAmendment.delete_all
  end
end
