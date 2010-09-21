class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :trackable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation
  include ::FluxxGrantUser
  
  
  # Make it so that devise does not reindex delta indexing in sphinx upon signin
  def update_tracked_fields_with_specific! request
    User.without_auditing do
      User.without_realtime do
        User.suspended_delta(false) do
          update_tracked_fields_without_specific! request
        end
      end
    end
  end
  alias_method_chain :update_tracked_fields!, :specific
  
end