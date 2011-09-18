class FluxxCrmAddLinkedinFieldToUser < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.string :linkedin_url
    end
  end

  def self.down
    change_table :users do |t|
      t.remove :linkedin_url
    end
  end
end