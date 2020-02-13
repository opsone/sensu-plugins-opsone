#! /usr/bin/env ruby
#
# check-s3-backup
#
# DESCRIPTION:
#   This plugin checks if a /var/arvhives files exists in a bucket and/or is not too old.
#
# OUTPUT:
#   plain-text
#
# PLATFORMS:
#   Linux
#
# DEPENDENCIES:
#   gem: aws-sdk-s3
#   gem: sensu-plugin
#
# USAGE:
#   ./check-s3-backup.rb --bucket-name mybucket-backup --aws-region eu-central-1 --directory-name "/var/archives"
#
# NOTES:
#
# LICENSE:
#   Copyright (c) 2017, Kevyn Lebouille, kevyn.lebouille@opsone.net
#   Released under the same terms as Sensu (the MIT license); see LICENSE
#   for details.
#

require 'sensu-plugin/check/cli'
require 'aws-sdk-s3'

class CheckS3Backup < Sensu::Plugin::Check::CLI
  check_name 'check_s3_backup'

  option :aws_access_key,
         short: '-a AWS_ACCESS_KEY',
         long: '--aws-access-key AWS_ACCESS_KEY',
         description: "AWS Access Key. Either set ENV['AWS_ACCESS_KEY'] or provide it as an option",
         default: ENV['AWS_ACCESS_KEY']

  option :aws_secret_access_key,
         short: '-k AWS_SECRET_KEY',
         long: '--aws-secret-access-key AWS_SECRET_KEY',
         description: "AWS Secret Access Key. Either set ENV['AWS_SECRET_KEY'] or provide it as an option",
         default: ENV['AWS_SECRET_KEY']

  option :aws_region,
         short: '-r AWS_REGION',
         long: '--aws-region REGION',
         description: 'AWS Region (defaults to eu-west-3).',
         default: 'eu-west-3'

  option :aws_endpoint,
         short: '-e AWS_ENDPOINT',
         long: '--aws-endpoint ENDPOINT',
         description: 'AWS Endpoint (defaults to https://s3.eu-west-3.amazonaws.com).',
         default: 'https://s3.eu-west-3.amazonaws.com'

  option :use_iam_role,
         short: '-u',
         long: '--use-iam',
         description: 'Use IAM role authenticiation. Instance must have IAM role assigned for this to work'

  option :bucket_name,
         short: '-b BUCKET_NAME',
         long: '--bucket-name',
         description: 'The name of the S3 bucket where object lives',
         required: true

  option :directory_name,
         short: '-d DIR_NAME',
         long: '--directory-name',
         description: 'The name of directory to check',
         default: '/var/archives'

  def aws_config
    { access_key_id: config[:aws_access_key],
      secret_access_key: config[:aws_secret_access_key],
      region: config[:aws_region],
      endpoint: config[:aws_endpoint] }
  end

  def run
    s3 = Aws::S3::Client.new(aws_config)

    Dir.glob("#{config[:directory_name]}/*") do |file|
      next if File.extname(file) == '.md5'
      begin
        file_name = File.basename(file)
        file_size = File.size(file)

        output      = s3.head_object(bucket: config[:bucket_name], key: file_name)
        remote_size = output[:content_length]

        if file_size != remote_size
          critical "S3 object #{file_name} size: #{file_size} bytes (bucket #{remote_size})"
        end
      rescue Aws::S3::Errors::NotFound => _
        critical "S3 object #{file_name} not found in bucket #{config[:bucket_name]}"
      rescue => e
        critical "S3 object #{file_name} in bucket #{config[:bucket_name]} - #{e.message} - #{e.backtrace}"
      end
    end

    ok("All files in #{config[:directory_name]} exists in S3 bucket #{config[:bucket_name]}")
  end
end
