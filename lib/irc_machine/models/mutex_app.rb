module IrcMachine
  module Models

    class MutexApp
      attr_reader :name, :last_user
      attr_accessor :deploy_url

      def initialize(name)
        @name = name
        @cache = { channel: "" }
        @deploying = false
        @last_user = "agent99"
        @last_state = :initial
        @deploy_lock = Mutex.new

        if block_given?
          yield self
        end
      end

      def deploy!(user, channel)
        # Reactor model, this is safe
        return "Deploy for #{name} in progress by #{last_user}" if @deploying

        @deploying = true
        @last_state = :deploying
        @last_user = user
        @cache[:channel] = channel

        uri = URI(deploy_url)
        Net::HTTP.get(uri)

        return "Deploy started for #{name}"
      end

      def succeed
        last_deploying = @deploying
        @last_state = :successful
        @deploying = false
        return last_deploying
      end

      def fail
        last_deploying = @deploying
        @last_state = :failure
        @deploying = false
        return last_deploying
      end

      def last_state
        @last_state.to_s
      end

      def last_channel
        @cache[:channel]
      end

      def deploying?
        @deploying
      end
    end

  end
end
