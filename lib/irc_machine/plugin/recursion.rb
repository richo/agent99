class IrcMachine::Plugin::Recursion < IrcMachine::Plugin::Base

  def initialize(*args)
    @config = load_config
    super(*args)
  end

  def load_config
    JSON.load(open(File.expand_path("recursion.json"))).symbolize_keys
  end

  def receive_line(line)
    @config[:triggers].each do |k, v|
      if line =~ /^:(\S+)!\S+ PRIVMSG (#+\S+) :.*#{v}/i
        `#{v}`
      end
    end
  end

end
