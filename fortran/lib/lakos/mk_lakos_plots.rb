#!/usr/bin/env ruby

CODES = %w[ Adapt Design Adjoint FUN3D_90 GetGrad GridMove Party PartyMPI ]

require 'fileutils'

FileUtils.rm_rf 'Lakos' if File.exist? 'Lakos'
Dir.mkdir 'Lakos'

File.open('Lakos/index.html','w') do |index|

 index.puts "<h1> Lakos-Style Physical Dependency Analysis</h1>"
 index.puts "<p>This snapshot brought to you by #$0.</p>"
 index.puts "<p>Started: #{Time.now}.</p>"
 index.puts "<ul>"

 CODES.each do |code|
  puts "#{code}"
  puts "=" * code.length
  Dir.chdir code
  if system '../Ruby/CASE_tools/analyze_dependencies.rb'# add main.?90
   FileUtils.mv 'Lakos', "../Lakos/#{code}", {:force=>true}
   index.puts "<li><a href='#{code}/index.html'>#{code}</a></li>"
  else
   $stderr.puts "Failed to make dependency plots for #{code}."
  end
  Dir.chdir '..'
  puts
 end

 index.puts "</ul>"
 index.puts "<p>Completed: #{Time.now}.</p>"

end

FileUtils.rm_rf '/var/www/html/HEFSS/Lakos' if File.exist? '/var/www/html/HEFSS/Lakos'
FileUtils.cp_r 'Lakos', '/var/www/html/HEFSS'
