require File.join(File.dirname(__FILE__), '..', 'spec_helper')

describe Stream do

  describe "validations" do
    
    it "should be valid with valid attributes" do
      Stream.gen.should(be_valid)
    end
    
    it "should require a title" do
      pending
    end
  end
  
end