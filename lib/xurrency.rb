require "rubygems"
require "soap/soap"
require "soap/wsdlDriver"
require "singleton"
require "delegate"

class Xurrency
  VERSION = "002"

  # Soap client.
  class Client < Delegator #:nodoc:
    include Singleton

    WSDL = "http://xurrency.com/api.wsdl"

    def initialize
      @driver = SOAP::WSDLDriverFactory.new(WSDL).create_rpc_driver
      @driver.endpoint_url = "http://www.xurrency.com/servidor_soap.php"
    end

    def __getobj__
      @driver
    end
  end

  module Request
    module_function

    # getName(code)
    def currency_name(code)
      Client.instance.getName(code)
    end

    # getZone(code)
    def zone(code)
      Client.instance.getZone(code)
    end

    # getURL(code)
    def url(code)
      Client.instance.getURL(code)
    end

    # isCurrency(code)
    def currency?(code)
      Client.instance.isCurrency(code)
    end

    # getCurrencies
    def currencies
      Client.instance.getCurrencies
    end

    # getValues(code)
    def values(code)
      table = {}
      Client.instance.getValues(code).each do |c|
        table[c["Id"]] = c["Value"]
      end
      return table
    end

    # getValuesInverse(code)
    def values_inverse(code)
      table = {}
      Client.instance.getValuesInverse(code).each do |c|
        table[c["Id"]] = c["Value"]
      end
      return table
    end

    # getValue(amount, base, target)
    def value(amount, base, target)
      Client.instance.getValue(amount, base, target)
    end
  end

  def initialize(init = nil)
    @cache = {}
    memoize :currency_name
    memoize :zone
    memoize :url
    memoize :currencies
    memoize :values
    memoize :values_inverse
    if init
      init = Request.currencies if init == :all
      init.each {|c| values(c) }
    end
  end

  # Calculates the value without quering getValue.
  def value(amount, base, target)
    values(base)[target] * amount
  end

  private

  # Memoize some queries.
  def memoize(name)
    @cache[name] = {}
    klass = (class << self; self; end)
    klass.__send__(:define_method, name) do |*args|
      return @cache[name][args] if @cache[name].has_key?(args)
      @cache[name][args] = Request.send(name, *args)
      @cache[name][args][:timestamp] = Time.now if name.to_s =~ /values/
      return @cache[name][args]
    end
    klass.__send__(:define_method, "update_#{name}") do |*args|
      @cache[name].delete(args)
      __send__(name, *args)
    end
    klass.__send__(:define_method, "#{name}_cached?") do |*args|
      @cache[name].has_key?(args)
    end
    klass.__send__(:define_method, "clear_#{name}") do |*args|
      @cache[name].delete(args)
    end
  end
end
