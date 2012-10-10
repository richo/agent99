class IrcMachine::Plugin::ImageMe < IrcMachine::Plugin::Base
  def receive_line(line)
    if line =~ /^:\S+ PRIVMSG (#+\S+) :#{session.state.nick}:? who's on (?:the )? decks\?$/
      session.msg $1, plugin_send(:Notifier, :airplay_current_hostname)
    end
  end
end
