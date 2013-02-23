require 'numerizer' unless defined?(Numerizer)
module ChronicDuration
  extend self

  class DurationParseError < StandardError
  end

  @@raise_exceptions = false
  @@duration_units = @@supported_duration_units = %w(seconds minutes hours days weeks months years)


  def self.raise_exceptions
    !!@@raise_exceptions
  end

  def self.raise_exceptions=(value)
    @@raise_exceptions = !!value
  end

  def self.use_units(*units)
    if units.first == :all
      @@duration_units = @@supported_duration_units
    else
      @@duration_units = @@supported_duration_units & units.map(&:to_s)
    end
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
    opts[:format] ||= :default
    decimal_places = seconds.to_s.split('.').last.length if seconds.is_a?(Float)
    values = Hash.new(0)
    units = duration_units_list.reverse
    units = units - ['weeks'] unless opts[:weeks]
    units.each do |unit|
      mult = duration_units_seconds_multiplier(unit)
      if seconds >= mult
        values[unit] = (seconds / mult).to_i
        seconds = seconds % mult
      end
    end
    values[units.last] += seconds / duration_units_seconds_multiplier(units.last)

    joiner = ' '
    process = nil

    case opts[:format]
    when :micro
      dividers = {
        'years' => 'y', 'months' => 'mo', 'weeks' => 'w', 'days' => 'd', 'hours' => 'h', 'minutes' => 'm', 'seconds' => 's' }
      joiner = ''
    when :short
      dividers = {
        'years' => 'y', 'months' => 'mo', 'weeks' => 'w', 'days' => 'd', 'hours' => 'h', 'minutes' => 'm', 'seconds' => 's' }
    when :default
      dividers = {
        'years' => ' yr', 'months' => ' mo', 'weeks' => ' wk', 'days' => ' day', 'hours' => ' hr', 'minutes' => ' min', 'seconds' => ' sec',
        :pluralize => true }
    when :long
      dividers = {
        'years' => ' year', 'months' => ' month', 'weeks' => ' week', 'days' => ' day', 'hours' => ' hour', 'minutes' => ' minute', 'seconds' => ' second',
        :pluralize => true }
    when :chrono
      dividers = {
        'years' => ':', 'months' => ':', 'weeks' => ':', 'days' => ':', 'hours' => ':', 'minutes' => ':', 'seconds' => ':', :keep_zero => true }
      process = lambda do |str|
        # Pad zeros
        # Get rid of lead off times if they are zero
        # Get rid of lead off zero
        # Get rid of trailing :
        str.gsub(/\b\d\b/) { |d| ("%02d" % d) }.gsub(/^(00:)+/, '').gsub(/^0/, '').gsub(/:$/, '')
      end
      joiner = ''
    end

    result = units.map do |unit|
      num = values[unit]
      num = ("%.#{decimal_places}f" % num) if num.is_a?(Float)
      humanize_time_unit( num, dividers[unit], dividers[:pluralize], dividers[:keep_zero] )
    end
    result.compact!
    result = result[0...opts[:units]] if opts[:units]
    result = result.join(joiner)

    if process
      result = process.call(result)
    end

    result.length == 0 ? nil : result

  end

private

  def humanize_time_unit(number, unit, pluralize, keep_zero)
    return nil if number == 0 && !keep_zero
    res = "#{number}#{unit}"
    # A poor man's pluralizer
    res << 's' if !(number == 1) && pluralize
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
    @@duration_units
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
    chrono_units_list = duration_units_list.reject {|v| v == "weeks"}
    if string.gsub(' ', '') =~ /#{float_matcher}(:#{float_matcher})+/
      res = []
      string.gsub(' ', '').split(':').reverse.each_with_index do |v,k|
        return unless chrono_units_list[k]
        res << "#{v} #{chrono_units_list[k]}"
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
      if mappings.has_key?(stripped_word) && duration_units_list.include?(mappings[stripped_word])
        res << mappings[stripped_word]
      elsif !join_words.include?(stripped_word) and ChronicDuration.raise_exceptions
        raise DurationParseError, "An invalid word #{word.inspect} was used in the string to be parsed."
      end
    end
    # add '1' at front if string starts with something recognizable but not with a number, like 'day' or 'minute 30sec' 
    res.unshift(1) if res.length > 0 && mappings[res[0]]  
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
      'mo'      => 'months',
      'mos'     => 'months',
      'month'   => 'months',
      'years'   => 'years',
      'year'    => 'years',
      'yrs'     => 'years',
      'yr'      => 'years',
      'y'       => 'years'
    }
  end

  def join_words
    ['and', 'with', 'plus']
  end

  def white_list
    self.mappings.keys
  end

end
