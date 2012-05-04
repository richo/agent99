module IrcMachine
  module Models

    class GithubCommit < OpenStruct

      def build_time
        (Time.now.to_i - start_time).to_s
      end

      def method_missing(sym, *args)
        # Make it the commit's problem
        self.commit.send(sym, *args)
      end

      def notification_format(build_status)
        "Build of #{commit.repo_name.irc_bold}/#{commit.branch.irc_bold} was a #{build_status} #{commit.repository.url}/compare/#{commit.before[0..6]}...#{commit.after[0..6]} in #{commit.build_time.irc_bold}s PING #{authors.join(" ")}"
      end

    end

  end
end
