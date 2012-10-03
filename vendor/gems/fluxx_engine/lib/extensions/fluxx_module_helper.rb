module FluxxModuleHelper
  def included(base)
    base.extend(@class_methods_module) if @class_methods_module
    base.send(:include, @instance_methods_module) if @instance_methods_module
    base.instance_eval(&@included_block) if @included_block
  end

  def when_included(&block)
    @included_block = block
  end

  def class_methods(&block)
    @class_methods_module = Module.new{ module_eval(&block) }
  end

  def instance_methods(&block)
    @instance_methods_module = Module.new{ module_eval(&block) }
  end
end
