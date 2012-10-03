module FluxxSubProgram
  SEARCH_ATTRIBUTES = [:created_at, :updated_at, :id, :program_id, :retired]
  LIQUID_METHODS = [:name]
  SUB_PROGRAM_FSA_JOIN_WHERE_CLAUSE = "(fsa.sub_program_id = ?
    or fsa.initiative_id in (select initiatives.id from initiatives where sub_program_id = ?)
    or fsa.sub_initiative_id in (select sub_initiatives.id from sub_initiatives, initiatives where initiative_id = initiatives.id and sub_program_id = ?)) and fsa.deleted_at is null"
  
  def self.included(base)
    base.belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by_id'
    base.belongs_to :updated_by, :class_name => 'User', :foreign_key => 'updated_by_id'
    base.belongs_to :program
    base.send :attr_accessor, :not_retired

    base.acts_as_audited({:full_model_enabled => false, :except => [:created_by_id, :updated_by_id, :delta, :updated_by, :created_by, :audits]})

    base.insta_search do |insta|
      insta.filter_fields = SEARCH_ATTRIBUTES
      insta.derived_filters = {}
    end
    base.liquid_methods *( LIQUID_METHODS )
    
    base.insta_export do |insta|
      insta.filename = 'sub_program'
      insta.headers = [['Date Created', :date], ['Date Updated', :date], 'Name', 'Spending Year', ['Amount Funded', :currency]]
      insta.sql_query = "sub_programs.created_at, sub_programs.updated_at, sub_programs.name, if(spending_year is null, 'none', spending_year), sum(amount)
                   from sub_programs
                   left outer join funding_source_allocations fsa on true
                    where
                   #{SUB_PROGRAM_FSA_JOIN_WHERE_CLAUSE.gsub /\?/, 'sub_programs.id'}
                      and sub_programs.id IN (?)
                      group by name, if(spending_year is null, 0, spending_year)
                  "
    end
    

    base.extend(ModelClassMethods)
    base.class_eval do
      include ModelInstanceMethods
    end
  end
  
  module ModelClassMethods
    def is_hidden?
      Fluxx.config(:hide_sub_program) == "1" && Fluxx.config(:funding_source_allocation_hide_sub_program) == "1"
    end

    def load_all
      SubProgram.where(:retired => 0).order(:name).all
    end
  end
  
  module ModelInstanceMethods
    def autocomplete_to_s
      !description || description.empty? ? name : description
    end

    def to_s
      autocomplete_to_s
    end

    def load_initiatives minimum_fields=true
      select_field_sql = if minimum_fields
        'description, name, id, sub_program_id'
      else
        'initiative.*'
      end
      Initiative.find :all, :select => select_field_sql, :conditions => ['sub_program_id = ? and retired = 0', id], :order => :name
    end
    
      
    def sub_program_fsa_join_where_clause
      SUB_PROGRAM_FSA_JOIN_WHERE_CLAUSE
    end
    
    def funding_source_allocations options={}
      spending_year_clause = options[:spending_year] ? " spending_year = #{options[:spending_year]} and " : ''
      retired_clause = options[:show_retired] ? " retired != 1 or retired is null " : ''

      FundingSourceAllocation.find_by_sql(FundingSourceAllocation.send(:sanitize_sql, ["select fsa.*,
        (select count(*) from funding_source_allocation_authorities where funding_source_allocation_id = fsa.id) num_allocation_authorities
        from funding_source_allocations fsa where 
        #{spending_year_clause}
        #{sub_program_fsa_join_where_clause}", 
          self.id, self.id, self.id])).select{|fsa| (fsa.num_allocation_authorities.to_i rescue 0) > 0}
    end
    
    def total_pipeline request_types=nil
      total_amount = FundingSourceAllocation.connection.execute(
          FundingSourceAllocation.send(:sanitize_sql, ["select sum(rfs.funding_amount) from funding_source_allocations fsa, request_funding_sources rfs, requests where 
          requests.granted = 0 and
          requests.deleted_at IS NULL AND requests.state <> 'rejected' and
      	rfs.request_id = requests.id 
      	#{Request.prepare_request_types_for_where_clause(request_types)}
      	and rfs.funding_source_allocation_id = fsa.id and
                #{sub_program_fsa_join_where_clause}",self.id, self.id, self.id]))
      total_amount.fetch_row.first.to_i
    end
    
    def total_allocation options={}
      spending_year_clause = options[:spending_year] ? " spending_year = #{options[:spending_year]} and " : ''
      total_amount = FundingSourceAllocation.connection.execute(
          FundingSourceAllocation.send(:sanitize_sql, ["select sum(amount) from funding_source_allocations fsa where 
            #{spending_year_clause}
            #{sub_program_fsa_join_where_clause}", 
            self.id, self.id, self.id]))
      total_amount.fetch_row.first.to_i
    end
  end
end