class FluxxCrmCorrectModelDocTemplateFieldNames < ActiveRecord::Migration
  def self.up
    
    change_table :model_document_templates do |t|
      t.rename :insert_page_break_between_flag, :do_not_insert_page_break
    end
    
  end

  def self.down
    
  end
end