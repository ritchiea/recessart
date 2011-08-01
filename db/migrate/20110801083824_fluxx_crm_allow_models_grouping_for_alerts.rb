class FluxxCrmAllowModelsGroupingForAlerts < ActiveRecord::Migration
  def self.up
    change_table :alerts do |t|
      t.boolean :group_models, :null => false, :default => false
    end
    
  end

  def self.down
    change_table :alerts do |t|
      t.remove :group_models
    end
  end
end