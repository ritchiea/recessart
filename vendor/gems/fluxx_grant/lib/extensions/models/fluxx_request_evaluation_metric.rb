module FluxxRequestEvaluationMetric
  SEARCH_ATTRIBUTES = [:request_id]
  LIQUID_METHODS = [:description, :comment]

  def self.included(base)
    base.belongs_to :request
    base.validates_presence_of :description
    
    base.insta_search do |insta|
      insta.filter_fields = SEARCH_ATTRIBUTES
    end
    base.insta_export
    base.insta_multi
    base.insta_lock
    base.insta_realtime
    base.liquid_methods *( LIQUID_METHODS )

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