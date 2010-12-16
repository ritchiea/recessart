class FluxxGrantAddNewFieldsToFundingSource < ActiveRecord::Migration
  def self.up
    add_column :funding_sources, :start_at, :datetime
    add_column :funding_sources, :end_at, :datetime
    add_column :funding_sources, :retired, :boolean
  end

  def self.down
    remove_column :funding_sources, :retired
    remove_column :funding_sources, :end_at
    remove_column :funding_sources, :start_at
  end
end