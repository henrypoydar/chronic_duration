module ChronicDuration
  extend self
  
  def parse(string)
    
    #begin
      string = string.gsub(' ', '').strip
      string = filter_white_list
      string = filter_type(string)
      
    #rescue
    #  raise ""
    #end
    
    result = "kdkd"
    
    unless result.is_a?(Integer) || result.is_a?(Float)
      raise error_message
    end
    
  end
  
private

  def error_message
    'Sorry, that duration could not be parsed'
  end
  
  def duration_units_list
    %w(seconds minutes hours days weeks months years)
  end
  def duration_units_seconds_multiplier(unit)
    return 0 unless self.duration_units_list.include?(unit)
    case unit
    when 'years';   31557600 # accounts for leap years
    when 'months';  3600 * 24 * 30
    when 'weeks';   3600 * 24 * 7
    when 'days';    3600 * 24
    when 'hours';   3600
    when 'minutes'; 60
    when 'seconds'; 1
    end
  end
  
  # Parse 3:41:59 and return 3 hours 41 minutes 59 seconds
  def filter_type(string)
    if string.gsub(' ', '') =~ /\d*\d*(:\d*\d)/
      res = []
      string.gsub(' ', '').split(':').reverse.each_with_index do |v,k|
        return unless duration_units_list[k]
        res << "#{v} #{duration_units_list[k]}"
      end
      res = res.reverse.join(' ')
    else
      res = string
    end
    res
  end
  
  def mappings
    { 
      'second'  => 'seconds',
      'secs'    => 'seconds',
      'sec'     => 'seconds',
      's'       => 'seconds',
      'minute'  => 'minutes',
      'mins'    => 'minutes',
      'min'     => 'minutes',
      'm'       => 'minutes',
      'hour'    => 'hours',
      'hrs'     => 'hours',
      'hr'      => 'hours',
      'h'       => 'hours',
      'day'     => 'days',
      'dy'      => 'days',
      'd'       => 'days',
      'months'  => 'months',
      'mos'     => 'months',
      'years'   => 'years',
      'yrs'     => 'years',
      'y'       => 'years'
    }
  end
  
  def white_list
    self.mappings.map { |k,v| k }
  end
  
  #TODO strip space, regex word/numerical patterns
  
end