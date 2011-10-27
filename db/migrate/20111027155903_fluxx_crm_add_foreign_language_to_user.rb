class FluxxCrmAddForeignLanguageToUser < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.string :first_name_foreign_language, :limit => 500
      t.string :middle_name_foreign_language, :limit => 500
      t.string :last_name_foreign_language, :limit => 500
    end
  end

  def self.down
    change_table :users do |t|
      t.remove :first_name_foreign_language
      t.remove :middle_name_foreign_language
      t.remove :last_name_foreign_language
    end
  end
end