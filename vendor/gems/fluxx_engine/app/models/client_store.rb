class ClientStore < ActiveRecord::Base
  SEARCH_ATTRIBUTES = [:name, :client_store_type]
  insta_search do |insta|
    insta.filter_fields = SEARCH_ATTRIBUTES
  end
  validates_presence_of     :name
  acts_as_audited({:full_model_enabled => false, :except => [:created_by_id, :modified_by_id, :locked_until, :locked_by_id, :delta, :updated_by, :created_by, :audits]})
end