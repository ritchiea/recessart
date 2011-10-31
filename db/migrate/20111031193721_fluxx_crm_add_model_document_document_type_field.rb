class FluxxCrmAddModelDocumentDocumentTypeField < ActiveRecord::Migration
  def self.up
    change_table :model_documents do |t|
      t.string :label, :null => false, :default => 'default'
    end
  end

  def self.down
    change_table :model_documents do |t|
      t.remove :label
    end
  end
end