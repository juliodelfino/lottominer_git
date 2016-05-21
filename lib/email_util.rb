class EmailUtil
    
  def self.send(mail_info)
    
    client = SendGrid::Client.new(api_key: ENV['SENDGRID_API_KEY'])
    
    mail = SendGrid::Mail.new do |m|
      m.to = mail_info[:to]
      m.from = mail_info[:from]
      m.subject = mail_info[:subject]
      m.text = mail_info[:text]
    end
    
    res = client.send(mail)
    puts "Sending mail status: " + res.code.to_s
    return res.code.to_s
  end
end