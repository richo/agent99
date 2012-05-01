module IrcMachine
  module Models

    class GithubCommit < OpenStruct

      def build_time
        (Time.now.to_i - start_time).to_s
      end

      def method_missing(sym, *args)
        # Make it the commit's problem:w
        self.commit.send(sym, *args)
      end

    end

  end
end
