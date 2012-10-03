module FluxxModelDocumentType
  SEARCH_ATTRIBUTES = [:model_type]

  def self.included(base)
    base.belongs_to :created_by, :class_name => 'User', :foreign_key => 'created_by_id'
    base.belongs_to :updated_by, :class_name => 'User', :foreign_key => 'updated_by_id'

    base.insta_search do |insta|
      insta.filter_fields = SEARCH_ATTRIBUTES
    end

    base.extend(ModelClassMethods)
    base.class_eval do
      include ModelInstanceMethods
    end
  end

  module ModelClassMethods
    def load_by_class klass, options={}
      klass = if klass.is_a? Class
        klass
      else
        klass.class
      end
      
      ModelDocumentType.where(:model_type => klass.name).all
    end
  end

  module ModelInstanceMethods
  end
end