class FluxxGrantCreateRequestEvaluationMetrics < ActiveRecord::Migration
  def self.up
    create_table :request_evaluation_metrics do |t|
      t.timestamps
      t.integer :created_by_id, :updated_by_id, :null => true, :limit => 12
      t.integer :request_id, :null => false, :limit => 12
      t.string :description
      t.string :comment
      t.boolean :achieved
    end
    add_constraint 'request_evaluation_metrics', 'request_evaluation_metrics_request_id', 'request_id', 'requests', 'id'
  end

  def self.down
    drop_table :request_evaluation_metrics
  end
end
