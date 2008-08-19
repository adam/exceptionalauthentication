$TESTING=true
$:.push File.join(File.dirname(__FILE__), '..', 'lib')

require 'rubygems'
require 'merb-core'
require 'merb-core/dispatch/session/cookie'
require 'spec' # Satisfies Autotest and anyone else not using the Rake tasks

require 'mauth-core'

Merb.start :environment => "test", :adapter => "runner"