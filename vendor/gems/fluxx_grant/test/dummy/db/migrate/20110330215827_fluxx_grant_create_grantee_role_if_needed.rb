class FluxxGrantCreateGranteeRoleIfNeeded < ActiveRecord::Migration
  def self.up
    if Role.where(:name => 'Grantee').count < 1
      Role.create :name => 'Grantee', :roleable_type => 'Program'
    end
    
  end

  def self.down
    Role.where(:name => 'Grantee').first.destroy
  end
end