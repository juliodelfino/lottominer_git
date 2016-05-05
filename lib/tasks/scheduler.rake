require 'sendgrid-ruby'

desc "This task is called by the Heroku scheduler add-on for Lottominer"
task :update_feed => :environment do
  puts "Adding new lotto results..."
  app = ActionDispatch::Integration::Session.new(Rails.application)
  app.get "/task/notify_user_daily?callid=scheduler"
  puts "done."
end

task :get_daily_results => :environment do
  puts "Adding new lotto results..."
  app = ActionDispatch::Integration::Session.new(Rails.application)
  app.get "/task/get_daily_results?callid=scheduler"
  puts "done."
end