require 'net/http'
require 'json'
class IrcMachine::Models::JuiciProject

  attr_reader :config, :name

  def initialize(name, config)
    @name = name
    @config = config || {}
  end

  def build_script
    config["build_script"] || <<-EOS #{{{
#!/bin/sh
#
if [ ! -d .git ]; then
  git init .
  git remote add origin https://github.com/#{name}.git
fi
git fetch origin

git checkout -fq $SHA1

./script/cibuild
EOS
#}}}
  end

  def build_payload(opts={})
    URI.encode_www_form({ #{{{
      "project" => name,
      "environment" => (opts[:environment] || {}).to_json,
      "command" => build_script,
      "priority" => opts[:priority] || 1,
      "callbacks" => (opts[:callbacks] || []).to_json,
      "title" => opts[:title]
    }) #}}}
  end

  def priorities
    @priorities ||= Priorities.new(config["priorities"] || {})
  end

  class Priorities
    def initialize(pties)
      @strings = {}
      @patterns = {}
      load_priorities(pties)
    end

    def [](k)
      if match = @strings[k]
        return match
      end

      @patterns.each do |ptn, value|
        return value if k =~ ptn
      end

      return nil
    end

  private

    def load_priorities(pties)
      pties.each do |k, v|
        if k.start_with?("/") && k.end_with?("/")
          @patterns[/#{k[1..-2]}/] = v
        else
          @strings[k] = v
        end
      end
    end

  end
end
