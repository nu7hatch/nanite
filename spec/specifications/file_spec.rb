require 'pathname'
require Pathname(__FILE__).dirname.expand_path.parent + 'spec_helper'

describe SpecFile = Nanite::Specification::File do
  
  describe ".new" do
    it "should not require arguments" do
      lambda { SpecFile.new }.should_not raise_error
    end
    
    describe "should set attribute" do
      
      it "#path to first argument of #new" do
        @file = SpecFile.new('/tmp/test')
        @file.path.should == '/tmp/test'
      end
      
      %w( owner perms ).each do |attr|
        it "##{attr} when sent ##{attr}=" do
          @file = SpecFile.new
          @file.send("#{attr}=", 'value')
          @file.send(attr).should == 'value'
        end
      end
    end
    
  end
  
  describe '#content=' do
    before do
      @file = SpecFile.new
    end
    
    it "should set #content" do
      @file.content = 'asdf'
      @file.content.should == 'asdf'
    end
    
    it "should accept an IO, StringIO, String, or Symbol" do
      lambda { @file.content = 'asdf' }.should_not raise_error
      lambda { @file.content = StringIO.new('asdf') }.should_not raise_error
      lambda { @file.content = :something }.should_not raise_error
    end
    
    it "should raise ArgumentError when given anything but IO, StringIO, String, or Symbol" do
      lambda { @file.content = 1 }.should raise_error(ArgumentError)
      lambda { @file.content = Object }.should raise_error(ArgumentError)
    end
  end
  
end