class FluxxCrmRemoveDeletedAtFromUserOrganizations < ActiveRecord::Migration
  def self.up
    remove_column :user_organizations, :deleted_at
  end

  def self.down
  end
end
