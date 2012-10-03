module FluxxGeoCity
  def self.included(base)
    base.belongs_to :geo_state
    base.belongs_to :geo_country
    base.acts_as_audited

    base.validates_presence_of :geo_state
    base.validates_presence_of :geo_country
    
    base.insta_search
    base.insta_export

    base.extend(ModelClassMethods)
    base.class_eval do
      include ModelInstanceMethods
    end
  end

  module ModelClassMethods
  end

  module ModelInstanceMethods
    def to_s
      name
    end
  end
end