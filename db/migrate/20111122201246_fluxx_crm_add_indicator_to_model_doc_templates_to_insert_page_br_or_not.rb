class FluxxCrmAddIndicatorToModelDocTemplatesToInsertPageBrOrNot < ActiveRecord::Migration
  def self.up
    change_table :model_document_templates do |t|
      t.boolean :insert_page_break_between_flag
    end
  end

  def self.down
    change_table :model_document_templates do |t|
      t.remove :insert_page_break_between_flag
    end
  end
end