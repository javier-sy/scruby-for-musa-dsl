#--
# Copyright (c) 2008 Macario Ortega
# Copyright (c) 2019 modifications by Javier Sánchez Yeste
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#++

require 'date'
require 'ruby-osc'
require 'yaml'

#
# This a proper option initialization for whoever is using jack in a normal
# (laptop) configuration. You may reset the variable to your taste.
#
ENV['SC_JACK_DEFAULT_OUTPUTS'] = 'system' unless ENV.keys.include?('SC_JACK_DEFAULT_OUTPUTS')

require_relative 'scruby/version'

require_relative 'scruby/core_ext/object'
require_relative 'scruby/core_ext/array'
require_relative 'scruby/core_ext/integer'
require_relative 'scruby/core_ext/numeric'
require_relative 'scruby/core_ext/proc'
require_relative 'scruby/core_ext/string'
require_relative 'scruby/core_ext/symbol'
require_relative 'scruby/core_ext/typed_array'
require_relative 'scruby/core_ext/delegator_array'

require_relative 'scruby/env'
require_relative 'scruby/control_name'

require_relative 'scruby/ugens/ugen'
require_relative 'scruby/ugens/ugen_operations'
require_relative 'scruby/ugens/multi_out'
require_relative 'scruby/ugens/panner'
require_relative 'scruby/ugens/buffer_read_write'
require_relative 'scruby/ugens/disk_in_out'
require_relative 'scruby/ugens/in_out'

require_relative 'scruby/ugens/operation_ugens'

require_relative 'scruby/ugens/ugens'
require_relative 'scruby/synthdef'

require_relative 'scruby/server'
require_relative 'scruby/ugens/env_gen'

require_relative 'scruby/node'
require_relative 'scruby/synth'
require_relative 'scruby/bus'
require_relative 'scruby/buffer'
require_relative 'scruby/group'

include Scruby
include Ugens
