class FluxxGrantAddRequestFieldsToLoi < ActiveRecord::Migration
  def self.up
    add_column :lois, :tax_id, :string rescue nil
    add_column :lois, :amount_requested, :decimal, :scale => 2, :precision => 10 rescue nil
    add_column :lois, :program_id, :integer rescue nil
    add_column :lois, :sub_program_id, :integer rescue nil
    add_column :lois, :duration_in_months, :integer rescue nil
    add_column :lois, :grant_begins_at, :datetime, :null => true rescue nil
  end

  def self.down
    
  end
end