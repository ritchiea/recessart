class FluxxCrmAddAdhocFlagToModelDocumentTemplate < ActiveRecord::Migration
  def self.up
    change_table :model_document_templates do |t|
      t.boolean :display_in_adhoc_list, :default => false, :null => false
    end
  end

  def self.down
    change_table :model_document_templates do |t|
      t.remove :display_in_adhoc_list
    end
  end
end