class FluxxCrmAddFacebookFieldToUser < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.string :facebook_url
    end
  end

  def self.down
    change_table :users do |t|
      t.remove :facebook_url
    end
  end
end