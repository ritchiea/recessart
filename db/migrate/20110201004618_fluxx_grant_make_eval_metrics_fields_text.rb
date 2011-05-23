class FluxxGrantMakeEvalMetricsFieldsText < ActiveRecord::Migration
  def self.up
    change_column :request_evaluation_metrics, :description, :text
    change_column :request_evaluation_metrics, :comment, :text
  end

  def self.down
  end
end