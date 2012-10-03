module FluxxGrantModelDocumentTypesController
  def self.included(base)
    base.send :include, FluxxModelDocumentTypesController
    base.insta_index ModelDocumentType do |insta|
      insta.pre do |controller_dsl|
        # Note if we are not loading up a request don't bother to preload, let the usual loader do its work
        if params[:model_id] && params[:model_type]
          klass = Kernel.const_get params[:model_type] rescue nil
          if klass && klass.extract_classes(klass).any?{|cur_klass| cur_klass == Request} && (request_model = klass.find(params[:model_id]))
            self.pre_models = ModelDocumentType.load_by_class(klass, :program_id => request_model.program_id, :sub_program_id => request_model.sub_program_id, 
              :initiative_id => request_model.initiative_id, :sub_initiative_id => request_model.sub_initiative_id)
          end
        end
          
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