require File.dirname(__FILE__) + '/spec_helper'

describe ElapsedChronic, '#parse' do




end

describe "#white_list" do
  it "should return an array of strings" do
    is_array?(ElapsedChronic.white_list).should be_true
  end
end