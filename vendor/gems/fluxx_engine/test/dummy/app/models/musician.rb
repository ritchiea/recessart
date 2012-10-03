class Musician < ActiveRecord::Base
  belongs_to :first_instrument, :class_name => 'Instrument', :foreign_key => :first_instrument_id
  has_many :musician_instruments
  has_many :instruments, :through => :musician_instruments
  
  validates_presence_of     :first_name
  validates_length_of       :first_name,    :within => 3..100
  
  validates_presence_of     :last_name
  validates_length_of       :last_name,    :within => 3..100
  
  insta_search do |insta|
  end
  insta_export do |insta|
  end
  insta_realtime do |insta|
  end
  insta_multi
  insta_lock
  insta_utc do |insta|
    insta.time_attributes = [:date_of_birth]
  end
  
  insta_template do |insta|
    insta.add_methods [:first_name_backwards, :first_instrument]
    insta.add_list_method :instruments, Instrument
    insta.remove_methods [:date_of_birth]
  end
  
  def first_name_backwards
    first_name.reverse
  end

  def to_s
    "#{first_name} #{last_name}"
  end
end
