module FluxxGeoCitiesController
  def self.included(base)
    base.insta_index GeoCity do |insta|
      insta.template = 'geo_city_list'
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