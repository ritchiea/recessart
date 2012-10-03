module ThinkingSphinx
  class Index
    class Builder
      
      # NOTE ESH: example of how to extend a sphinx index.  Add this to the organization.rb class for example
      # def self.extra_index_organization_first index
      #   # index.has index.constituents(:id), :type => :multi, :as => :constituent_ids
      # end
      
      
      def initialize(index, &block)
        @index  = index
        @explicit_source = false
        
        self.instance_eval &block
        
        extra_block_name = "extra_index_#{@index.instance_variable_get "@name" rescue ''}"
        @index.model.send(extra_block_name, self) if @index && @index.model && @index.model.respond_to?(extra_block_name)
        
        if no_fields?
          raise "At least one field is necessary for an index, in #{@index.model.to_s}"
        end
      end
    end
  end
end
    
