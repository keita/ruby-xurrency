$LOAD_PATH.unshift File.join(File.dirname(__FILE__), "..", "lib")
require "xurrency"
require "bacon"

include Xurrency::Request

describe "Xurrency::Request" do
  it "should get the currency name" do
    currency_name("jpy").should == "Japanese Yen"
  end

  it "should get the zone" do
    zone("jpy").should == "Japan"
  end

  it "should get the url" do
    url("jpy").should =~ /jpy/
  end

  it "should determin whether the currency is supported or not" do
    currency?("jpy").should.be.true
    currency?("XXX").should.be.false
  end

  it "should list up supported currencies" do
    currencies.should.include("jpy")
  end

  it "should get values" do
    values("jpy").should.has_key("usd")
  end

  it "should get inverse values" do
    values_inverse("jpy").should.has_key("usd")
  end

  it "should get the value" do
    value(1, "jpy", "usd").should > 0
  end
end
