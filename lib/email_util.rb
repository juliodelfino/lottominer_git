class EmailUtil
    
  def self.send(mail_info)
    
    
=begin
    client = SendGrid::Client.new(api_key: ENV['SENDGRID_API_KEY'])
    
    mail = SendGrid::Mail.new do |m|
      m.to = mail_info[:to]
      m.from = mail_info[:from]
      m.subject = mail_info[:subject]
      m.text = mail_info[:text]
      m.html = mail_info[:html]
    end
    
    res = client.send(mail)
    puts "Sending mail status: " + res.code.to_s
    return res.code.to_s
=end


    from = SendGrid::Email.new(email: mail_info[:from])
    subject = mail_info[:subject]
    to = SendGrid::Email.new(email: mail_info[:to])
    content = SendGrid::Content.new(type: 'text/html', value: mail_info[:html])
    mail = SendGrid::Mail.new(from, subject, to, content)

    sg = SendGrid::API.new(api_key: ENV['SENDGRID_API_KEY'])
    response = sg.client.mail._('send').post(request_body: mail.to_json)

    puts "Sending mail status: " + response.status_code.to_s
    return response.status_code.to_s

  end
end