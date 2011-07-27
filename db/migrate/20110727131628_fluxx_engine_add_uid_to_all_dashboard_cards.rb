class FluxxEngineAddUidToAllDashboardCards < ActiveRecord::Migration
  def self.up
    ClientStore.where(:client_store_type => 'dashboard').all.each do |dashboard|
      if dashboard && dashboard.data
        funj = dashboard.data.de_json
        cards = funj['cards']
        if cards
          funj['nextUid'] = cards.size + 1;
          cards.each_with_index do |card, i|
            card['uid'] = i + 1
          end
          dashboard.data = funj.to_json
          dashboard.save
        end
      end
    end
  end

  def self.down
    
  end
end