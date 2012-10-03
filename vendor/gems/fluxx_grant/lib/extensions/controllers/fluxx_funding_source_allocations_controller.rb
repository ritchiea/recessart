module FluxxFundingSourceAllocationsController
  ICON_STYLE = 'style-funding-source-allocations'
  def self.included(base)
    base.insta_index FundingSourceAllocation do |insta|
      insta.template = 'funding_source_allocation_list'
      insta.order_clause = 'updated_at desc'
      insta.results_per_page = 500
      insta.include_relation = :funding_source
      insta.order_clause = 'funding_sources.name asc'
      insta.icon_style = ICON_STYLE
      insta.suppress_model_iteration = true
      
      insta.pre do |controller_dsl|
        prog_entity = if !params[:sub_initiative_id].blank? && Fluxx.config(:no_funding_source_ripple_sub_initiative) != "1"
          SubInitiative.find params[:sub_initiative_id]
        elsif !params[:initiative_id].blank? && Fluxx.config(:no_funding_source_ripple_initiative) != "1"
          Initiative.find params[:initiative_id]
        elsif !params[:sub_program_id].blank? && Fluxx.config(:no_funding_source_ripple_sub_program) != "1"
          SubProgram.find params[:sub_program_id]
        elsif !params[:program_id].blank?
          Program.find params[:program_id]
        elsif !params[:funding_source_id].blank?
          FundingSource.find params[:funding_source_id]
        end
        self.pre_models = if prog_entity
          if params[:spending_year].blank?
            []
          elsif prog_entity.is_a?(FundingSource)
            prog_entity.load_funding_source_allocations(:spending_year => params[:spending_year])
          else
            prog_entity.funding_source_allocations(:spending_year => params[:spending_year], :deleted_at => nil)
          end
        else
          []
        end
        
      end
      
      insta.format do |format|
        format.autocomplete do |triple|
          controller_dsl, outcome, default_block = triple
          funding_amount_string = params[:funding_amount]
          funding_amount_string = funding_amount_string.to_s.gsub(/[^\d.]+/, '') if funding_amount_string
          request_amount = if funding_amount_string && funding_amount_string.to_i > 0
            funding_amount_string.to_i
          end
          out_text = @models.map do |model|
              controller_url = url_for(model)
              {:label => model.funding_source_title(request_amount), :value => model.id, :url => controller_url} if model.amount_remaining && request_amount && model.amount_remaining >= request_amount
            end.compact.to_json
          render :text => out_text, :layout => false
        end
      end
    end
    base.insta_show FundingSourceAllocation do |insta|
      insta.template = 'funding_source_allocation_show'
      insta.icon_style = ICON_STYLE
      insta.add_workflow
    end
    base.insta_new FundingSourceAllocation do |insta|
      insta.template = 'funding_source_allocation_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_edit FundingSourceAllocation do |insta|
      insta.template = 'funding_source_allocation_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_post FundingSourceAllocation do |insta|
      insta.template = 'funding_source_allocation_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_put FundingSourceAllocation do |insta|
      insta.template = 'funding_source_allocation_form'
      insta.icon_style = ICON_STYLE
      insta.add_workflow
    end
    base.insta_delete FundingSourceAllocation do |insta|
      insta.template = 'funding_source_allocation_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_related FundingSourceAllocation do |insta|
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
  end
end