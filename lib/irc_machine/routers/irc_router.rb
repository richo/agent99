class IrcMachine::Routers::IrcRouter

  def initialize
    reset!
    if block_given?
      yield self
    end
  end

  def reset!
    @routes = []
  end

  def route(pattern, &block)
    @routes[pattern] = block
  end

  def build_pattern(text)
    /^:(\S+)!\S+ PRIVMSG (#+\S+) :#{text}/
  end

  def hear(str, &block)
    route(build_pattern(str), block)
  end

  def respond(str, &block)
    # TODO Session handle?
    route(build_pattern("#{session.state.nick}:? #{str}"), block)
  end

  def process(line)
    @routes.each do |pattern, route|
      if match = pattern.match?(line)
        route.call(line, match)
      end
    end
  end

end
