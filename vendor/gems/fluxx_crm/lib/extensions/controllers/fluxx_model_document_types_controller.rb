module FluxxModelDocumentTypesController
  def self.included(base)
    base.insta_index ModelDocumentType do |insta|
      insta.template = 'model_document_list'
      insta.results_per_page = 5000
      insta.order_clause = 'name asc'
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