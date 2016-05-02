require 'sendgrid-ruby'

desc "This task is called by the Heroku scheduler add-on for Lottominer"
task :update_feed => :environment do
  puts "Adding new lotto results..."
  app = ActionDispatch::Integration::Session.new(Rails.application)
  app.get "/articles?from=updater"
#  @result = generate_result
#  send_lotto_mail(@result)
  puts "done."
end