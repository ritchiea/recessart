module FluxxProgram
  SEARCH_ATTRIBUTES = [:created_at, :updated_at, :id, :retired]
  LIQUID_METHODS = [:name, :description]
  PROGRAM_FSA_JOIN_WHERE_CLAUSE = "(fsa.program_id = ?
  or fsa.sub_program_id in (select id from sub_programs where program_id = ?)
  or fsa.initiative_id in (select initiatives.id from initiatives, sub_programs where sub_program_id = sub_programs.id and sub_programs.program_id = ?)
  or fsa.sub_initiative_id in (select sub_initiatives.id from sub_initiatives, initiatives, sub_programs where initiative_id = initiatives.id and sub_program_id = sub_programs.id and sub_programs.program_id = ?)) and fsa.deleted_at is null"

  def self.included(base)
    base.acts_as_audited

    base.has_many :sub_programs
    base.validates_presence_of     :name
    base.validates_length_of       :name,    :within => 3..255

    base.belongs_to :parent_program, :class_name => 'Program', :foreign_key => :parent_id
    base.has_many :children_programs, :class_name => 'Program', :foreign_key => :parent_id
    base.send :attr_accessor, :not_retired
    
    base.insta_search do |insta|
      insta.filter_fields = SEARCH_ATTRIBUTES
      insta.derived_filters = {}
    end

    base.insta_export do |insta|
      insta.filename = 'program'
      insta.headers = [['Date Created', :date], ['Date Updated', :date], 'Name', 'Spending Year', ['Amount Funded', :currency]]
      insta.sql_query = "programs.created_at, programs.updated_at, programs.name, if(spending_year is null, 'none', spending_year), sum(amount)
                   from programs
                   left outer join funding_source_allocations fsa on true
                    where
                   #{PROGRAM_FSA_JOIN_WHERE_CLAUSE.gsub /\?/, 'programs.id'}
                      and programs.id IN (?)
                      group by name, if(spending_year is null, 0, spending_year)
                  "
    end
    
    base.insta_realtime
    base.insta_multi
    base.insta_template do |insta|
      insta.entity_name = 'program'
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
      Fluxx.config(:hide_program) == "1" && Fluxx.config(:funding_source_allocation_hide_program) == "1"
    end

    def finance_administrator_role_name
      'Finance Administrator'
    end

    def grants_administrator_role_name
      'Grants Administrator'
    end

    def grants_assistant_role_name
      'Grants Assistant'
    end

    def president_role_name
      'President'
    end

    def program_associate_role_name
      'Program Associate'
    end

    def program_director_role_name
      'Program Director'
    end

    def program_officer_role_name
      'Program Officer'
    end
    
    def deputy_director_role_name
      'Deputy Director'
    end

    def cr_role_name
      'CR'
    end

    def svp_role_name
      'SVP'
    end

    def grantee_role_name
      'Grantee'
    end

    def request_roles
      [president_role_name, program_associate_role_name, program_officer_role_name, program_director_role_name, cr_role_name, deputy_director_role_name, svp_role_name, grants_administrator_role_name, grants_assistant_role_name]
    end

    def grantee_roles
      [grantee_role_name]
    end

    def grant_roles
      [grants_administrator_role_name, grants_assistant_role_name]
    end

    def finance_roles
      [finance_administrator_role_name]
    end
    
    def all_program_users
      User.joins(:role_users => :role).where({:deleted_at => nil, :role_users => {:roles => {:roleable_type => self.name}}}).group("users.id").compact
    end

    def load_all_nonrollup
      load_all_without_children_programs
    end

    def load_all
      Program.where(:retired => 0).order(:name).all
    end
    
    def load_all_without_children_programs
      Program.where(:retired => 0).where('(select count(*) from programs subprog where subprog.parent_id = programs.id) = 0').order(:name).all
    end

    def program_roles
      Role.where(:roleable_type => Program.name).order(:name).all
    end
  end

  module ModelInstanceMethods
    
    def has_children_programs?
      Program.where(:parent_id => self.id).count > 0
    end
    
    def load_sub_programs minimum_fields=true
      select_field_sql = if minimum_fields
        'description, name, id, program_id'
      else
        'sub_programs.*'
      end
      SubProgram.find :all, :select => select_field_sql, :conditions => ['program_id = ? and retired = 0', id], :order => :name
    end

    def load_users role_name=nil
      children = self.children_programs
      programs = if children.empty?
        [self]
      else
        [self] + children
      end
      programs << self.parent_program if self.parent_program
      
      program_ids = programs.compact.flatten.map &:id
      
      user_query = User.joins(:role_users => :role).order('first_name asc, last_name asc').where({:test_user_flag => 0, :role_users => {:roleable_id => program_ids, :roles => {:roleable_type => self.class.name}}})
      user_query = user_query.where({:role_users => {:roles => {:name => role_name}}}) if role_name
      user_query.group("users.id").compact
    end
    
    def program_fsa_join_where_clause
      PROGRAM_FSA_JOIN_WHERE_CLAUSE
    end
    
    def funding_source_allocations options={}
      spending_year_clause = options[:spending_year] ? " spending_year = #{options[:spending_year]} and " : ''
      retired_clause = options[:show_retired] ? " retired != 1 or retired is null " : ''

      FundingSourceAllocation.find_by_sql(FundingSourceAllocation.send(:sanitize_sql, 
        ["select fsa.*, 
          (select count(*) from funding_source_allocation_authorities where funding_source_allocation_id = fsa.id) num_allocation_authorities
          from funding_source_allocations fsa where 
        #{spending_year_clause} #{program_fsa_join_where_clause}
          ", 
        self.id, self.id, self.id, self.id])).select{|fsa| (fsa.num_allocation_authorities.to_i rescue 0) > 0}
    end
    
    def total_pipeline request_types=nil
      total_amount = FundingSourceAllocation.connection.execute(
          FundingSourceAllocation.send(:sanitize_sql, ["select sum(rfs.funding_amount) from funding_source_allocations fsa, request_funding_sources rfs, requests where 
          requests.granted = 0 and
          requests.deleted_at IS NULL AND requests.state <> 'rejected' and
      	rfs.request_id = requests.id 
      	#{Request.prepare_request_types_for_where_clause(request_types)}
      	and rfs.funding_source_allocation_id = fsa.id and
                #{program_fsa_join_where_clause}",self.id, self.id, self.id, self.id]))
      total_amount.fetch_row.first.to_i
    end
    
    def total_allocation options={}
      spending_year_clause = options[:spending_year] ? " spending_year = #{options[:spending_year]} and " : ''
      total_amount = FundingSourceAllocation.connection.execute(
          FundingSourceAllocation.send(:sanitize_sql, ["select sum(amount) from funding_source_allocations fsa where 
            #{spending_year_clause}
            #{program_fsa_join_where_clause}", 
            self.id, self.id, self.id, self.id]))
      total_amount.fetch_row.first.to_i
    end
    
    def autocomplete_to_s
      description || name
    end

    def to_s
      autocomplete_to_s
    end
  end
end