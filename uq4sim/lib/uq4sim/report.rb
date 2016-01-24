module Uq4sim

  def report message, ios=$stdout, &block
    ios.print message
    ios.flush
    yield
    ios.puts 'complete.'
    ios.flush
  end

  def report_progress glyph='.', ios=$stdout
    ios.print glyph
    ios.flush
  end

end