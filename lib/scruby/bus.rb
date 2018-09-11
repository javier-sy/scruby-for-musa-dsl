module Scruby
  module Bus
    attr_accessor :main_bus
    attr_reader :server, :channels

    def initialize server, channels = 1, main_bus = self, hardware_out = false
      @server, @channels, @main_bus, @hardware_out = server, channels, main_bus, hardware_out
    end
    
    # def audio_out?
    #   index < @server.instance_variable_get(:@opts)[:audio_outputs]
    # end

    def free
      @server.buses(rate).delete self
    end

    def index
      @server.buses(rate).index self
    end

    def rate; self.class::RATE end

    def self.included base
      base.extend ClassMethods
    end

    module ClassMethods
      def allocate_buses server, channels = 1
        buses = (1..channels).map{ new(server, channels) }
        buses.each { |bus| bus.main_bus = buses.first }
        server.allocate :"#{self::RATE}_buses", buses
        buses.first
      end
    end

    module Messaging
      def set *args
        args.flatten!
        message_args = []
        (index...channels).to_a.zip(args) do |chan, val|
          message_args.push(chan).push(val) if chan and val
        end
        if args.size > channels
          warn "You tried to set #{args.size} values for bus #{index} that only has #{channels} channels, extra values are ignored." 
        end
        @server.send '/c_set', *message_args
      end

      def fill value, channels = @channels
        if channels > @channels
          warn "You tried to set #{channels} values for bus #{index} that only has #{@channels} channels, extra values are ignored." 
        end
        @server.send '/c_fill', index, channels.min(@channels), value
      end
    end
  end

  class AudioBus
    include Bus
    RATE = :audio
  end

  class ControlBus
    include Bus
    RATE = :control

    def to_map; "c#{index}" end
  end
end
