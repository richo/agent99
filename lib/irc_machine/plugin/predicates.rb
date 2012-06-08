class IrcMachine::Plugin::Predicates < IrcMachine::Plugin::Base
  PREDICATES = [
    [/^is.*\?/i, ["Yes", "No"]],
    [/^are.*\?/i, ["Yes", "No"]]
  ]

  def recieve_line(line)
    if line =~ /^:(\S+)!\S+ PRIVMSG (#+\S+) :(.*)$/
      msg, chan, nick = $3, $2, $1
      PREDICATES.each do |regex, choices|
        if msg =~ regex
          session.msg chan, "#{nick}: #{choices.sample}"
        end
      end
    end
  end
end
