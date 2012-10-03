module FluxxCrmTestHelper
  def self.included(base)
    base.send :include, ::FluxxEngineTestHelper
    base.extend(ModelClassMethods)
    base.class_eval do
      include ModelInstanceMethods
    end
  end

  module ModelClassMethods
  end

  module ModelInstanceMethods
    def check_models_are_updated
      assert_difference('WorkflowEvent.count') do
        yield
      end
    end

    def check_models_are_not_updated
      assert_difference('WorkflowEvent.count', 0) do
        yield
      end
    end
    
  end
end