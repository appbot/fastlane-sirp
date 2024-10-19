# encoding: utf-8

# coveralls.io and coco are incompatible. Run each in their own env.
if ENV['TRAVIS'] || ENV['CI'] || ENV['JENKINS_URL'] || ENV['TDDIUM'] || ENV['COVERALLS_RUN_LOCALLY']
  # coveralls.io : web based code coverage
  require 'coveralls'
  Coveralls.wear!
else
  # coco : local code coverage
  require 'fileutils'
  require 'coco'
end

require 'fastlane-sirp'

# Monkey-patch Client and Verifier classes for testing convenience
module SIRP
  class Verifier
    def set_aa(val)
      @A = val
    end

    def set_b(val)
      @b = val
    end

    def set_salt(val)
      @salt = val
    end
  end
end

module SIRP
  class Client
    def set_a(val)
      @a = val
    end

    def set_h_amk(val)
      @H_AMK = val
    end
  end
end
