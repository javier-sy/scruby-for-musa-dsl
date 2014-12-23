class Proc
  def arguments
    self.parameters.map &:last
  end
  alias :value :call
end
