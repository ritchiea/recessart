class FluxxGrantAddOrganizationForeignNameToLoi < ActiveRecord::Migration
  def self.up
    change_table :lois do |t|
      t.string :organization_name_foreign_language, :limit => 1500
    end
  end

  def self.down
    change_table :lois do |t|
      t.remove :organization_name_foreign_language
    end
  end
end
