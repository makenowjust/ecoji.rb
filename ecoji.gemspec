# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'ecoji/version'

Gem::Specification.new do |spec|
  spec.name          = 'ecoji'
  spec.version       = Ecoji::VERSION
  spec.authors       = ['TSUYUSATO Kitsune']
  spec.email         = ['make.just.on@gmail.com']

  spec.summary       = 'Ecoji implementation in Ruby'
  spec.description   = 'Ecoji is a data-to-emoji encoding scheme. This library provides the implementation of Ecoji in Ruby.'
  spec.homepage      = 'https://github.com/makenowjust/ecoji.rb/'
  spec.license       = 'MIT'

  if spec.respond_to?(:metadata)
    spec.metadata['homepage_uri'] = spec.homepage
    spec.metadata['source_code_uri'] = 'https://github.com/makenowjust/ecoji.rb/'
    spec.metadata['changelog_uri'] = 'https://github.com/makenowjust/ecoji.rb/blob/main/CHANGELOG.md'
  else
    raise 'RubyGems 2.0 or newer is required to protect against ' \
          'public gem pushes.'
  end

  spec.files = Dir.chdir(File.expand_path(__dir__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(dep|test)/}) }
  end
  spec.bindir        = 'exe'
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']
  spec.required_ruby_version = '3.2'

  spec.metadata['rubygems_mfa_required'] = 'true'

  spec.add_development_dependency 'bundler', '~> 2.4'
  spec.add_development_dependency 'minitest', '~> 5.17'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rubocop', '~> 1.43'
  spec.add_development_dependency 'rubocop-minitest', '~> 0.25'
  spec.add_development_dependency 'rubocop-rake', '~> 0.6'
end
