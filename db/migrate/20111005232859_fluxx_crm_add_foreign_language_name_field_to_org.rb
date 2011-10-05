class FluxxCrmAddForeignLanguageNameFieldToOrg < ActiveRecord::Migration
  def self.up
    change_table :organizations do |t|
      t.string :name_foreign_language, :limit => 1500
    end
  end

  def self.down
    change_table :organizations do |t|
      t.remove :name_foreign_language
    end
  end
end