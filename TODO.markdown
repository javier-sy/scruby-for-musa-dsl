# Array workarounds

* Buffer as Ugen input 

# general constants under the `Scruby` module

* `scruby` is currently set to work at La/A 440. This is not good enough for
  professional usage. We need the `Scruby.tuning` variable which may be
  changed for proper tuning. It may be done with the following code:
  ```ruby
  module Scruby
    class << self
      attr_accessor :tuning
    end
  end
  ```
