class FluxxGrantAddC3FieldToOrganization < ActiveRecord::Migration
  def self.up
    change_table :organizations do |t|
      t.boolean :c3_status_approved, :null => false, :default => false
      t.text :c3_serialized_response, :null => true
    end
    
  end

  def self.down
    change_table :organizations do |t|
      t.remove :c3_status_approved
      t.remove :c3_serialized_response
    end
  end
end