class FluxxGrantMakeEvalMetricsFieldsText < ActiveRecord::Migration
  def self.up
    execute "ALTER TABLE request_evaluation_metrics change column description description text NOT NULL"
    execute "ALTER TABLE request_evaluation_metrics change column comment comment text NOT NULL"
  end

  def self.down
    execute "ALTER TABLE request_evaluation_metrics change column description description varchar(255) NOT NULL"
    execute "ALTER TABLE request_evaluation_metrics change column comment comment varchar(255) NOT NULL"
  end
end