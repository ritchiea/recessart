class FluxxGrantDropRequestLetters < ActiveRecord::Migration
  def self.up
    drop_table :request_letters
    drop_table :letter_templates
  end

  def self.down
  end
end