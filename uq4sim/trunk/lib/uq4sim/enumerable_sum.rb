module Enumerable # FIXME: refactor away this monkey patch
  
  ##
  # shorthand function to sum elements
  
  def sum
    inject{ |sum,e| sum + e }
  end

end
