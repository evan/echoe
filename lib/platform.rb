
module Gem

  # Overrides to support cross packaging, which Rubygems 0.9.5 doesn't do
  class Specification

    alias :old_validate :validate    
           
    PLATFORM_CROSS_TARGETS = ["aix", "cygwin", "darwin", "freebsd", "hpux", "java", "linux", "mingw", "mswin", "netbsdelf", "openbsd", "solaris", "test", "_platform"]
    
    def validate
      begin
        old_validate
      rescue Gem::InvalidSpecificationException
        if platform =~ /(#{PLATFORM_CROSS_TARGETS.join("|")})/i
          true
        else
          raise Gem::InvalidSpecificationException, "unknown packaging target #{platform}"
        end
      end
    end
    
  end
end
