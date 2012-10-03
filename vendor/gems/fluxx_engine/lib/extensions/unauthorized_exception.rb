class UnauthorizedException < Exception
  def initialize acl=nil, model_class=nil
    identifier = if model_class.is_a? Class
      model_class
    elsif String
      model_class
    elsif model_class
      "#{model_class.class.name} - #{model_class.id}"
    end
    super("Invalid access for #{acl} on #{identifier}")
  end
end