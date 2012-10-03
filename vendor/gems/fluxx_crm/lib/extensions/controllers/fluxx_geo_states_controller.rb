module FluxxGeoStatesController
  def self.included(base)
    base.insta_index GeoState do |insta|
      insta.template = 'geo_state_list'
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