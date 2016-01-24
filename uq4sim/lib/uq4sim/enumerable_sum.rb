module Enumerable
  
  ##
  # Shorthand function to sum elements
  def sum
    inject{ |sum,e| sum + e }
  end

end
