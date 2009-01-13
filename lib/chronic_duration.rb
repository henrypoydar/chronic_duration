module ChronicDuration
  extend self
  
  def parse(string)
    
    begin
      result = calculate_from_words(cleanup(string))
    rescue
      raise error_message
    end

    unless result.is_a?(Integer) || result.is_a?(Float)
      raise error_message
    end
    
    result
    
  end  
  
private
  
  def calculate_from_words(string)
    
    # words = string.split(' ')
    #    words.each do |word|
    #      
    #    end
  end
  
  def cleanup(string)
    res = filter_by_type(string)
    res = res.gsub(float_matcher) {|n| " #{n} "}.squeeze(' ').strip
    res = filter_through_white_list(res)
  end
  
  def convert_to_number(string)
    string.to_f % 1 > 0 ? string.to_f : string.to_i
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
  
  def error_message
    'Sorry, that duration could not be parsed'
  end
  
  # Parse 3:41:59 and return 3 hours 41 minutes 59 seconds
  def filter_by_type(string)
    if string.gsub(' ', '') =~ /#{float_matcher}(:#{float_matcher})+/
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
  
  def float_matcher
    /[0-9]*\.?[0-9]+/
  end
  
  # Get rid of unknown words and map found
  # words to defined time units
  def filter_through_white_list(string)
    res = []
    string.split(' ').each do |word|
      if word =~ float_matcher
        res << word.strip
        next
      end
      res << mappings[word.strip] if mappings.has_key?(word.strip)
    end
    res.join(' ')
  end
  
  def mappings
    { 
      'seconds' => 'seconds',
      'second'  => 'seconds',
      'secs'    => 'seconds',
      'sec'     => 'seconds',
      's'       => 'seconds',
      'minutes' => 'minutes',
      'minute'  => 'minutes',
      'mins'    => 'minutes',
      'min'     => 'minutes',
      'm'       => 'minutes',
      'hours'   => 'hours',
      'hour'    => 'hours',
      'hrs'     => 'hours',
      'hr'      => 'hours',
      'h'       => 'hours',
      'days'    => 'days',
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
  
end