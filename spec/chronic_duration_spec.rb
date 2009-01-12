require File.dirname(__FILE__) + '/spec_helper'

describe ChronicDuration, 'gem' do
  
  it "should build a gem" do
    FileUtils.rm_rf(File.dirname(__FILE__) + '../chronic_duration.gemspec')
    system "cd #{File.dirname(__FILE__)}/.. && gem build chronic_duration.gemspec"
    File.fnmatch?("#{File.dirname(__FILE__)}/../chronic_duration*.gem")
  end
  
end

describe ChronicDuration, '#parse' do


  it "should raise a canned error if the parsing fails"

end

describe ChronicDuration, "#white_list" do
  
  it "should return an array of strings" do
    #is_array?(ChronicDuration.white_list).should be_true
  end

end