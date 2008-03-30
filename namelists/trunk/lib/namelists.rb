class Namelists
  VERSION = '1.0.0'
  def initialize( contents )
    @contents = contents
  end
  def find_definitions
    strip_comments
    collapse_continuations
    raw = @contents.scan(/^\s*namelist\s*\/\s*(\w+)\s*\/\s*(.*?)$/)
    namelists = raw.inject({}) do |result,element|
      result[element.first] = element.last.split(/,\s*/)
      result
    end
  end
  # TODO: ignore exclamation characters in strings
  def strip_comments
    @contents = @contents.gsub(/\s*!.*$/,'').gsub(/^\n$/,'')
  end
  # TODO: ingore & in strings and handle & as leading character
  def collapse_continuations
    @contents = @contents.gsub(/\s*&.*?\n/,'')
  end
  def parse_description
    @contents.scan(/^\s*!\s*begin namelist \/(\w+)\/ description.*?\n(.*)!\s*end namelist \/\1\/ description/m)
  end
end
