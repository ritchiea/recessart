# require 'net/ldap'
class User < ActiveRecord::Base

  # Setup accessible (or protected) attributes for your model
  attr_accessible :email, :password, :password_confirmation
  validates_confirmation_of :password

  validates_length_of       :login,    :within => 2..40, :if => lambda {|user| !user.login.blank? }  
  include ::FluxxGrantUser
  
  # TODO: Make it so that authlogic does not reindex delta indexing in sphinx upon signin
  
end
