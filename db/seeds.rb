# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)

energy_program = Program.create :created_at => Time.now, :updated_at => Time.now, :name => 'Energy', :description => 'Energy'
power_program = Program.create :created_at => Time.now, :updated_at => Time.now, :name => 'Power', :description => 'Power'
coal_program = Program.create :created_at => Time.now, :updated_at => Time.now, :name => 'Coal', :description => 'Coal'

Initiative.create :created_at => Time.now, :updated_at => Time.now, :name => 'Energy - initiative', :description => 'Energy - initiative', :program_id => energy_program
Initiative.create :created_at => Time.now, :updated_at => Time.now, :name => 'Power - initiative', :description => 'Power - initiative', :program_id => power_program
Initiative.create :created_at => Time.now, :updated_at => Time.now, :name => 'Coal - initiative', :description => 'Coal - initiative', :program_id => coal_program
