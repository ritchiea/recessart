module FluxxGeoCountriesController
  def self.included(base)
    base.insta_index GeoCountry do |insta|
      insta.template = 'geo_country_list'
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