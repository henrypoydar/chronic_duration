require File.dirname(__FILE__) + '/spec_helper'

describe ChronicDuration, '#parse' do



end

describe ChronicDuration, "#white_list" do
  
  it "should return an array of strings" do
    is_array?(ChronicDuration.white_list).should be_true
  end

end