module Scruby
  module Bus
    attr_accessor :main_bus
    attr_reader :server, :channels

    def initialize(server, channels = 1, main_bus: self, hardware_in: false, hardware_out: false)
      @server = server
      @channels = channels
      @main_bus = main_bus

      @hardware_in = hardware_in
      @hardware_out = hardware_out
    end

    def rate
      self.class::RATE
    end

    def audio_out?
      @hardware_out
    end

    def free
      @server.buses(rate).delete(self)
    end

    def index
      @server.buses(rate).index(self)
    end

    def set(*args)
      args.flatten!

      message_args = []
      (index...channels).to_a.zip(args) do |chan, val|
        message_args.push(chan).push(val) if chan && val
      end

      if args.size > channels
        warn "You tried to set #{args.size} values for bus #{index} that only has #{channels} channels, extra values are ignored."
      end

      @server.send '/c_set', *message_args
    end

    def fill(value, channels = @channels)
      if channels > @channels
        warn "You tried to set #{channels} values for bus #{index} that only has #{@channels} channels, extra values are ignored."
      end

      @server.send '/c_fill', index, channels.min(@channels), value
    end

    def self.included(base)
      base.extend ClassMethods
    end

    module ClassMethods
      def allocate(server, channels: 1, hardware_in: false, hardware_out: false)
        buses = (1..channels).map { new(server, channels, hardware_in: hardware_in, hardware_out: hardware_out) }
        first = buses.first

        buses.each { |bus| bus.main_bus = first }
        server.allocate "#{self::RATE}_buses".intern, *buses
        first
      end
    end
  end

  class AudioBus
    include Bus

    RATE = :audio

    def to_map
      raise SCError, 'Cannot use to_map on audio bus'
    end
  end

  class ControlBus
    include Bus

    RATE = :control

    def to_map
      "c#{index}"
    end
  end
end
