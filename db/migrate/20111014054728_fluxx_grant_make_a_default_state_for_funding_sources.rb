class FluxxGrantMakeADefaultStateForFundingSources < ActiveRecord::Migration
  def self.up
    change_column 'funding_sources', 'state', :string, :null => false, :default => 'approved'
  end

  def self.down
    
  end
end