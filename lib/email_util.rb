class EmailUtil
    
  def self.send(mail_info)
    
    client = SendGrid::Client.new(api_key: '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')
    
    mail = SendGrid::Mail.new do |m|
      m.to = mail_info[:to]
      m.from = mail_info[:from]
      m.subject = mail_info[:subject]
      m.text = mail_info[:text]
    end
    
    res = client.send(mail)
    Rails.logger.debug "Sending mail status: " + res.code.to_s
  end
end