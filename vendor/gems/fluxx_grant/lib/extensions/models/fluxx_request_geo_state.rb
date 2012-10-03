module FluxxRequestGeoState
  def self.included(base)
    base.belongs_to :request
    base.belongs_to :geo_state
    
    base.insta_search
    base.insta_export
    base.insta_realtime

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