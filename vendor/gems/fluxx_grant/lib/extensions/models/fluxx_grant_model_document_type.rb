module FluxxGrantModelDocumentType

  def self.included(base)
    base.send :include, FluxxModelDocumentType
    
    base.extend(ModelClassMethods)
    base.class_eval do
      include ModelInstanceMethods
    end
  end

  module ModelClassMethods
    def load_by_class klass, options={}
      klass = if klass.is_a? Class
        klass
      else
        klass.class
      end
      ModelDocumentType.where(:model_type => klass.name).where(['if(program_id is not null, program_id = ?, true) AND 
        if(sub_program_id is not null, sub_program_id = ?, true) AND 
          if(initiative_id is not null, initiative_id = ?, true) AND 
            if(sub_initiative_id is not null, sub_initiative_id = ?, true)',
              options[:program_id], options[:sub_program_id], options[:initiative_id], options[:sub_initiative_id]]).order('name asc').all
    end
    
  end

  module ModelInstanceMethods
  end
end