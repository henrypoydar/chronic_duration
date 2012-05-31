require 'numerizer' unless defined?(Numerizer)
module ChronicDuration
  extend self
  
  class DurationParseError < StandardError
  end
  
  @@raise_exceptions = false
  
  def self.raise_exceptions
    !!@@raise_exceptions
  end
  
  def self.raise_exceptions=(value)
    @@raise_exceptions = !!value
  end
  
  # Given a string representation of elapsed time,
  # return an integer (or float, if fractions of a
  # second are input)
  def parse(string, opts = {})
    result = calculate_from_words(cleanup(string), opts)
    result == 0 ? nil : result
  end  
  
  # Given an integer and an optional format,
  # returns a formatted string representing elapsed time
  def output(seconds, opts = {})
    
    # default unit values (useful for later lookup)
    unit_values = [:years, :months, :days, :hours, :minutes, :seconds]
    
    opts[:format] ||= :default
    
    # allow customization on the units to display and whether 
    # to show zero value units
    opts[:units] ||= unit_values
    opts[:keep_zero] ||= false
    opts[:verbose] ||= false
    
    years = months = days = hours = minutes = 0
    
    decimal_places = seconds.to_s.split('.').last.length if seconds.is_a?(Float)

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
    when :micro
      dividers = { 
        :years => 'y', :months => 'm', :days => 'd', :hours => 'h', :minutes => 'm', :seconds => 's' }
      joiner = ''
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
        :years => ':', :months => ':', :days => ':', :hours => ':', :minutes => ':', :seconds => ':' }
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

    opts[:units].each_with_index do |t,i|
      num = eval(t.to_s)

      # Determine whether we're showing the first unit. If so loop up the tree
      # to add back the greater units.
      # TODO : needs refactoring
      if i == 0
        position = unit_values.index t
        multiplier = duration_units_seconds_multiplier(t.to_s)
        if position > 0
          num = num.to_i
          unit_values[0..(position-1)].each do |u|
            if duration_units_seconds_multiplier(u.to_s) > multiplier
              num += eval(u.to_s).to_i * (duration_units_seconds_multiplier(u.to_s)/multiplier).to_i
            end
          end
        end
      end

      num = ("%.#{decimal_places}f" % num) if num.is_a?(Float) && t == :seconds 

      result << humanize_time_unit( num, dividers[t], dividers[:pluralize], opts[:keep_zero], opts[:verbose] )
    end

    result = result.join(joiner).squeeze(' ').strip
    
    if process
      result = process.call(result)
    end
    
    result.length == 0 ? nil : result

  end
  
private
  
  def humanize_time_unit(number, unit, pluralize, keep_zero, verbose)
    return '' if number == 0 && !keep_zero
    if verbose
      res = "<span class=\"number-#{unit.strip}\">#{number}</span>"
      res << "<span class=\"unit-#{unit.strip}\">#{unit}#{'s' if !(number == 1) && pluralize}</span>"
    else
      res = "#{number}#{unit}"
      # A poor man's pluralizer
      res << 's' if !(number == 1) && pluralize
    end
    res
  end
  
  def calculate_from_words(string, opts)
    val = 0
    words = string.split(' ')
    words.each_with_index do |v, k|
      if v =~ float_matcher
        val += (convert_to_number(v) * duration_units_seconds_multiplier(words[k + 1] || (opts[:default_unit] || 'seconds')))
      end
    end
    val
  end
  
  def cleanup(string)
    res = string.downcase
    res = filter_by_type(Numerizer.numerize(res))
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
    when 'years';   31536000 # doesn't accounts for leap years
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
      stripped_word = word.strip.gsub(/^,/, '').gsub(/,$/, '')
      if mappings.has_key?(stripped_word)
        res << mappings[stripped_word]
      elsif !join_words.include?(stripped_word) and ChronicDuration.raise_exceptions
        raise DurationParseError, "An invalid word #{word.inspect} was used in the string to be parsed."
      end
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
      'weeks'   => 'weeks',
      'week'    => 'weeks',
      'w'       => 'weeks',
      'months'  => 'months',
      'mos'     => 'months',
      'month'   => 'months',
      'years'   => 'years',
      'year'    => 'years',
      'yrs'     => 'years',
      'y'       => 'years'
    }
  end
  
  def join_words
    ['and', 'with', 'plus']
  end
  
  def white_list
    self.mappings.map {|k, v| k}
  end
  
end
