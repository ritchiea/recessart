class FluxxEngineCreateRealtimeUpdatesTable < ActiveRecord::Migration
  def self.up
    create_table :realtime_updates do |t|
      t.timestamps
      t.string :action,       :null => false  # create/update/delete
      t.integer :user_id,         :limit => 12, :null => true
      t.integer :model_id,        :limit => 12, :null => false
      t.string :type_name,      :null => false
      t.string :model_class,      :null => false
      t.text :delta_attributes,   :null => false # describe the attributes (in YAML) which were changed
    end
  end

  def self.down
    drop_table :accounts
  end
end
