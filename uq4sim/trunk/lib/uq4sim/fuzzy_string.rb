require 'uq4sim/distributions'
require 'scanf'

module Uq4sim
  
  class FuzzyString < String

    include Uq4sim

    FLOAT = '[-+0-9eE.]'

    # Note: `perldoc -q float` suggests
    #       /([-+]?)(?=\d|\.\d)\d*(\.\d*)?([Ee]([-+]?\d+))?/ 

    FUZZY_PATTERN = /(#{FLOAT}+)         # $1 : number
                     \s*\+\/-\s*
                     (#{FLOAT}+)         # $2 : tolerance
                     (%|o)?              # $3 : type of tolerance (optional)
                     (N|U)?              # $4 : distribution to use (opt)
                     (_(\d+[.]?\d*[#{Scanf::FormatString::SPECIFIERS}]))?
                                         # $6 : simplified format specifier (opt)
                     (\s*(["'])(.*?)\8)? # $9 : tag (funky stuff is "-matching)
                    /x

    attr_accessor :distribution, :fields

    def initialize( string, distribution=:randn )
      @distribution = distribution
      @fields = {}
      super(string)
    end

    def sample
      untagged_fields = 0
      gsub(FUZZY_PATTERN) do |match|
        set_distribution $4 if $4
        sample = compute_sample( $1.to_f, $2.to_f, $3 )
        record $9 || untagged_fields += 1, sample
        $6 ? sprintf("%#$6",sample) : sample
      end
    end

    def record( tag, sample )
      tag = "untagged_#{tag}"  if tag.is_a? Fixnum
      (@fields[tag] ||= []) << sample
    end

    def compute_sample( mean, tolerance, type )
      sigma = 0.5*tolerance
      case type
      when '%' then
        mean + send(@distribution,mean*sigma/100)
      when 'o' then
        if mean < 0 then
          -10**(Math.log10(-mean)+send(@distribution,sigma))
        elsif mean > 0
          10**(Math.log10(mean)+send(@distribution,sigma))
        else # necessary for Ruby < 1.8.6
          0
        end
      else
        mean + send(@distribution,sigma)
      end
    end

    def set_distribution( glyph )
      case glyph
      when 'U' then @distribution = :randu
      when 'N' then @distribution = :randn
      else
        raise "unknown distribution: >>#{glyph}<<"
      end
    end

    def fuzzies
      grep(FUZZY_PATTERN){$&}
    end

    def crisp
      gsub(FUZZY_PATTERN){$1}
    end

  end

end