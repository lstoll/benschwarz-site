# DO NOT MODIFY THIS FILE

require 'digest/sha1'
require "rubygems"

module Gem
  class Dependency
    if !instance_methods.map { |m| m.to_s }.include?("requirement")
      def requirement
        version_requirements
      end
    end
  end
end

module Bundler
  module SharedHelpers

    def default_gemfile
      gemfile = find_gemfile
      gemfile or raise GemfileNotFound, "The default Gemfile was not found"
      Pathname.new(gemfile)
    end

    def in_bundle?
      find_gemfile
    end

  private

    def find_gemfile
      return ENV['BUNDLE_GEMFILE'] if ENV['BUNDLE_GEMFILE']

      previous = nil
      current  = File.expand_path(Dir.pwd)

      until !File.directory?(current) || current == previous
        filename = File.join(current, 'Gemfile')
        return filename if File.file?(filename)
        current, previous = File.expand_path("..", current), current
      end
    end

    def clean_load_path
      # handle 1.9 where system gems are always on the load path
      if defined?(::Gem)
        me = File.expand_path("../../", __FILE__)
        $LOAD_PATH.reject! do |p|
          next if File.expand_path(p).include?(me)
          p != File.dirname(__FILE__) &&
            Gem.path.any? { |gp| p.include?(gp) }
        end
        $LOAD_PATH.uniq!
      end
    end

    def reverse_rubygems_kernel_mixin
      # Disable rubygems' gem activation system
      ::Kernel.class_eval do
        if private_method_defined?(:gem_original_require)
          alias rubygems_require require
          alias require gem_original_require
        end

        undef gem
      end
    end

    def cripple_rubygems(specs)
      reverse_rubygems_kernel_mixin

      executables = specs.map { |s| s.executables }.flatten

     :: Kernel.class_eval do
        private
        def gem(*) ; end
      end
      Gem.source_index # ensure RubyGems is fully loaded

      ::Kernel.send(:define_method, :gem) do |dep, *reqs|
        if executables.include? File.basename(caller.first.split(':').first)
          return
        end
        opts = reqs.last.is_a?(Hash) ? reqs.pop : {}

        unless dep.respond_to?(:name) && dep.respond_to?(:requirement)
          dep = Gem::Dependency.new(dep, reqs)
        end

        spec = specs.find  { |s| s.name == dep.name }

        if spec.nil?
          e = Gem::LoadError.new "#{dep.name} is not part of the bundle. Add it to Gemfile."
          e.name = dep.name
          e.version_requirement = dep.requirement
          raise e
        elsif dep !~ spec
          e = Gem::LoadError.new "can't activate #{dep}, already activated #{spec.full_name}. " \
                                 "Make sure all dependencies are added to Gemfile."
          e.name = dep.name
          e.version_requirement = dep.requirement
          raise e
        end

        true
      end

      # === Following hacks are to improve on the generated bin wrappers ===

      # Yeah, talk about a hack
      source_index_class = (class << Gem::SourceIndex ; self ; end)
      source_index_class.send(:define_method, :from_gems_in) do |*args|
        source_index = Gem::SourceIndex.new
        source_index.spec_dirs = *args
        source_index.add_specs(*specs)
        source_index
      end

      # OMG more hacks
      gem_class = (class << Gem ; self ; end)
      gem_class.send(:define_method, :bin_path) do |name, *args|
        exec_name, *reqs = args

        spec = nil

        if exec_name
          spec = specs.find { |s| s.executables.include?(exec_name) }
          spec or raise Gem::Exception, "can't find executable #{exec_name}"
        else
          spec = specs.find  { |s| s.name == name }
          exec_name = spec.default_executable or raise Gem::Exception, "no default executable for #{spec.full_name}"
        end

        File.join(spec.full_gem_path, spec.bindir, exec_name)
      end
    end

    extend self
  end
end

module Bundler
  LOCKED_BY    = '0.9.9'
  FINGERPRINT  = "94333e9a8c4a42b9eadf3e579e533c649f1e310b"
  AUTOREQUIRES = {:default=>[["rdiscount", true], ["sinatra/base", true], ["thin", false], ["less", true], ["haml", true], ["tilt", true], ["smoke", true]]}
  SPECS        = [
        {:loaded_from=>"/Users/ben/.gem/ruby/1.8/specifications/nokogiri-1.3.2.gemspec", :load_paths=>["/Users/ben/.gem/ruby/1.8/gems/nokogiri-1.3.2/lib", "/Users/ben/.gem/ruby/1.8/gems/nokogiri-1.3.2/ext"]},
        {:loaded_from=>"/Users/ben/.gem/ruby/1.8/specifications/rdiscount-1.5.8.gemspec", :load_paths=>["/Users/ben/.gem/ruby/1.8/gems/rdiscount-1.5.8/lib"]},
        {:loaded_from=>"/Users/ben/.gem/ruby/1.8/specifications/daemons-1.0.10.gemspec", :load_paths=>["/Users/ben/.gem/ruby/1.8/gems/daemons-1.0.10/lib"]},
        {:loaded_from=>"/Users/ben/.gem/ruby/1.8/specifications/registry-0.1.2.gemspec", :load_paths=>["/Users/ben/.gem/ruby/1.8/gems/registry-0.1.2/lib"]},
        {:loaded_from=>"/Users/ben/.gem/ruby/1.8/specifications/eventmachine-0.12.10.gemspec", :load_paths=>["/Users/ben/.gem/ruby/1.8/gems/eventmachine-0.12.10/lib"]},
        {:loaded_from=>"/Users/ben/.gem/ruby/1.8/specifications/rest-client-1.0.3.gemspec", :load_paths=>["/Users/ben/.gem/ruby/1.8/gems/rest-client-1.0.3/lib"]},
        {:loaded_from=>"/Users/ben/.gem/ruby/1.8/specifications/moneta-0.6.0.gemspec", :load_paths=>["/Users/ben/.gem/ruby/1.8/gems/moneta-0.6.0/lib"]},
        {:loaded_from=>"/Users/ben/.bundle/ruby/1.8/specifications/json-1.2.2.gemspec", :load_paths=>["/Users/ben/.bundle/ruby/1.8/gems/json-1.2.2/ext/json/ext", "/Users/ben/.bundle/ruby/1.8/gems/json-1.2.2/ext", "/Users/ben/.bundle/ruby/1.8/gems/json-1.2.2/lib"]},
        {:loaded_from=>"/Users/ben/.gem/ruby/1.8/specifications/rack-1.1.0.gemspec", :load_paths=>["/Users/ben/.gem/ruby/1.8/gems/rack-1.1.0/lib"]},
        {:loaded_from=>"/Users/ben/.bundle/ruby/1.8/specifications/sinatra-0.9.5.gemspec", :load_paths=>["/Users/ben/.bundle/ruby/1.8/gems/sinatra-0.9.5/lib"]},
        {:loaded_from=>"/Users/ben/.bundle/ruby/1.8/specifications/thin-1.2.7.gemspec", :load_paths=>["/Users/ben/.bundle/ruby/1.8/gems/thin-1.2.7/lib"]},
        {:loaded_from=>"/Users/ben/.gem/ruby/1.8/specifications/simple-rss-1.2.gemspec", :load_paths=>["/Users/ben/.gem/ruby/1.8/gems/simple-rss-1.2/lib"]},
        {:loaded_from=>"/Users/ben/.bundle/ruby/1.8/specifications/crack-0.1.7.gemspec", :load_paths=>["/Users/ben/.bundle/ruby/1.8/gems/crack-0.1.7/lib"]},
        {:loaded_from=>"/Users/ben/.bundle/ruby/1.8/specifications/mutter-0.5.3.gemspec", :load_paths=>["/Users/ben/.bundle/ruby/1.8/gems/mutter-0.5.3/lib"]},
        {:loaded_from=>"/Users/ben/.gem/ruby/1.8/specifications/polyglot-0.3.0.gemspec", :load_paths=>["/Users/ben/.gem/ruby/1.8/gems/polyglot-0.3.0/lib"]},
        {:loaded_from=>"/Users/ben/.bundle/ruby/1.8/specifications/treetop-1.4.4.gemspec", :load_paths=>["/Users/ben/.bundle/ruby/1.8/gems/treetop-1.4.4/lib"]},
        {:loaded_from=>"/Users/ben/.bundle/ruby/1.8/specifications/less-1.2.21.gemspec", :load_paths=>["/Users/ben/.bundle/ruby/1.8/gems/less-1.2.21/lib"]},
        {:loaded_from=>"/Users/ben/.bundle/ruby/1.8/specifications/haml-2.2.20.gemspec", :load_paths=>["/Users/ben/.bundle/ruby/1.8/gems/haml-2.2.20/lib"]},
        {:loaded_from=>"/Users/ben/.bundle/ruby/1.8/specifications/tilt-0.7.gemspec", :load_paths=>["/Users/ben/.bundle/ruby/1.8/gems/tilt-0.7/lib"]},
        {:loaded_from=>"/Users/ben/.gem/ruby/1.8/specifications/fastercsv-1.5.1.gemspec", :load_paths=>["/Users/ben/.gem/ruby/1.8/gems/fastercsv-1.5.1/lib"]},
        {:loaded_from=>"/Users/ben/.gem/ruby/1.8/specifications/smoke-0.5.20.gemspec", :load_paths=>["/Users/ben/.gem/ruby/1.8/gems/smoke-0.5.20/lib"]},
      ].map do |hash|
    spec = eval(File.read(hash[:loaded_from]), binding, hash[:loaded_from])
    spec.loaded_from = hash[:loaded_from]
    spec.require_paths = hash[:load_paths]
    spec
  end

  extend SharedHelpers

  def self.match_fingerprint
    print = Digest::SHA1.hexdigest(File.read(File.expand_path('../../Gemfile', __FILE__)))
    unless print == FINGERPRINT
      abort 'Gemfile changed since you last locked. Please `bundle lock` to relock.'
    end
  end

  def self.setup(*groups)
    match_fingerprint
    clean_load_path
    cripple_rubygems(SPECS)
    SPECS.each do |spec|
      Gem.loaded_specs[spec.name] = spec
      $LOAD_PATH.unshift(*spec.require_paths)
    end
  end

  def self.require(*groups)
    groups = [:default] if groups.empty?
    groups.each do |group|
      (AUTOREQUIRES[group] || []).each do |file, explicit|
        if explicit
          Kernel.require file
        else
          begin
            Kernel.require file
          rescue LoadError
          end
        end
      end
    end
  end

  # Setup bundle when it's required.
  setup
end