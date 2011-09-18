class FluxxGrantAddHgrantOmitFlag < ActiveRecord::Migration
  def self.up
    change_table :requests do |t|
      t.boolean :skip_hgrant_flag, :default => false, :null => false
    end
  end

  def self.down
    change_table :requests do |t|
      t.remove :skip_hgrant_flag, :default => false, :null => false
    end
  end
end
