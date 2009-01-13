require File.dirname(__FILE__) + '/spec_helper'

describe ChronicDuration, 'gem' do
  
  it "should build" do
    spec = eval(File.read("#{File.dirname(__FILE__)}/../chronic_duration.gemspec"))
    FileUtils.rm_f(File.dirname(__FILE__) + "/../chronic_duration-#{spec.version}.gem")
    system "cd #{File.dirname(__FILE__)}/.. && gem build chronic_duration.gemspec -q --no-verbose"
    File.exists?(File.dirname(__FILE__) + "/../chronic_duration-#{spec.version}.gem").should be_true
    FileUtils.rm_f(File.dirname(__FILE__) + "/../chronic_duration-#{spec.version}.gem")
  end
  
end

describe ChronicDuration, '.parse' do
  
  @exemplars = { 
    '1:20'          => 60 + 20,
    '1:20.51'       => 60 + 20.51,
    '4:01:01'       => 4 * 3600 + 60 + 1,
    '3 mins 4 sec'  => 3 * 60 + 4,
    '2 hrs 20 min'  => 2 * 3600 + 20 * 60,
    '2h20min'       => 2 * 3600 + 20 * 60
  }
  
  it "should raise a canned error if the parsing fails" do
    lambda { ChronicDuration.parse('gobblygoo') }.should raise_error
    lambda { ChronicDuration.parse('4 hours 20 minutes') }.should_not raise_error
  end
  
  it "should return a float if seconds are in decimals" do
    pending
  end
  
  it "should return an integer unless the seconds are in decimals" do
    pending
    
  end
  
  @exemplars.each do |k,v|
    it "should properly parse a duration like #{k}" do
      ChronicDuration.parse(k).should == v
    end
  end
  
end

# Some of the private methods deserve some spec'ing to aid
# us in development...

describe ChronicDuration, "private methods" do
  
  describe "#filter_type" do
    it "should take a chrono-formatted time like 3:14 and return a human time like 3 hours 14 minutes" do
      ChronicDuration.instance_eval("filter_type('3:14')").should == '3 minutes 14 seconds'
    end
    it "should return the input if it's not a chrono-formatted time" do
      ChronicDuration.instance_eval("filter_type('4 hours')").should == '4 hours'
    end
  end
  
end 