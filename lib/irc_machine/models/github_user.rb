module IrcMachine
  module Models

    class GithubUser < OpenStruct
      @@nicks = Hash.new
      class << self
        def nicks=(mapping)
          @@nicks = mapping
        end

        def get_nick(nick)
          @@nicks[nick] || nick
        end
      end

      # Wrapper class that does a lookup based on usernames at init time
      attr_accessor :nick
      def intialize
        super
        nick = self.class.get_nick(username)
      end

      def to_s
        nick
      end
    end

  end
end
