lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)

require_relative 'lib/sensu-opsone-check/version'

Gem::Specification.new do |spec|
  spec.name          = 'sensu-opsone-check'
  spec.version       = Sensu::Opsone::Check::VERSION
  spec.authors       = ['leon.baudouin']
  spec.email         = ['leon.baudouin@opsone.net']

  spec.executables   = Dir.glob('bin/**/*.rb').map { |file| File.basename(file) }
  spec.summary       = 'Sensu custom check by Opsone for backup'
  # spec.description   = %q{TODO: Write a longer description or delete this line.}
  spec.homepage      = 'https://opsone.net'
  spec.required_ruby_version = Gem::Requirement.new('>= 2.4.0')

  spec.metadata['allowed_push_host'] = "TODO: Set to 'http://mygemserver.com'"

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = "TODO: Put your gem's public repo URL here."
  spec.metadata['changelog_uri'] = "TODO: Put your gem's CHANGELOG.md URL here."

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_runtime_dependency 'aws-sdk-s3', '~> 1'
  spec.add_runtime_dependency 'sensu-plugin', '~> 4.0'

  spec.add_development_dependency 'bundler', '~> 2.1'
  spec.add_development_dependency 'rubocop', '~> 0.51.0'
  spec.add_development_dependency 'rake', '~> 13.0'
end
