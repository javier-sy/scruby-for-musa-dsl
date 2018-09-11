class Proc
  def arguments
    self.parameters.map { |_, name| name }
  end
  alias :value :call
end
