require 'numerizer'
module ChronicDuration
  extend self
  
  # Given a string representation of elapsed time,
  # return an integer (or float, if fractions of a
  # second are input)
  def parse(string)
    result = calculate_from_words(cleanup(string))
    result == 0 ? nil : result
  end  
  
  # Given an integer and an optional format,
  # returns a formatted string representing elapsed time
  def output(seconds, opts = {})
    
    opts[:format] ||= :default
    
    years = months = days = hours = minutes = 0
    
    if seconds >= 60
      minutes = (seconds / 60).to_i 
      seconds = seconds % 60
      if minutes >= 60
        hours = (minutes / 60).to_i
        minutes = (minutes % 60).to_i
        if hours >= 24
          days = (hours / 24).to_i
          hours = (hours % 24).to_i
          if days >= 30
            months = (days / 30).to_i
            days = (days % 30).to_i
            if months >= 12
              years = (months / 12).to_i
              months = (months % 12).to_i
            end
          end
        end
      end
    end
    
    joiner = ' '
    process = nil
    
    case opts[:format]
    when :short
      dividers = { 
        :years => 'y', :months => 'm', :days => 'd', :hours => 'h', :minutes => 'm', :seconds => 's' }
    when :default 
      dividers = {
        :years => ' yr', :months => ' mo', :days => ' day', :hours => ' hr', :minutes => ' min', :seconds => ' sec',
        :pluralize => true }
    when :long 
      dividers = {
        :years => ' year', :months => ' month', :days => ' day', :hours => ' hour', :minutes => ' minute', :seconds => ' second', 
        :pluralize => true }
    when :chrono
      dividers = {
        :years => ':', :months => ':', :days => ':', :hours => ':', :minutes => ':', :seconds => ':', :keep_zero => true }
      process = lambda do |str|
        # Pad zeros
        # Get rid of lead off times if they are zero
        # Get rid of lead off zero
        # Get rid of trailing :
        str.gsub(/\b\d\b/) { |d| ("%02d" % d) }.gsub(/^(00:)+/, '').gsub(/^0/, '').gsub(/:$/, '')
      end
      joiner = ''
    end
    
    result = []
    [:years, :months, :days, :hours, :minutes, :seconds].each do |t|
      result << humanize_time_unit( eval(t.to_s), dividers[t], dividers[:pluralize], dividers[:keep_zero] )
    end
    
    result = result.join(joiner).squeeze(' ').strip
    
    if process
      result = process.call(result)
    end
    
    result.length == 0 ? nil : result

  end
  
private
  
  def humanize_time_unit(number, unit, pluralize, keep_zero)
    return '' if number == 0 && !keep_zero
    res = "#{number}#{unit}"
    # A poor man's pluralizer
    res << 's' if !(number == 1) && pluralize
    res
  end
  
  def calculate_from_words(string)
    val = 0
    words = string.split(' ')
    words.each_with_index do |v, k|
      if v =~ float_matcher
        val += (convert_to_number(v) * duration_units_seconds_multiplier(words[k + 1] || 'seconds'))
      end
    end
    val
  end
  
  def cleanup(string)
    res = filter_by_type(Numerizer.numerize(string))
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
    return 0 unless duration_units_list.include?(unit)
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
    self.mappings.map {|k, v| k}
  end
  
end