class FluxxGrantAddFundingSourceFieldsForEf < ActiveRecord::Migration
  def self.up
    change_table :funding_sources do |t|
      t.decimal :overhead_amount, :scale => 2, :precision => 15
      t.decimal :net_available_to_spend_amount, :scale => 2, :precision => 15
      t.integer :narrative_lead_user_id, :null => true, :limit => 11
      t.string :state
    end
  end

  def self.down
    change_table :funding_sources do |t|
      t.remove :overhead_amount
      t.remove :net_available_to_spend_amount
      t.remove :narrative_lead_user_id
      t.remove :state
    end
  end
end