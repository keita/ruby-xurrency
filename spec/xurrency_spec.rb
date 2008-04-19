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
    res.__id__.should.not == $xu.update_zone("jpy").__id__
  end

  it "should know weather cached or not" do
    $xu.zone_cached?("cny").should.be.false
    $xu.zone("cny")
    $xu.zone_cached?("cny").should.be.true
  end

  it "should clear cache" do
    $xu.zone("usd")
    $xu.zone_cached?("usd").should.be.true
    $xu.clear_zone("usd")
    $xu.zone_cached?("usd").should.be.false
  end

  it "should respond methods" do
    methods = []
    list = [ "currency_name",
             "zone",
             "url",
             "currencies",
             "values",
             "values_inverse" ]
    methods += list
    methods += list.map {|name| "update_#{name}" }
    methods += list.map {|name| "clear_#{name}" }
    methods += list.map {|name| "#{name}_cached?" }
    methods.each {|name| $xu.methods.should.include? name }
  end
end
