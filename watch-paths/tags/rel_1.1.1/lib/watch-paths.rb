require 'yaml'
require 'fileutils'
require 'digest/md5'

include FileUtils

$r ||= false

##
# A poor man's configuration management tool.

class WatchPaths

  VERSION = '1.1.1'

  ##
  # File used to record checksums in each path scanned

  MANIFEST = '.chksum_manifest.yml'

  ##
  # compares file checksums for a set of directory paths

  def watch( paths )
    chksum_errors = {}
    paths.map!{ |path| Dir["#{path}/**/*"] }.flatten! if $r
    dirs = paths.select{ |path| File.directory? path }
    dirs.each do |dir|
      cd dir do
        begin
          chksum_manifest = load
          chksum_manifest = check chksum_manifest
          dump chksum_manifest
        rescue ChecksumError => error
          chksum_errors[dir] = error.message
        end
      end
    end
    chksum_errors
  end

  ##
  # Attempts to load checksum manifest YAML file,
  # otherwise returns an empty hash.

  def load
    YAML.load_file MANIFEST rescue {}
  end

  ##
  # Write YAML file containing checksum manifest

  def dump( chksum_manifest )
    File.open(MANIFEST,'w') { |f| YAML.dump chksum_manifest, f }
  end

  ##
  # Create a checksum manifest of files in current directory

  def create_chksum_manifest
    chksum_manifest = {}
    files = Dir['*'].select{ |f| File.file? f }
    files.each do |file|
      chksum_manifest[file] = Digest::MD5.hexdigest File.read(file)
    end
    chksum_manifest
  end

  ##
  # Check old manifest against the current state.

  def check( chksum_manifest )
    new_chksum_manifest = create_chksum_manifest
    changed = []
    chksum_manifest.each do |file,chksum|
      changed << file  if chksum != new_chksum_manifest[file]
    end
    if changed.empty?
      chksum_manifest = new_chksum_manifest
    else
      raise ChecksumError, changed
    end
  end

end

##
# Expection used to report checksum mismatches

class ChecksumError < RuntimeError; end
