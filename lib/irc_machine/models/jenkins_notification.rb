require "json"
require "cgi"
require "ostruct"

module IrcMachine
  module Models

    class JenkinsNotification

      attr_reader :data

      def initialize(body)
        json = CGI.parse(body)["payload"][0]
        @data = OpenStruct.new(JSON.parse(json))
      end

      def repo_name
        data.name
      end

      def url
        data.url
      end

      def status
        data.build["status"]
      end

      def phase
        data.build["phase"]
      end

      def parameters
        data.build["parameters"]
      end

    end

  end
end
