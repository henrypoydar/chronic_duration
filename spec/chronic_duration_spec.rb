require 'chronic_duration'

describe ChronicDuration, '.parse' do
  
  @exemplars = { 
    '1:20'                  => 60 + 20,
    '1:20.51'               => 60 + 20.51,
    '4:01:01'               => 4 * 3600 + 60 + 1,
    '3 mins 4 sec'          => 3 * 60 + 4,
    '3 Mins 4 Sec'          => 3 * 60 + 4,
    'three mins four sec'          => 3 * 60 + 4,
    '2 hrs 20 min'          => 2 * 3600 + 20 * 60,
    '2h20min'               => 2 * 3600 + 20 * 60,
    '6 mos 1 day'           => 6 * 30 * 24 * 3600 + 24 * 3600,
    '1 year 6 mos 1 day'    => 1 * 31536000 + 6 * 30 * 24 * 3600 + 24 * 3600,
    '2.5 hrs'               => 2.5 * 3600,
    '47 yrs 6 mos and 4.5d' => 47 * 31536000 + 6 * 30 * 24 * 3600 + 4.5 * 24 * 3600,
    'two hours and twenty minutes' => 2 * 3600 + 20 * 60,
    'four hours and forty minutes' => 4 * 3600 + 40 * 60,
    'four hours, and fourty minutes' => 4 * 3600 + 40 * 60,
    '3 weeks and, 2 days' => 3600 * 24 * 7 * 3 + 3600 * 24 * 2,
    '3 weeks, plus 2 days' => 3600 * 24 * 7 * 3 + 3600 * 24 * 2,
    '3 weeks with 2 days' => 3600 * 24 * 7 * 3 + 3600 * 24 * 2,
    '1 month'               => 3600 * 24 * 30,
    '2 months'              => 3600 * 24 * 30 * 2
  }
  
  it "should return nil if the string can't be parsed" do
    ChronicDuration.parse('gobblygoo').should be_nil
  end
  
  it "should raise an exception if the string can't be parsed and @@raise_exceptions is set to true" do
    ChronicDuration.raise_exceptions = true
    lambda { ChronicDuration.parse('23 gobblygoos') }.should raise_exception(ChronicDuration::DurationParseError)
    ChronicDuration.raise_exceptions = false
  end
  
  it "should return a float if seconds are in decimals" do
    ChronicDuration.parse('12 mins 3.141 seconds').is_a?(Float).should be_true
  end
  
  it "should return an integer unless the seconds are in decimals" do
    ChronicDuration.parse('12 mins 3 seconds').is_a?(Integer).should be_true
  end
  
  
  
  @exemplars.each do |k, v|
    it "should properly parse a duration like #{k}" do
      ChronicDuration.parse(k).should == v
    end
  end
  
end

describe ChronicDuration, '.output' do
  
  it "should return nil if the input can't be parsed" do
    ChronicDuration.parse('gobblygoo').should be_nil
  end
  
  @exemplars = { 
    (60 + 20) => 
      { 
        :micro    => '1m20s',
        :short    => '1m 20s',
        :default  => '1 min 20 secs',
        :long     => '1 minute 20 seconds',
        :chrono   => '1:20'
      },
    (60 + 20.51) => 
      { 
        :micro    => '1m20.51s',
        :short    => '1m 20.51s',
        :default  => '1 min 20.51 secs',
        :long     => '1 minute 20.51 seconds',
        :chrono   => '1:20.51'
      },
    (4 * 3600 + 60 + 1) => 
      { 
        :micro    => '4h1m1s',
        :short    => '4h 1m 1s',
        :default  => '4 hrs 1 min 1 sec',
        :long     => '4 hours 1 minute 1 second',
        :chrono   => '4:01:01'
      },
    (2 * 3600 + 20 * 60) => 
      { 
        :micro    => '2h20m',
        :short    => '2h 20m',
        :default  => '2 hrs 20 mins',
        :long     => '2 hours 20 minutes',
        :chrono   => '2:20'
      },
    (2 * 3600 + 20 * 60) => 
      { 
        :micro    => '2h20m',
        :short    => '2h 20m',
        :default  => '2 hrs 20 mins',
        :long     => '2 hours 20 minutes',
        :chrono   => '2:20:00'
      },
    (6 * 30 * 24 * 3600 + 24 * 3600) => 
      { 
        :micro    => '6m1d',
        :short    => '6m 1d',
        :default  => '6 mos 1 day',
        :long     => '6 months 1 day',
        :chrono   => '6:01:00:00:00' # Yuck. FIXME
      }
  }
  
  @exemplars.each do |k, v|
    v.each do |key, val|
      it "should properly output a duration of #{k} seconds as #{val} using the #{key.to_s} format option" do
        ChronicDuration.output(k, :format => key).should == val
      end
    end
  end
  
  it "should use the default format when the format is not specified" do
    ChronicDuration.output(2 * 3600 + 20 * 60).should == '2 hrs 20 mins'
  end
  
  
end


# Some of the private methods deserve some spec'ing to aid
# us in development...

describe ChronicDuration, "private methods" do
  
  describe ".filter_by_type" do
    
    it "should take a chrono-formatted time like 3:14 and return a human time like 3 minutes 14 seconds" do
      ChronicDuration.instance_eval("filter_by_type('3:14')").should == '3 minutes 14 seconds'
    end
    
    it "should take a chrono-formatted time like 12:10:14 and return a human time like 12 hours 10 minutes 14 seconds" do
      ChronicDuration.instance_eval("filter_by_type('12:10:14')").should == '12 hours 10 minutes 14 seconds'
    end
    
    it "should return the input if it's not a chrono-formatted time" do
      ChronicDuration.instance_eval("filter_by_type('4 hours')").should == '4 hours'
    end
  
  end
  
  describe ".cleanup" do
    
    it "should clean up extraneous words" do
      ChronicDuration.instance_eval("cleanup('4 days and 11 hours')").should == '4 days 11 hours'
    end
    
    it "should cleanup extraneous spaces" do
      ChronicDuration.instance_eval("cleanup('  4 days and 11     hours')").should == '4 days 11 hours'
    end
    
    it "should insert spaces where there aren't any" do
      ChronicDuration.instance_eval("cleanup('4m11.5s')").should == '4 minutes 11.5 seconds'
    end
    
  end
  
end 
