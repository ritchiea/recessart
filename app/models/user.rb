class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation
  acts_as_authentic do |c|
    # c.my_config_option = my_value # for available options see documentation in: Authlogic::ActsAsAuthentic
    c.act_like_restful_authentication = true
  end # block optional
  
  include ::FluxxGrantUser
  
  
  # TODO: Make it so that authlogic does not reindex delta indexing in sphinx upon signin
  
end

