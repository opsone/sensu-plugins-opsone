#! /usr/bin/env ruby
#
# check-ftp-backup
#
# DESCRIPTION:
#   This plugin checks if a /var/arvhives files exists in a FTP folder and files sizes.
#
# OUTPUT:
#   plain-text
#
# PLATFORMS:
#   Linux
#
#
# USAGE:
#   ./check-ftp-backup.rb --ftp-host ftphost --ftp-user ftplogin --ftp-password ftppasswd --directory-name "/var/archives"
#
# NOTES:
#
# LICENSE:
#   Copyright (c) 2017, Kevyn Lebouille, kevyn.lebouille@opsone.net
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/check/cli'
require 'net/ftp'

class CheckFtpBackup < Sensu::Plugin::Check::CLI
  check_name 'check_ftp_backup'

  option :ftp_user,
         short: '-u USER',
         long: '--ftp-user USER',
         description: 'FTP User'

  option :ftp_password,
         short: '-p PASS',
         long: '--ftp-password PASS',
         description: 'FTP Password'

  option :ftp_host,
         short: '-h HOST',
         long: '--ftp-host HOST',
         description: 'FTP Hostname',
         required: true

  option :directory_name,
         short: '-d DIR_NAME',
         long: '--directory-name',
         description: 'The name of directory to check',
         default: '/var/archives'

  def run
    ftp = Net::FTP.new config[:ftp_host]
    ftp.login config[:ftp_user], config[:ftp_password]
    ftp.binary = true

    Dir.glob("#{config[:directory_name]}/*") do |file|
      next if File.extname(file) == '.md5'

      file_name = File.basename(file)
      file_size = File.size(file)

      if ftp.ls(file_name).empty?
        critical "FTP file #{file_name} missing"
      elsif file_size != ftp.size(file_name)
        critical "FTP file #{file_name} size differ from original"
      end
    end

    ok("Files in #{config[:directory_name]} exists on FTP #{config[:ftp_host]}")
  rescue Net::FTPError => e
    critical "FTP exception - #{e.message} - #{e.backtrace}"
  ensure
    ftp.quit if ftp
  end
end
