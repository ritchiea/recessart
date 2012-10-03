module FluxxFundingSourceAllocationAuthority
  SEARCH_ATTRIBUTES = [:created_at, :updated_at, :id]
  
  def self.included(base)
    base.acts_as_audited({:full_model_enabled => false, :except => [:created_by_id, :updated_by_id, :delta, :updated_by, :created_by, :audits]})

    base.belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by_id'
    base.belongs_to :updated_by, :class_name => 'User', :foreign_key => 'updated_by_id'
    base.belongs_to :funding_source_allocation
    base.after_save :recalculate_allocation_amount
    base.after_destroy :recalculate_allocation_amount
    base.send :attr_accessor, :program_id
    base.send :attr_accessor, :sub_program_id
    base.send :attr_accessor, :initiative_id
    base.send :attr_accessor, :sub_initiative_id
    base.send :attr_accessor, :spending_year
    base.send :attr_accessor, :retired
    base.send :attr_accessor, :funding_source
    base.send :attr_accessor, :funding_source_id
    base.insta_multi

    base.insta_search do |insta|
      insta.filter_fields = SEARCH_ATTRIBUTES
      insta.derived_filters = {}
    end

    base.insta_template do |insta|
    end

    base.extend(ModelClassMethods)
    base.class_eval do
      include ModelInstanceMethods
    end
  end

  module ModelClassMethods
  end
  
  module ModelInstanceMethods
    def recalculate_allocation_amount
      funding_source_allocation.recalculate_amount if funding_source_allocation
    end
  end
end