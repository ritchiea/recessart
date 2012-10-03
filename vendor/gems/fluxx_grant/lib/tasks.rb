require 'fluxx_engine'

namespace :fluxx_grant do
  desc "add a all program roles to a user specified by user_id"
  task :add_all_program_roles => :environment do
    user_id = ENV['user_id']
    user = User.find user_id if user_id
    if user
      user.has_permission! 'admin'
      user.user_profile = UserProfile.find_by_name 'employee'
      user.save
      Program.all.each do |program|
        (Program.request_roles + Program.grant_roles + Program.finance_roles).each do |role|
          user.has_role! role, program
        end
      end
    else
      p "Please add an environment variable user_id"
    end
  end
end