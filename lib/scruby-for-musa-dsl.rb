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

require_relative 'scruby-for-musa-dsl/version'

require_relative 'scruby-for-musa-dsl/core_ext/object'
require_relative 'scruby-for-musa-dsl/core_ext/array'
require_relative 'scruby-for-musa-dsl/core_ext/integer'
require_relative 'scruby-for-musa-dsl/core_ext/numeric'
require_relative 'scruby-for-musa-dsl/core_ext/proc'
require_relative 'scruby-for-musa-dsl/core_ext/string'
require_relative 'scruby-for-musa-dsl/core_ext/symbol'
require_relative 'scruby-for-musa-dsl/core_ext/typed_array'
require_relative 'scruby-for-musa-dsl/core_ext/delegator_array'

require_relative 'scruby-for-musa-dsl/env'
require_relative 'scruby-for-musa-dsl/control_name'

require_relative 'scruby-for-musa-dsl/ugens/ugen'
require_relative 'scruby-for-musa-dsl/ugens/ugen_operations'
require_relative 'scruby-for-musa-dsl/ugens/multi_out'
require_relative 'scruby-for-musa-dsl/ugens/panner'
require_relative 'scruby-for-musa-dsl/ugens/buffer_read_write'
require_relative 'scruby-for-musa-dsl/ugens/disk_in_out'
require_relative 'scruby-for-musa-dsl/ugens/in_out'

require_relative 'scruby-for-musa-dsl/ugens/operation_ugens'

require_relative 'scruby-for-musa-dsl/ugens/ugens'
require_relative 'scruby-for-musa-dsl/synthdef'

require_relative 'scruby-for-musa-dsl/server'
require_relative 'scruby-for-musa-dsl/ugens/env_gen'

require_relative 'scruby-for-musa-dsl/node'
require_relative 'scruby-for-musa-dsl/synth'
require_relative 'scruby-for-musa-dsl/bus'
require_relative 'scruby-for-musa-dsl/buffer'
require_relative 'scruby-for-musa-dsl/group'

include Scruby4MusaDSL
include Ugens
