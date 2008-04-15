$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "..", "lib")
require "xurrency"
require "bacon"

$xu = Xurrency.new

describe "Xurrency" do
  it "should cache queries" do
    res = $xu.currency_name("jpy")
    res.should == "Japanese Yen"
    res.__id__.should == $xu.currency_name("jpy").__id__
    res.__id__.should.not == Xurrency::Request.currency_name("jpy").__id__
  end

  it "should update the value" do
    res = $xu.zone("jpy")
    res.should == "Japan"
    res.__id__.should == $xu.zone("jpy").__id__
    res.__id__.should.not == $xu.update(:zone, "jpy").__id__
  end
end
