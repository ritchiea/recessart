class FluxxGrantAddModelTypeHierarchyToModelDocumentTypes < ActiveRecord::Migration
  def self.up
    change_table :model_document_types do |t|
      t.integer :program_id
      t.integer :sub_program_id
      t.integer :initiative_id
      t.integer :sub_initiative_id
    end
    add_constraint 'model_document_types', 'model_document_types_program_id', 'program_id', 'programs', 'id'
    add_constraint 'model_document_types', 'model_document_types_sub_program_id', 'sub_program_id', 'sub_programs', 'id'
    add_constraint 'model_document_types', 'model_document_types_initiative_id', 'initiative_id', 'initiatives', 'id'
    add_constraint 'model_document_types', 'model_document_types_sub_initiative_id', 'sub_initiative_id', 'sub_initiatives', 'id'
  end

  def self.down
    remove_constraint 'model_document_types', 'model_document_types_program_id', 'program_id', 'programs', 'id'
    remove_constraint 'model_document_types', 'model_document_types_sub_program_id', 'sub_program_id', 'sub_programs', 'id'
    remove_constraint 'model_document_types', 'model_document_types_initiative_id', 'initiative_id', 'initiatives', 'id'
    remove_constraint 'model_document_types', 'model_document_types_sub_initiative_id', 'sub_initiative_id', 'sub_initiatives', 'id'
    change_table :model_document_types do |t|
      t.remove :program_id
      t.remove :sub_program_id
      t.remove :initiative_id
      t.remove :sub_initiative_id
    end
  end
end