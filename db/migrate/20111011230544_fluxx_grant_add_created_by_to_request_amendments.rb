class FluxxGrantAddCreatedByToRequestAmendments < ActiveRecord::Migration
  def self.up
    change_table :request_amendments do |t|
      t.integer :created_by_id
      t.integer :updated_by_id
    end
    
  end

  def self.down
    change_table :request_amendments do |t|
      t.remove :created_by_id
      t.remove :updated_by_id
    end
  end
end