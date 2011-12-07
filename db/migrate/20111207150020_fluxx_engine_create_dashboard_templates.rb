class FluxxEngineCreateDashboardTemplates < ActiveRecord::Migration
  def self.up
    create_table "dashboard_templates", :force => true do |t|
      t.timestamps
      t.integer :created_by_id, :updated_by_id, :null => true, :limit => 12
      t.string :name
      t.text :data
    end

    add_constraint 'dashboard_templates', 'dashboard_templates_created_by_id', 'created_by_id', 'users', 'id'
    add_constraint 'dashboard_templates', 'dashboard_templates_updated_by_id', 'updated_by_id', 'users', 'id'

  end

  def self.down
    drop_table 'dashboard_templates'
  end
end