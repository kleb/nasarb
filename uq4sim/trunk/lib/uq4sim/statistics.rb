module Uq4sim

  ##
  # Statistical methods to be used with numeric Arrays

  module Statistics

    def mean
      self.inject(0) { |sum, x| sum + x.to_f / self.size }
    end

    def median
      sorted = self.sort
      mid = sorted.size / 2
      sorted.size % 2 == 0 ? [ sorted[mid], sorted[mid-1] ].mean : sorted[mid]
    end

    def variance
      mean = self.mean
      self.inject(0) { |sum, x| sum + (x-mean)**2 } / self.size 
    end

    def standard_deviation
      Math::sqrt(self.variance)
    end

    def coefficient_of_variation
      mean = self.mean
      mean == 0 ? 0.0 : self.standard_deviation/mean
    end

    def skewness
      mean, variance = self.mean, self.variance
      variance == 0 ? 0.0 :
      self.inject(0) { |sum, x| sum + (x-mean)**3 } /
        self.size / variance**(3/2.0)
    end

    def kurtosis
      mean, variance = self.mean, self.variance
      variance == 0 ? 0.0 :
      self.inject(0) { |sum, x| sum + (x-mean)**4 } /
        self.size / variance**2
    end

    def percentile(percentage)
      self.sort[ (self.size-1)*percentage/100 + 0.5 ]
    end

    def histogram(num_of_bins=20)
      min, max = self.min, self.max
      bin_width = Float(max-min)/num_of_bins
      bins = []
      num_of_bins.times do
        bins << (min..min+bin_width)
        min += bin_width
      end
      histohash = {}
      bins.each{ |b| histohash[b]=0 }
      self.each do |e|
        bin = bins.find{ |b| b.include? e }
        bin = bins.last unless bin # round off
        histohash[ bin ] += 1
      end
      histohash.sort do |x,y|
        0.5*(x[0].begin+x[0].end) <=> 0.5*(y[0].begin+y[0].end)
      end
    end

    def within?(tolerance,options={})
      last_value = self.last
      max_difference = self.inject(0) do |max,value|
        difference = ( last_value - value ).abs
        max >= difference ? max : difference
      end
      scale = options[:percent] ? 100.0/last_value : 1
      scale = 0 if scale == 1.0/0
      max_difference * scale <= tolerance
    end

  end

end

# FIXME: monkey patch

class Array
  include Uq4sim::Statistics
end

##
# sample

if __FILE__ == $0 then
  require 'distributions'
  class Array; include Uq4sim::Statistics; end
  N = 10000
  samples = []
  (1..N).each{ |i| samples << randn(0.5) }
  puts "           samples: #{N}"
  puts "             range: #{samples.min}...#{samples.max}"
  puts "              mean: #{samples.mean}"
  puts "            median: #{samples.median}"
  puts "standard deviation: #{Math.sqrt(samples.variance)}"
  puts "          skewness: #{samples.skewness}"
  puts "          kurtosis: #{samples.kurtosis}"
  bins = Hash.new{ |h,k| h[k]=0 }
  samples.each{ |s| bins[((s*10).round/10.0).to_s] += 1 }
  bins.to_a.sort{ |x,y| x[0].to_f <=> y[0].to_f }.each do |pair|
   puts pair.first.to_s.rjust(4) + " " + "*" * ( pair.last.to_f * 800 / N )
  end
end
