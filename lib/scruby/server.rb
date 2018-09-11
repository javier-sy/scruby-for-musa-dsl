require 'open3'

module Scruby 
  include OSC
  
  TrueClass.send :include, OSC::OSCArgument
  TrueClass.send(:define_method, :to_osc_type){ 1 }
  
  FalseClass.send :include, OSC::OSCArgument
  FalseClass.send(:define_method, :to_osc_type){ 0 }
  
  Hash.send :include, OSC::OSCArgument
  Hash.send :define_method, :to_osc_type do 
    self.to_a.collect{ |pair| pair.collect{ |a| OSC.coerce_argument a } }
  end

  Array.send(:include, OSC::OSCArgument)
  Array.send( :define_method, :to_osc_type) do
    Blob.new Message.new(*self).encode
  end

  class Server
    attr_reader :host, :port, :path, :buffers, :control_buses, :audio_buses
    # Initializes and registers a new Server instance and sets the host and port for it.
    # The server is a Ruby representation of scsynth which can be a local binary or a remote    
    # server already running.
    # Server class keeps an array with all the instantiated servers
    # 
    # For more info 
    #   $ man scsynth
    # 
    # @param [Hash] opts the options to create a message with.
    # @option opts [String] :path ('scsynt' if in PATH env variable otherwise '/Applications/SuperCollider/scsynth') scsynth binary path
    # @option opts [String] :host ('localhost') SuperCollider Server address
    # @option opts [Fixnum] :port (57111) TCP port
    # @option opts [Fixnum] :control_bus_count (4096) Number of buses for routing control data, indices start at 0
    # @option opts [Fixnum] :audio_bus_count (128) Number of audio Bus channels for hardware output and input and internal routing
    # @option opts [Fixnum] :audio_output_count (8) Reserved buses for hardware output, indices start at 0
    # @option opts [Fixnum] :audio_input_count (8) Reserved buses for hardware input, indices starting from the number of audio outputs
    # @option opts [Fixnum] :buffer_count (1024) Number of available sample buffers
    # 
    def initialize opts = {}
      @path               = opts.delete(:path) || (%x(which scsynth).empty? ? '/Applications/SuperCollider/scsynth' : 'scsynth')
      @host               = opts.delete(:host) || 'localhost'
      @port               = opts.delete(:port) || 57111

      @audio_output_count = opts.delete(:audio_output_count) || 8
      @audio_input_count  = opts.delete(:audio_input_count)  || 8
      @buffer_count       = opts.delete(:buffer_count)       || 1024
      @control_bus_count  = opts.delete(:control_bus_count)  || 4096
      @audio_bus_count    = opts.delete(:audio_bus_count)    || 128

      @buffers       = []
      @control_buses = []
      @audio_buses   = []

      @client        = Client.new port, host
      # Bus.audio self, @audio_output_count # register hardware buses
      # Bus.audio self, @audio_input_count
      self.class.all << self
    end

    # Boots the local binary of the scsynth forking a process, it will rise a SCError if the scsynth 
    # binary is not found in path. 
    # The default path can be overriden using Server.scsynt_path=('path')
    def boot
      raise SCError.new("scsyth already running on port #{port}") if running?

      ready, timeout = false, Time.now + 2
      @thread = Thread.new do
        Open3.popen3("#{@path} -u #{port}") do |stdin, stdout, stderr, thread|
          stdout.each_line do |line|
            puts line
            ready = true if line.include? "server ready"
          end
          stderr.each_line { |line| puts "\e[31m#{line.chop}\e[0m" }
        end
      end

      sleep 0.1 until Time.now > timeout || ready
      raise SCError.new("could not boot scsynth") unless running?

      send "/g_new", 1  # default group
      self   
    end

    def running?
      @thread && @thread.alive?
    end

    def stop
      send "/g_freeAll", 0
      send "/clearSched"
      send "/g_new", 1
    end
    alias :panic :stop

    # Sends the /quit OSC signal to the scsynth
    def quit
      Server.all.delete self
      send '/quit'
    end

    # Sends an OSC command or +Message+ to the scsyth server.
    # E.g. +server.send('/dumpOSC', 1)+
    def send message, *args
      message = Message.new message, *args unless Message === message or Bundle === message
      @client.send message
    end

    def send_bundle timestamp = nil, *messages
      send Bundle.new( timestamp, *messages.map{ |message| Message.new *message  } )
    end

    # Encodes and sends a SynthDef to the scsynth server
    def send_synth_def synth_def
      send Bundle.new( nil, Message.new('/d_recv', Blob.new(synth_def.encode), 0) )
    end

    # Allocates either buffer or bus indices, should be consecutive
    def allocate kind, *elements
      collection, max_size = 
        case kind
        when :buffers
          [buffers, @buffer_count]
        when :control_buses
          [control_buses, @control_bus_count]
        when :audio_buses
          [audio_buses, @audio_bus_count]
        end
      
      elements.flatten!

      raise SCError.new("No more indices available -- free some #{kind} before allocating.") if collection.compact.size + elements.size > max_size

      return collection.concat(elements) unless collection.index nil # just concat arrays if no nil item

      indices = []
      collection.each_with_index do |item, index|
        break if indices.size >= elements.size
        item.nil? ? indices.push(index) : indices.clear
      end

      case 
      when indices.size >= elements.size
        collection[indices.first, elements.size] = elements
      when collection.size + elements.size <= max_size
        collection.concat elements
      else
        raise SCError.new("No block of #{elements.size} consecutive #{kind} indices is available.")
      end
    end

    @@servers = []
    class << self
      # Returns an array with all the registered servers
      def all
        @@servers
      end

      # Clear the servers array
      def clear
        @@servers.clear
      end

      # Return a server corresponding to the specified index of the registered servers array
      def [] index
        @@servers[index]
      end

      # Set a server to the specified index of the registered servers array
      def []= index
        @@servers[index]
        @@servers.uniq!
      end
    end
  end

  class SCError < StandardError
  end
end
