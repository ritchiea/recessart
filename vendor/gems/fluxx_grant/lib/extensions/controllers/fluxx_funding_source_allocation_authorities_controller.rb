module FluxxFundingSourceAllocationAuthoritiesController
  ICON_STYLE = 'style-funding-source-allocation-authorities'
  def self.included(base)
    base.insta_index FundingSourceAllocationAuthority do |insta|
      insta.template = 'funding_source_allocation_authority_list'
      insta.filter_title = "FundingSourceAllocationAuthorities Filter"
      insta.filter_template = 'funding_source_allocation_authorities/funding_source_allocation_authority_filter'
      insta.order_clause = 'updated_at desc'
      insta.icon_style = ICON_STYLE
    end
    base.insta_show FundingSourceAllocationAuthority do |insta|
      insta.template = 'funding_source_allocation_authority_show'
      insta.icon_style = ICON_STYLE
      insta.add_workflow
    end
    base.insta_new FundingSourceAllocationAuthority do |insta|
      insta.template = 'funding_source_allocation_authority_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_edit FundingSourceAllocationAuthority do |insta|
      insta.template = 'funding_source_allocation_authority_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_post FundingSourceAllocationAuthority do |insta|
      insta.template = 'funding_source_allocation_authority_form'
      insta.icon_style = ICON_STYLE
      
      insta.post do |triple|
        controller_dsl, model, outcome = triple
        # There are many funding source allocation authorities connected to a funding source allocation.  This allows us to roll up the amount at the funding source allocation
        # level, and track the authority at the funding_source_allocation_authority.  As such, we are creating the funding_source_allocation_authority, but it has to be linked back to a
        # funding_source_allocation which may or may not exist.  That's what this handles
        if params[:funding_source_allocation_authority]
          fsa = FundingSourceAllocation.where(derive_fsa_params).where(:deleted_at => nil).first || FundingSourceAllocation.create(derive_fsa_params)
          model.funding_source_allocation = fsa
          model.funding_source_allocation_id = fsa.id if fsa
          model.save
        end
      end
      
    end
    base.insta_put FundingSourceAllocationAuthority do |insta|
      insta.template = 'funding_source_allocation_authority_form'
      insta.icon_style = ICON_STYLE
      insta.add_workflow
      insta.pre do |controller_dsl|
        # This is an interesting one; we want to apply the changed attributes to the fsa currently associated with the fsaa.
        # Note that this could have consequences for other fsaa's that are also linked to that fsa
        # For example if you have:
        #  $20,000 - 2011 - Core Contributers - Nov 2010
        #  $40,000 - 2011 - Core Contributers - Feb 2011
        #
        # If you click retired it will mark both of the above as retired essentially because
        # we track allocations not allocation authorities
        self.pre_model = controller_dsl.load_existing_model params
        self.pre_model.funding_source_allocation.update_attributes(:retired => params[:funding_source_allocation_authority][:retired]) if self.pre_model && self.pre_model.funding_source_allocation
      end
    end
    base.insta_delete FundingSourceAllocationAuthority do |insta|
      insta.template = 'funding_source_allocation_authority_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_related FundingSourceAllocationAuthority do |insta|
      insta.add_related do |related|
      end
    end
    
    base.extend(ModelClassMethods)
    base.class_eval do
      include ModelInstanceMethods
    end
  end

  module ModelClassMethods
  end

  module ModelInstanceMethods
    def derive_fsa_params
      fsa_params = {:funding_source_id => params[:funding_source_allocation_authority][:funding_source_id]}
      fsa_params[:program_id] = params[:funding_source_allocation_authority][:program_id] unless (params[:funding_source_allocation_authority][:program_id]).blank?
      fsa_params[:sub_program_id] = params[:funding_source_allocation_authority][:sub_program_id] unless (params[:funding_source_allocation_authority][:sub_program_id]).blank?
      fsa_params[:initiative_id] = params[:funding_source_allocation_authority][:initiative_id] unless (params[:funding_source_allocation_authority][:initiative_id]).blank?
      fsa_params[:sub_initiative_id] = params[:funding_source_allocation_authority][:sub_initiative_id] unless (params[:funding_source_allocation_authority][:sub_initiative_id]).blank?
      fsa_params[:spending_year] = params[:funding_source_allocation_authority][:spending_year] unless (params[:funding_source_allocation_authority][:spending_year]).blank?
      fsa_params[:retired] = params[:funding_source_allocation_authority][:retired] unless (params[:funding_source_allocation_authority][:retired]).blank?
      fsa_params
    end
  end
end
