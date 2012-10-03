module FluxxWikiDocumentTemplatesController
  def self.included(base)
    base.insta_index WikiDocumentTemplate do |insta|
      insta.template = 'wiki_document_template_list'
    end
    base.insta_show WikiDocumentTemplate do |insta|
      insta.template = 'wiki_document_template_show'
    end
    base.insta_new WikiDocumentTemplate do |insta|
      insta.template = 'wiki_document_template_form'
    end
    base.insta_edit WikiDocumentTemplate do |insta|
      insta.template = 'wiki_document_template_form'
    end
    base.insta_post WikiDocumentTemplate do |insta|
      insta.template = 'wiki_document_template_form'
    end
    base.insta_put WikiDocumentTemplate do |insta|
      insta.template = 'wiki_document_template_form'
    end
    base.insta_delete WikiDocumentTemplate do |insta|
      insta.template = 'wiki_document_template_form'
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