class String
  def encode *args
    # FIXME: This is a gross hack to get around the fact that this monkey-patch breaks
    #   some pry internals. The monkey-patched implementation did not accept arguments,
    #   so this should suffice to differentiate:
    if args.any?
      self
    else
      [self.size & 255].pack('C*') + self[0..255]
    end
  end
end
