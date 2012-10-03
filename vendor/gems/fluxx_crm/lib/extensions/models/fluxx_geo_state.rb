module FluxxGeoState
  LIQUID_METHODS = [:name]  
  
  def self.included(base)
    base.belongs_to :geo_country
    base.has_many :geo_cities
    base.acts_as_audited

    base.validates_presence_of :geo_country

    base.insta_search do |insta|
      insta.filter_fields = [:geo_country_id]
    end
    base.insta_export

    base.insta_template do |insta|
      insta.entity_name = 'geo_state'
      insta.add_methods []
      insta.remove_methods [:id]
    end
    base.liquid_methods *( LIQUID_METHODS )  

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