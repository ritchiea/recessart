class Orchestra < ActiveRecord::Base
  belongs_to :locked_by, :class_name => 'Musician', :foreign_key => 'locked_by_id'
  define_index do
    # fields
    indexes name, :sortable => true
  
    # attributes
    has created_at, updated_at
  end
  
  insta_search do |insta|
    insta.filter_fields = [:created_at, :name]
  end
  insta_lock
  insta_realtime
end
