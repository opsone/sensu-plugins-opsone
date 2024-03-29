# sensu-opsone-check

This project contains several monitoring script for sensu-go. They can be found in `lib/sensu-opsone-check`.

## Installation

Asset definition
```
---
type: Asset
api_version: core/v2
metadata:
  name: sensu-plugins-opsone_debian_amd64
  labels:
  annotations:
spec:
  url: https://github.com/opsone/sensu-plugins-opsone/releases/download/v0.1.2/sensu-opsone-check-0.1.2.tar.gz
  sha512: 71ce4a02da957c6c8f14d5b5af020c55511ecece0373428e99326bac3a9544933682996c231c89c8e48e4324b288cb41d6187c5758f064e6c941f269a1709aef
  filters:
  - entity.system.os == 'linux'
  - entity.system.arch == 'amd64'
  - entity.system.platform_family == 'debian'
```


## Usage

### bin/check-ftp-backup

This plugin checks if a /var/archives files exists in a FTP folder and compare files sizes.

Options:

```
-D, --ftp-directory DIR_NAME     FTP directory
-d, --directory-name DIR_NAME    The name of directory to check
-h, --ftp-host HOST              FTP Hostname (required)
-p, --ftp-password PASS          FTP Password
-u, --ftp-user USER              FTP User
```

Check definition:

```
---
type: CheckConfig
metadata:
  name: check_ftp_backup
spec:
  command: check-ftp-backup.rb -h {{ index .labels "ftp_backup_hostname" }} -u {{ index .labels "ftp_backup_user" }} -p {{ index .labels "ftp_backup_password" }}
  handlers: [slack]
  high_flap_threshold: 0
  cron: '0 14 * * *'
  low_flap_threshold: 0
  publish: true
  runtime_assets:
  - sensu-plugins-opsone_debian_amd64
  - sensu-ruby-runtime_debian_amd64
  subscriptions:
  - ftp_backup
```

### bin/check-s3-backup

This plugin checks if a /var/archives files exists in a bucket and/or is not too old.

Options:

```
-a AWS_ACCESS_KEY,               AWS Access Key. Either set ENV['AWS_ACCESS_KEY'] or provide it as an option
    --aws-access-key
-e, --aws-endpoint ENDPOINT      AWS Endpoint (defaults to https://s3.eu-west-3.amazonaws.com).
-r, --aws-region REGION          AWS Region (defaults to eu-west-3).
-k AWS_SECRET_KEY,               AWS Secret Access Key. Either set ENV['AWS_SECRET_KEY'] or provide it as an option
    --aws-secret-access-key
-b, --bucket-name BUCKET_NAME    The name of the S3 bucket where object lives (required)
-d, --directory-name DIR_NAME    The name of directory to check
-u, --use-iam                    Use IAM role authenticiation. Instance must have IAM role assigned for this to work
```

Check definition:

```
---
type: CheckConfig
metadata:
  name: check_s3_backup
spec:
  command: check-s3-backup.rb -a {{ index .labels "s3_backup_access_key" }} -k {{ index .labels "s3_backup_secret_key" }} -b {{ index .labels "s3_backup_bucket" }} -e {{ index .labels "s3_backup_endpoint" }} -r {{ index .labels "s3_backup_region" }}
  handlers: [slack]
  high_flap_threshold: 0
  cron: '0 14 * * *'
  low_flap_threshold: 0
  publish: true
  runtime_assets:
  - sensu-plugins-opsone_debian_amd64
  - sensu-ruby-runtime_debian_amd64
  subscriptions:
  - s3_backup
```

## Compile it yourself

1. Clone this repository
2. Execute:

```
$ bundle install --standalone --binstubs ./bin
```

3. Manually correct load path in both `bin/check-ftp-backup.rb` and `bin/check-s3-backup.rb` from:

```
../../exe/check-[ftp|s3]-backup.rb
```
to:

```
../../lib/sensu-opsone-check/check-[ftp|s3]-backup.rb
```

4. Compress it

```
$ tar -C ./ -cvzf sensu-opsone-check-0.1.2.tar.gz .
```

5. Calculate checksum

```
$ shasum -a 512 sensu-opsone-check-0.1.2.tar.gz
```
