module Scruby
  class Synth < Node
    attr_reader :name

    def initialize(name, servers)
      super servers
      @name = name.to_s
    end

    class << self
      def new(name, action: :head, target: nil, **args)
        case target
        when nil
          target_id, servers = 1, nil
        when Group
          target_id, servers = group.id, target.servers
        when Node
          target_id, servers = 1, target.servers
        else
          raise TypeError.new("expected #{ target } to kind of Node or nil")
        end

        synth = super name, servers
        synth.send '/s_new', synth.name, synth.id, Node::ACTIONS.index(action), target_id, args
        synth
      end

      def after(target, name, **args)
        new name, action: :after, target: target, **args
      end

      def before(target, name, **args)
        new name, action: :before, target: target, **args
      end

      def head(target, name, **args)
        new name, action: :head, target: target, **args
      end

      def tail(target, name, **args)
        new name, action: :tail, target: target, **args
      end

      def replace(target, name, **args)
        new name, action: :replace, target: target, **args
      end
    end
  end
end
