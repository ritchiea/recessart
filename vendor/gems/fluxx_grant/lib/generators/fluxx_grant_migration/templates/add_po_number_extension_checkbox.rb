class FluxxGrantAddPoNumberExtensionCheckbox < ActiveRecord::Migration
  def self.up
    change_table :requests do |t|
      t.string :po_number
      t.boolean :extension_flag
    end
  end

  def self.down
    change_table :requests do |t|
      t.remove :po_number
      t.remove :extension_flag
    end
  end
end