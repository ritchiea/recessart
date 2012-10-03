module FluxxModelDocument
  SEARCH_ATTRIBUTES = [:documentable_id, :documentable_type]

  def self.included(base)
    base.belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by_id'
    base.belongs_to :updated_by, :class_name => 'User', :foreign_key => 'updated_by_id'
    base.belongs_to :documentable, :polymorphic => true
    base.belongs_to :model_document_type
    base.send :attr_accessor, :model_document_actual_filename
    

    if defined?(USE_MODEL_DOCUMENT_S3) && USE_MODEL_DOCUMENT_S3
      base.has_attached_file :document,
         :storage => :s3,
         :s3_credentials => "#{Rails.root}/config/amazon_s3.yml",
         :path => "/documents/:id/:filename"
    else
      base.has_attached_file :document
    end
    base.before_post_process :transliterate_file_name
    
    base.insta_search do |insta|
      insta.filter_fields = SEARCH_ATTRIBUTES
    end

    base.validates_presence_of :documentable
    base.validates_attachment_presence :document
    
    base.extend(ModelClassMethods)
    base.class_eval do
      include ModelInstanceMethods
    end
  end

  module ModelClassMethods
    # ESH: hack to rename ModelDocument to Document
    def model_name
      u = ActiveModel::Name.new ModelDocument
      u.instance_variable_set '@human', 'Document'
      u
    end
  end

  module ModelInstanceMethods
    def is_file?
      self.document_type == 'file'
    end
    
    def is_text?
      self.document_type == 'text'
    end
    
    def transliterate_file_name
      self.document.instance_write(:file_name, CGI::unescape(model_document_actual_filename)) if model_document_actual_filename
    end

    def relates_to_user? user
      (self.documentable.class.name == 'RequestReport') ?
        (user.primary_organization.id == self.documentable.request.program_organization_id) || (user.primary_organization.id == self.documentable.request.fiscal_organization_id) : false
    end
  end
end
