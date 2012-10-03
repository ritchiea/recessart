module FluxxFavorite
  def self.included(base)
    base.belongs_to :favorable, :polymorphic => true
    base.belongs_to :user

    base.after_commit :update_related_data
    base.insta_search
    
    base.extend(ModelClassMethods)
    base.class_eval do
      include ModelInstanceMethods
    end
  end

  module ModelClassMethods
  end

  module ModelInstanceMethods
    def update_related_data
      if favorable && favorable.class.respond_to?(:indexed_by_sphinx?)
        favorable.class.update_all 'delta = 1', ['id = ?', favorable.id]
        if favorable
          favorable.delta = 1
          favorable.save 
        end
      end
    end
  end
end