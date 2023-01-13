
lib = File.expand_path("../lib", __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "ecoji/version"

Gem::Specification.new do |spec|
  spec.name          = "ecoji"
  spec.version       = Ecoji::VERSION
  spec.authors       = ["TSUYUSATO Kitsune"]
  spec.email         = ["make.just.on@gmail.com"]

  spec.summary       = %q{Encodes (and decodes) data as emojis}
  spec.description   = %q{Ecoji encodes (and decodes) data as emojis. This library implements V1 and V2.}
  spec.homepage      = "https://github.com/makenowjust/ecoji.rb/"
  spec.license       = "MIT"

  if spec.respond_to?(:metadata)
    spec.metadata["homepage_uri"] = spec.homepage
    spec.metadata["source_code_uri"] = "https://github.com/makenowjust/ecoji.rb/"
    spec.metadata["changelog_uri"] = "https://github.com/makenowjust/ecoji.rb/blob/main/CHANGELOG.md"
  else
    raise "RubyGems 2.0 or newer is required to protect against " \
      "public gem pushes."
  end

  spec.files         = Dir.chdir(File.expand_path('..', __FILE__)) do
    `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(deps|test)/}) }
  end
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 2.4"
  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "minitest", "~> 5.17"
end
