module FluxxInitiative
  SEARCH_ATTRIBUTES = [[:program_id, 'sub_programs'], :sub_program_id, :retired]
  LIQUID_METHODS = [:name]
  INITIATIVE_FSA_JOIN_WHERE_CLAUSE = "(fsa.initiative_id = ?
    or fsa.sub_initiative_id in (select sub_initiatives.id from sub_initiatives where initiative_id = ?)) and fsa.deleted_at is null"
    
  def self.included(base)
    base.belongs_to :sub_program
    base.acts_as_audited

    base.validates_presence_of     :sub_program
    base.validates_presence_of     :name
    base.validates_length_of       :name,    :within => 3..255
    base.send :attr_accessor, :not_retired
    
    base.insta_search do |insta|
      insta.filter_fields = SEARCH_ATTRIBUTES
    end
    base.insta_export do |insta|
      insta.filename = 'initiative'
      insta.headers = [['Date Created', :date], ['Date Updated', :date], 'Name', 'Spending Year', ['Amount Funded', :currency]]
      insta.sql_query = "initiatives.created_at, initiatives.updated_at, initiatives.name, if(spending_year is null, 'none', spending_year), sum(amount)
                   from initiatives
                   left outer join funding_source_allocations fsa on true
                    where
                   #{INITIATIVE_FSA_JOIN_WHERE_CLAUSE.gsub /\?/, 'initiatives.id'}
                      and initiatives.id IN (?)
                      group by name, if(spending_year is null, 0, spending_year)
                  "
    end
    base.insta_realtime
    base.insta_template do |insta|
      insta.entity_name = 'initiative'
      insta.add_methods []
      insta.remove_methods [:id]
    end
    base.liquid_methods *( LIQUID_METHODS )
    
    base.extend(ModelClassMethods)
    base.class_eval do
      include ModelInstanceMethods
    end
  end

  module ModelClassMethods
    def is_hidden?
      Fluxx.config(:hide_initiative) == "1" && Fluxx.config(:funding_source_allocation_hide_initiative) == "1"
    end

    def load_all
      Initiative.where(:retired => 0).order(:name).all
    end
  end

  module ModelInstanceMethods
    def autocomplete_to_s
      description || name
    end

    def to_s
      autocomplete_to_s
    end
    
    def load_sub_initiatives minimum_fields=true
      select_field_sql = if minimum_fields
        'description, name, id, initiative_id'
      else
        'sub_initiatives.*'
      end
      SubInitiative.find :all, :select => select_field_sql, :conditions => ['initiative_id = ? and retired = 0', id], :order => :name
    end
    
    def program_id= program_id
      # no-op to make the form happy ;)
    end
    
    def program_id
      program.id if program
    end
    
    def program
      sub_program.program if sub_program
    end

      
    def initiative_fsa_join_where_clause
      INITIATIVE_FSA_JOIN_WHERE_CLAUSE
    end
   
    def funding_source_allocations options={}
      spending_year_clause = options[:spending_year] ? " spending_year = #{options[:spending_year]} and " : ''
      retired_clause = options[:show_retired] ? " retired != 1 or retired is null " : ''

      FundingSourceAllocation.find_by_sql(FundingSourceAllocation.send(:sanitize_sql, ["select fsa.*,
        (select count(*) from funding_source_allocation_authorities where funding_source_allocation_id = fsa.id) num_allocation_authorities
        from funding_source_allocations fsa where 
        #{spending_year_clause}
        #{initiative_fsa_join_where_clause}",
          self.id, self.id])).select{|fsa| (fsa.num_allocation_authorities.to_i rescue 0) > 0}
    end
    
    def total_pipeline request_types=nil
      total_amount = FundingSourceAllocation.connection.execute(
          FundingSourceAllocation.send(:sanitize_sql, ["select sum(rfs.funding_amount) from funding_source_allocations fsa, request_funding_sources rfs, requests where 
          requests.granted = 0 and
          requests.deleted_at IS NULL AND requests.state <> 'rejected' and
      	rfs.request_id = requests.id 
      	#{Request.prepare_request_types_for_where_clause(request_types)}
      	and rfs.funding_source_allocation_id = fsa.id and
                #{initiative_fsa_join_where_clause}",self.id, self.id]))
      total_amount.fetch_row.first.to_i
    end

    def total_allocation options={}
      spending_year_clause = options[:spending_year] ? " spending_year = #{options[:spending_year]} and " : ''
      total_amount = FundingSourceAllocation.connection.execute(
          FundingSourceAllocation.send(:sanitize_sql, ["select sum(amount) from funding_source_allocations fsa where 
            #{spending_year_clause}
            #{initiative_fsa_join_where_clause}", 
            self.id, self.id]))
      total_amount.fetch_row.first.to_i
    end
  end
end