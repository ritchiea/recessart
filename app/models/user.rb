class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :token_authenticatable, :confirmable, :lockable and :timeoutable

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation
  validates_confirmation_of :password
  acts_as_authentic do |c|
    # c.my_config_option = my_value # for available options see documentation in: Authlogic::ActsAsAuthentic
    c.act_like_restful_authentication = true
    c.validate_login_field=false
    c.validate_password_field=false
    c.validate_email_field=false
  end # block optional
  
  include ::FluxxGrantUser
  
  
  # TODO: Make it so that authlogic does not reindex delta indexing in sphinx upon signin
  
end

