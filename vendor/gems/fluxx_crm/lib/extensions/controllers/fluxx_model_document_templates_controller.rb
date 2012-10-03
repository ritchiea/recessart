module FluxxModelDocumentTemplatesController
  def self.included(base)
    base.insta_index ModelDocumentTemplate do |insta|
      insta.template = 'model_document_template_list'
    end
    base.insta_show ModelDocumentTemplate do |insta|
      insta.template = 'model_document_template_show'
    end
    base.insta_new ModelDocumentTemplate do |insta|
      insta.template = 'model_document_template_form'
    end
    base.insta_edit ModelDocumentTemplate do |insta|
      insta.template = 'model_document_template_form'
    end
    base.insta_post ModelDocumentTemplate do |insta|
      insta.template = 'model_document_template_form'
    end
    base.insta_put ModelDocumentTemplate do |insta|
      insta.template = 'model_document_template_form'
    end
    base.insta_delete ModelDocumentTemplate do |insta|
      insta.template = 'model_document_template_form'
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