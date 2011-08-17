class FluxxEngineCreateSphinxCheck < ActiveRecord::Migration
  def self.up
    create_table "sphinx_checks", :force => true, :client_id => false do |t|
      t.timestamps
      t.integer :check_ts
    end
    execute "insert into sphinx_checks (check_ts) values (0)"
  end

  def self.down
    drop_table "sphinx_checks"
  end
end