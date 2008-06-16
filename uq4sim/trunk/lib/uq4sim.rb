require 'yaml'
require 'fileutils'
require 'enumerator'

require 'uq4sim/fuzzy_string'
require 'uq4sim/report'
require 'uq4sim/correlation'
require 'uq4sim/statistics'

module Uq4sim
  
  include FileUtils

##
# This is the version of UQ4SIM you are running.
  VERSION = '1.0.0'

##
# Base error class for all UQ4SIM errors.
  class Error < RuntimeError; end

##
# Raised when you have mismatched correlation arrays.
  class CorrelationError < Error; end

##
# A Statistics struct to ease manipulation of sample distribution statistics.
  Struct.new( 'Statistics', :size, :min, :max, :mean, :median,
                            :standard_deviation, :skewness, :kurtosis )

  class Struct::Statistics
    def to_s
      self.entries.join ' '
    end
  end

##
# Load configuration from YAML file, making each parameter an instance variable.
  def load config_file
    YAML.load_file(config_file).each do |parameter,value|
      instance_variable_set( "@#{parameter}", value )
    end
  end

##
# Run the sensitivty analysis.
  def self.run( config_file='uq4sim.yml' )

    load_config config_file

    srand 1234 # set seed for (repeatable) pseudo-random numbers

    fuzzy_files, fuzzy_file = Dir['*.fzy'], {}

    inputs, input_vars, input_samples, outputs = {}, [], []

    outputs, correlations, statistics = {}, {}, []

    @link_files.map!{ |file| File.join pwd, @nominal, file }
    @copy_files.map!{ |file| File.join pwd, @nominal, file }

    report 'reading fzy files' do
      fuzzy_files.each do |file|
        fuzzy_file[file.chomp('.fzy')] = FuzzyString.new File.read(file)
        report_progress
      end
    end

    report 'start sampling' do
      rm_rf   @run_name # !! DANGEROUS !!
      mkdir_p @run_name
      cd      @run_name do
        label_width = @max_samples.to_s.size
        for sample_number in 1..@max_samples
          sample_dir = File.join( @run_name, 'sample' + sample_number.to_s.rjust(label_width,"0") )
          mkdir_p sample_dir
          ln_sf @link_files, sample_dir  unless @link_files.empty?
          cp    @copy_files, sample_dir  unless @copy_files.empty?
          cd sample_dir do
            report 'sample inputs' do
              fuzzy_files.each do |file,content|
                input_sample = content.sample
                File.open(file,'w'){ |f| f.puts input_sample }
                inputs.merge!(input_sample){ |key,old,new| old.concat(new) }
                report_progress
              end
            end
            report 'run sample' do
              system @run_recipe
            end
            report 'collect outputs' do
              @output_files.each do |file|
                output_sample = parse_output file # HOW?!
                outputs.merge!(output_sample){ |key,old,new| old.concat(new) }
                report_progress
              end
            end
            report 'compute statistics' do
              outputs.each do |variable, samples|
                statistics[variable] <<
                  Struct::Statistics.new(
                    samples.size,
                    samples.min, samples.max,
                    samples.mean, samples.median,
                    samples.standard_deviation,
                    samples.skewness, samples.kurtosis )
                report_progress
              end
            end
            report 'checking for statistical convergence' do ! FIXME
              num_of_samples, converged, percent_tolerance = 100, false, 0.1
              break if statistics.each do |variable,stats|
                break unless stats.size >= num_of_samples
                break unless stats.last(num_of_samples).within?(percent_tolerance,:percent=>true)
              end
            end
          end
        end
        report 'compute correlations' do
          outputs.each do |output_variable,output_samples|
            correlations[output_variable] = correlation(input_samples,[samples])[1]
            report_progress
          end
        end
        report 'save correlations' do
          File.open('correlations.yml','w'){ |file| YAML.dump(correlations,file) }
        end
        report 'save input samples' do
          fuzzy_file.each do |input_file,content|
            File.open(input_file+'.rbm','w'){ |file| Marshal.dump(inputs,file) }
            report_progress
          end
        end
        report 'save outputs samples' do
          @outputs.each do |output_file,content|
            File.open(output_file+'.rdm','w') { |file| Marshal.dump(outputs,file) }
            report_progress
          end
        end
        report 'save statistics history' do
          File.open('output_statistics_history.dat','w') do |file|
            file.puts "Title='Statistics History'"
            file.puts "Variables=samples min max mean median sigma skewness kurtosis"
            statistics.each do |variable, stats| # FIXME
              file.puts "Zone T='#{variable}'"
              stats.each{ |stat| file.puts stat }
              report_progress
            end
          end
        end
      end
    end
    
  end # def

end # module

#--
# Copyright 2007 United States Government as represented by
# NASA Langley Research Center. No copyright is claimed in
# the United States under Title 17, U.S. Code. All Other Rights
# Reserved.
#
# This file is governed by the NASA Open Source Agreement.
# See License.txt for details.
#++