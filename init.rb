# Include hook code here
require 'nested_discussions'

ActiveRecord::Base.send :include, ActiveRecord::Acts::Discussable
