class FluxxGrantAddLinkFieldsToLoi < ActiveRecord::Migration
  def self.up
    change_table :lois do |t|
      t.integer :user_id
      t.integer :request_id
      t.integer :organization_id
    end
  end

  def self.down
    change_table :lois do |t|
      t.remove :user_id
      t.remove :request_id
      t.remove :organization_idr
    end
  end
end