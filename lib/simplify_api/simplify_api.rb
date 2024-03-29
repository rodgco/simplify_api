# frozen_string_literal: true

# SimplifyApi
module SimplifyApi
  def self.included(base)
    base.singleton_class.send(:attr_accessor, :attributes)
    base.attributes = {}
    base.extend(ClassMethods)
  end

  # ClassMethods
  module ClassMethods
    def attribute(attr, type = Object, **args)
      raise ArgumentError, "Duplicate attribute #{attr}." if attributes[attr]

      if type.class == Array
        args[:default] = [] unless args[:default]
        args[:array_type] = type[0]
      end

      args[:mandatory] ||= false
      args[:default] ||= nil unless args[:default].class == FalseClass

      attributes[attr] = {
        name: attr.to_s,
        type: { Class => type, Array => Array }[type.class] || Object,
        params: args
      }
      attr
    end
  end

  def initialize(opts = {})
    opts.symbolize_keys!

    opts.each_pair do |key, value|
      expanded_value = process_value(key, value)
      create_and_set_instance_variable(key.to_s, expanded_value)
    end
  end

  def to_h
    h = {}
    instance_variables.each do |i|
      k = /\@(.*)/.match(i.to_s)[1].to_sym
      v = instance_variable_get(i)
      if v.class == Array then
        r = []
        v.each { |a| r << (a.respond_to?(:to_h) ? a.to_h : a) }
        if klass_attr[k][:params][:invisible] then
          h = r
        else
          h[k] = r
        end
      else
        h[k] = v.respond_to?(:to_h) ? v.to_h : v
      end
    end
    return h
  end

  def to_json
    self.to_h.to_json
  end

  # method_missing
  #   Called in case an unexisting method is called.
  #
  #   To an assignment call it will create the instance variable.
  #   To an getter of a specified attribute, return the default value.
  #   Every other call will be passed to super.
  #
  def method_missing(method_name, *args, &block)
    if method_name.match(/(.*)\=$/)
      create_and_set_instance_variable($1.to_s, args[0])
    else
      return klass_attr.dig(method_name.to_sym, :params, :default) if klass_attr.key?(method_name.to_sym)

      super(method_name, args, block)
    end
  end

  # respond_to_mssing?
  #   Called to check if an instance respond to a message.
  #
  #   It should respond to any defined attribute (getter & setter).
  #   Every other type should be passed to super.
  #
  def respond_to_missing?(method_name, *args)
    return true if method_name.match(/(.*)\=$/)

    return true if klass_attr.key?(method_name.to_sym)

    super(method_name, args)
  end

  def valid?
    klass_attr.each_pair do |key, value|
      puts "Key: #{key}"
      return false if value.dig(:params, :mandatory) & !instance_variable_defined?("@#{key.to_s}".to_sym)
    end
    true
  end

  private

  def create_and_set_instance_variable(name, value)
    klass_attr[name.to_sym] = { name: name, type: value.class, params: { default: nil, mandatory: false }} unless klass_attr[name.to_sym]

    define_singleton_method("#{name}=") do |arg|
      raise ArgumentError, "Invalid value for #{name} => #{arg}" unless valid_value?(name, arg)

      instance_variable_set("@#{name}", arg)
    end

    define_singleton_method(name.to_s) do
      instance_variable_get("@#{name}")
    end

    send("#{name}=", value)
  end

  def valid_value?(name, value)
    return true if value.nil?
    return true unless klass_attr[name.to_sym][:params].key?(:values)

    valid_values = klass_attr[name.to_sym][:params][:values]
    return true if valid_values.include?(value)

    false
  end

  def process_value(key, value)
    case value
    when Hash
      value = klass_attr[key][:type].new(value)
    when Array
      value.collect! do |item|
        if klass_attr[key][:params].key?(:array_type)
          klass_attr[key][:params][:array_type].new(item)
        else
          item
        end
      end
    end
    value
  end

  def klass_attr
    self.class.attributes
  end
end
