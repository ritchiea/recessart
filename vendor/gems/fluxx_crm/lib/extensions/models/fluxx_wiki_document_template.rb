module FluxxWikiDocumentTemplate
  SEARCH_ATTRIBUTES = [:model_type]

  def self.included(base)
    base.belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by_id'
    base.belongs_to :updated_by, :class_name => 'User', :foreign_key => 'updated_by_id'
    base.acts_as_audited({:full_model_enabled => false, :except => [:created_by_id, :updated_by_id, :delta, :updated_by, :created_by, :audits]})

    base.validates_presence_of :model_type
    
    base.insta_search do |insta|
      insta.filter_fields = SEARCH_ATTRIBUTES
    end
    base.insta_export
    base.insta_realtime
    base.insta_lock
    
    base.extend(ModelClassMethods)
    base.class_eval do
      include ModelInstanceMethods
    end
  end

  module ModelClassMethods
    # STOP! use only for dev purposes
    def reload_all_templated_wiki_documents
      WikiDocumentTemplate.reload_all_doc_templates

      WikiDocumentTemplate.connection.execute 'update wiki_documents, wiki_document_templates set wiki_documents.note = wiki_document_templates.document where wiki_documents.wiki_document_template_id = wiki_document_templates.id'
    end
    
    def reload_all_doc_templates
      WikiDocumentTemplate.all.each do |doc_template|
        possible_files = ActionController::Base.view_paths.map {|v| "#{v.instance_variable_get '@path'}/doc_templates/#{doc_template.filename}"}
        filename = possible_files.map{|file_name| file_name if File.exist?(file_name) }.compact.first
        if filename
          p "Loading file #{filename}"
          doc_contents = File.open(filename, 'r').read_whole_file
          doc_template.update_attribute :document, doc_contents
        end
      end
    end
  end

  module ModelInstanceMethods
    def to_s
      description
    end
  end
end