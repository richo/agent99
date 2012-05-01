module IrcMachine
  module Models

    class GithubCommit < OpenStruct

      def build_time
        (Time.now.to_i - start_time).to_s
      end


    end

  end
end
