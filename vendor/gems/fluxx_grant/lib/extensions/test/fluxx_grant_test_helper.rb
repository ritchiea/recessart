module FluxxGrantTestHelper
  def self.included(base)
    base.send :include, ::FluxxCrmTestHelper
    base.extend(ModelClassMethods)
    base.class_eval do
      include ModelInstanceMethods
    end
    
    eval "class ActionController::Base
      attr_accessor :current_user
    end"
    
    eval "
    class TestHelper
      def self.loaded_meg= val
        @loaded_meg = val
      end

      def self.loaded_meg
        @loaded_meg
      end

      def self.load_megs
        unless TestHelper.loaded_meg
          TestHelper.loaded_meg = true
          setup_grant_multi_element_groups
          setup_grant_org_tax_classes
          setup_grant_fip_types
        end
      end

      def self.clear_blueprint
        # It's possible to run out of faker values (such as last name), so if you don't reset your shams you could run out of unique values
        Sham.reset

        @entered = {} unless @entered
        unless @entered[\"#{self.class.name}::#{@method_name}\"]
          @entered[\"#{self.class.name}::#{@method_name}\"] = true
          UserProfile.clear_cache
        end
      end
    end
    "
    
  end

  module ModelClassMethods
  end

  module ModelInstanceMethods
    def add_perms user
      user.has_permission! 'listview_all'
      user.has_permission! 'view_all'
      user.has_permission! 'create_all'
      user.has_permission! 'update_all'
      user.has_permission! 'delete_all'
    end

    def login_as user
      add_perms user

      @controller.current_user = user
    end

    def login_as_user_with_role role_name, program=@program
      @alternate_user = User.make
      @alternate_user.has_role! role_name, program 
      login_as @alternate_user
      @alternate_user
    end

    def current_user
      @current_user unless @current_user == false
    end

    # Store the given user id in the session.
    def current_user=(new_user)
      @current_user = new_user || false
    end
  end
end