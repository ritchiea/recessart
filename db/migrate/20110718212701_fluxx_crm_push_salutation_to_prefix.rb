class FluxxCrmPushSalutationToPrefix < ActiveRecord::Migration
  def self.up
    execute 'update users set prefix = salutation, salutation = null where salutation is not null'
  end

  def self.down
    
  end
end