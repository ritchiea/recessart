class FluxxGrantSwitchRequestFundingSourceAuthoritiesToAllocation < ActiveRecord::Migration
  def self.up
    execute "update multi_element_groups set target_class_name='FundingSourceAllocation' where target_class_name='RequestFundingSource'"
  end

  def self.down
    execute "update multi_element_groups set target_class_name='RequestFundingSource' where target_class_name='FundingSourceAllocation'"
  end
end