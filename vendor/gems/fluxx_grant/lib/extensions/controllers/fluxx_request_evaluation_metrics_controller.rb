module FluxxRequestEvaluationMetricsController
  def self.included(base)
    base.insta_index RequestEvaluationMetric do |insta|
      insta.template = 'request_evaluation_metrics_list'
    end
    base.insta_show RequestEvaluationMetric do |insta|
      insta.template = 'request_evaluation_metrics_show'
    end
    base.insta_new RequestEvaluationMetric do |insta|
      insta.template = 'request_evaluation_metrics_form'
    end
    base.insta_edit RequestEvaluationMetric do |insta|
      insta.template = 'request_evaluation_metrics_form'
    end
    base.insta_post RequestEvaluationMetric do |insta|
      insta.template = 'request_evaluation_metrics_form'
    end
    base.insta_put RequestEvaluationMetric do |insta|
      insta.template = 'request_evaluation_metrics_form'
    end
    base.insta_delete RequestEvaluationMetric do |insta|
      insta.template = 'request_evaluation_metrics_form'
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