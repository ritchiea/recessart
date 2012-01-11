class FluxxGrantCreateProgramBudget < ActiveRecord::Migration
  def self.up
    create_table :program_budgets do |t|
      t.timestamps
      t.integer :created_by_id, :updated_by_id, :null => true, :limit => 12
      t.integer :program_id
      t.integer :sub_program_id
      t.integer :initiative_id
      t.integer :sub_initiative_id
      t.integer :spending_year
      t.decimal :amount, :scale => 2, :precision => 15
      t.integer :locked_by_id, :null => true, :limit => 12
      t.datetime :locked_until, :deleted_at, :null => true
    end
    add_index :program_budgets, [:spending_year, :program_id]
    add_index :program_budgets, [:spending_year, :sub_program_id]
    add_index :program_budgets, [:spending_year, :initiative_id]
    add_index :program_budgets, [:spending_year, :sub_initiative_id]
    
    add_constraint 'program_budgets', 'program_budgets_program_id', 'program_id', 'programs', 'id'
    add_constraint 'program_budgets', 'program_budgets_sub_program_id', 'sub_program_id', 'sub_programs', 'id'
    add_constraint 'program_budgets', 'program_budgets_initiative_id', 'initiative_id', 'initiatives', 'id'
    add_constraint 'program_budgets', 'program_budgets_subinitiative_id', 'sub_initiative_id', 'sub_initiatives', 'id'
    
    add_constraint 'program_budgets', 'program_budgets_created_by_id', 'created_by_id', 'users', 'id'
    add_constraint 'program_budgets', 'program_budgets_updated_by_id', 'updated_by_id', 'users', 'id'
  end

  def self.down
    drop_table "program_budgets"
  end
end