class FluxxGrantAddIsGrantorToOrganizations < ActiveRecord::Migration
  def self.up
    add_column :organizations, :is_grantor, :boolean, :default => false
  end

  def self.down
    remove_column :organizations, :is_grantor
  end
end
