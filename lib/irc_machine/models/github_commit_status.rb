module IrcMachine
  module Models

    class GitHubCommitStatus
      VALID_STATUS = %w[pending success failure error]

      # Required options
      #
      # :user -> Github user owning the repo
      # :project -> Github project to create a status fetcher for
      #
      # Optional options
      #
      # :endpoint -> GitHub API endpoint.

      def self.from_project(proj)
        #                       vvv Accessor?
        new(:project => proj.repo,
            :user => proj

      def initialize(opts)
        @opts = default_opts.merge(opts)
        @status = Hash.new
      end

      def for_sha(sha)
        @status[sha] ||= get_status(sha)
      end

      def for_sha=(sha, status)
        raise InvalidStatus unless VALID_STATUS.include? status
        set_status sha, status
        @status[sha] = status
      end

      # def for_ref(ref)
      #   # TODO
      # end

      # def for_ref=(ref, status)
      #   # TODO
      # end

    private

      def get_status(sha)
      end

      def set_status(sha, status)
      end

      def default_opts
        { :endpoint => "https://api.github.com/v3" }
      end

      def request_url
        "#{opts[:endpoint]}/status/#{opts[:user]}/#{opts[:project]}"
      end

    end

  end
end
