class IrcMachine::Plugin::JokeDetector < IrcMachine::Plugin::Base

  def receive_line(line)
    if line =~ /^:\S+ PRIVMSG (#+\S+) :#{session.state.nick}:? rimshot$/
      rimshot
    elsif line =~ /^:\S+ PRIVMSG (#+\S+) :.*your mum$/
      rimshot
    end
  end

  def rimshot
    plugin_send(:Notifier, :notify, "rimshot")
  end

end
