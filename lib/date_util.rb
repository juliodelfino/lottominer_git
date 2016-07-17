class DateUtil
    
  def self.now()
    return DateTime.now.in_time_zone('Singapore')
  end
end