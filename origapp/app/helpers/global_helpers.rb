module Merb
  module GlobalHelpers
    include AuthenticationHelper
    # helpers defined here available to all views.  
    def debug(thing, tag = 'pre')
      %Q{<#{tag}>#{thing.to_yaml}</#{tag}>}
    end
  end
end
