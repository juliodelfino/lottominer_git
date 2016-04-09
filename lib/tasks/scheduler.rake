require 'sendgrid-ruby'

desc "This task is called by the Heroku scheduler add-on for Lottominer"
task :update_feed => :environment do
  puts "Adding new lotto results..."
  @result = generate_result
  send_lotto_mail(@result)
  puts "done."
end

def generate_result
  @result = LottoResult.create(game: "SuperLotto 6/49", numbers: "3 6 8 12 16 49", won: false)
  @result.save
end

def send_lotto_mail(mail_info)
  
  client = SendGrid::Client.new(api_key: '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')
  
  mail = SendGrid::Mail.new do |m|
    m.to = 'jhackr@gmail.com'
    m.from = 'taco@cat.limo'
    m.subject = 'Notification from Lottominer ' + mail_info.created_at
    m.text = 'Here are the lotto results:<br>Game: ' + mail_info.game + "<br>Results: " + mail_info.numbers
  end

  res = client.send(mail)
  @resp = LottoResult.create(game: res.code, numbers: res.body, won: false)
  @resp.save
end