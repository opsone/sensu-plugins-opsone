#!/usr/bin/env ruby
#
# This file was generated by Bundler.
#
# The application 'check-ftp-backup.rb' is installed as part of a gem, and
# this file is here to facilitate running it.
#

require "pathname"
path = Pathname.new(__FILE__)
$:.unshift File.expand_path "../../lib", path.realpath

require "bundler/setup"
load File.expand_path "../../lib/sensu-opsone-check/check-ftp-backup.rb", path.realpath
