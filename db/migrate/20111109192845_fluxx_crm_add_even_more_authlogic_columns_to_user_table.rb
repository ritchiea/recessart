class FluxxCrmAddEvenMoreAuthlogicColumnsToUserTable < ActiveRecord::Migration
  def self.up
    change_table :users do |t|
      t.boolean :active, :default => true
      t.boolean :approved, :default => true
      t.boolean :confirmed, :default => true
    end
  end

  def self.down
    change_table :users do |t|
      t.remove :active
      t.remove :approved
      t.remove :confirmed
    end
  end
end