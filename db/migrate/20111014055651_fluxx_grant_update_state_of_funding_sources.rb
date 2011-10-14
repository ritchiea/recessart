class FluxxGrantUpdateStateOfFundingSources < ActiveRecord::Migration
  def self.up
    execute "update funding_sources set state = 'approved'"
  end

  def self.down
    
  end
end