class User < ActiveRecord::Base
  include FluxxUser
  
  attr_accessor :password_confirmation
end