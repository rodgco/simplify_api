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
        type: type.class == Class ? type : (type.class == Array ? Array : Object),
        params: args
      }
      attributes[attr]
    end
  end

  def initialize(opts = {})
    opts.symbolize_keys!
    # opts = { klass_attr.first[0] => opts } if opts.class == Array
    klass_attr.each_pair do |name, spec|
      params = spec[:params]
      if opts.key?(name)
        value = process_value(name, opts[name])
        opts.delete(name)
      else
        value = params[:default]
      end
      raise ArgumentError, "Missing mandatory attribute => #{name}" if params[:mandatory] & value.nil?

      create_and_set_instance_variable(name.to_s, value)
    end

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
  #   Every other call will be passed to super.
  #
  def method_missing(method_name, *args, &block)
    case method_name
    when /(.*)\=$/
      create_and_set_instance_variable($1.to_s, args[0])
    else
      super(method_name, args, block)
    end
  end

  # respond_to_mssing?
  #   Called to check if an instance respond to a message.
  #
  #   It should respond to any assignment call.
  #   Every other type should be passed to super.
  #
  def respond_to_missing?(method_name, *args)
    case method_name
    when /(.*)\=$/
      true # always respond to assignment methods
    else
      super(method_name, args)
    end
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
