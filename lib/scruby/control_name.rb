module Scruby
  class ControlName #:nodoc:
    attr_accessor :name, :value, :rate, :index
    RATES = { 'n_' => :noncontrol, 'i_' => :scalar, 'k_' => :control, 't_' => :trigger }.freeze

    def initialize(name, value, rate, index)
      @name = name.to_s
      @value = value.to_f
      @rate = set_rate(name, rate)
      @index = index
    end

    def set_rate(name, rate)
      RATES.has_value?(rate) ? rate : rate_from_name(name)
    end

    def rate_from_name(name)
      RATES[ name.to_s[0..1] ] || :control
    end

    def non_control?
      @rate == :noncontrol
    end

    def ==(other)
      @name == other.name &&
        @value == other.value &&
        @rate == other.rate &&
        @index == other.index
    end
  end
end
