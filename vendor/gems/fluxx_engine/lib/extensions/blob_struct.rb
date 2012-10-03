# interface to a Hash using method_missing
# to make a more convenient DSL in some places
class BlobStruct
  def initialize params={}
    @store = HashWithIndifferentAccess.new params
  end
  
  def store
    @store
  end
  
  def id
    if @store[:id]
      @store[:id]
    else
      super.id
    end
  end
  
  def class
    if @store[:class]
      @store[:class]
    else
      super.class
    end
  end
  
  def method_missing(method, *args, &block)
    if method.to_s =~ /=$/
      if args.length == 1
        @store[method.to_s.gsub(/=$/, '')] = args.first 
      elsif block
        @store[method.to_s.gsub(/=$/, '')] = block
      end
    elsif block
      @store[method.to_s] = block
    else
      @store[method.to_s]
    end
  end
  
end