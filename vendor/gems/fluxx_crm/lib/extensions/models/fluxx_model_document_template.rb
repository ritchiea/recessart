module FluxxModelDocumentTemplate
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
    def for_type_and_category(model_type, category=nil)
      clause = where(:model_type => model_type)
      clause = clause.where(:category => category) if category
      clause
    end
    
    def adhoc_for_type_and_category(model_type, category=nil)
      for_type_and_category(model_type, category).where(:display_in_adhoc_list => true)
    end
    
    # STOP! use only for dev purposes
    def reload_all_templated_model_documents
      ModelDocumentTemplate.reload_all_doc_templates

      ModelDocumentTemplate.connection.execute 'update model_documents, model_document_templates set model_documents.document_text = model_document_templates.document where model_documents.model_document_template_id = model_document_templates.id'
    end
    
    def reload_all_doc_templates
      ModelDocumentTemplate.all.each do |doc_template|
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