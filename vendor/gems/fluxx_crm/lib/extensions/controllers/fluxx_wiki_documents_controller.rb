module FluxxWikiDocumentsController
  ICON_STYLE = 'style-wiki'
  def self.included(base)
    base.insta_index WikiDocument do |insta|
      insta.template = 'wiki_document_list'
      insta.suppress_model_iteration = true
      insta.icon_style = ICON_STYLE
    end
    base.insta_show WikiDocument do |insta|
      insta.template = 'wiki_document_show'
      insta.icon_style = ICON_STYLE
    end
    base.insta_post WikiDocument do |insta|
      insta.template = 'wiki_document_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_delete WikiDocument do |insta|
      insta.template = 'wiki_document_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_new WikiDocument do |insta|
      insta.template = 'wiki_document_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_edit WikiDocument do |insta|
      insta.template = 'wiki_document_form'
      insta.icon_style = ICON_STYLE
    end
    base.insta_put WikiDocument do |insta|
      insta.template = 'wiki_document_form'
      insta.icon_style = ICON_STYLE
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