class FluxxGrantAddModelDocumentPermissionType < ActiveRecord::Migration
  def self.up
    change_table :model_documents do |t|
      t.string :s3_permission
    end
  end

  def self.down
    change_table :model_documents do |t|
      t.remove :s3_permission
    end
  end
end