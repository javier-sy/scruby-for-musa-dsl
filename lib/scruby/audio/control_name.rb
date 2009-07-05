module Scruby
  module Audio
    class ControlName #:nodoc:
      attr_accessor :name, :value, :rate, :index
      RATES = { 'n_' => :noncontrol, 'i_' => :scalar, 'k_' => :control, 't_' => :trigger }

      def initialize name, value, rate, index
        @name, @value, @rate, @index = name.to_s, value.to_f, set_rate( name, rate ), index
      end

      def set_rate name, rate
        RATES.has_value?( rate ) ? rate : rate_from_name( name )
      end

      def rate_from_name name
        RATES[ name.to_s[0..1] ] || :control
      end

      def non_control?
        @rate == :noncontrol
      end
      
      def valid_ugen_input?
        true
      end
    end
  end
end