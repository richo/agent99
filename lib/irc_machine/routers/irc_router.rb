class IrcMachine::Routers::IrcRouter

  attr_reader :session
  def initialize(session)
    @session = session
    flush_routes!
    if block_given?
      yield self
    end
  end

  def on(partial, opts={}, &block)
    @routes << OpenStruct.new({partial: partial, opts: default_opts.merge(opts),
                               block: block})
    # Can't compile string regexes here, nick may change
  end

  def dispatch(line)
    @routes.each do |route|
      case route.partial
      when String
        if match = build_pattern(route.partial).match(line)
          route.block.call(line, match)
        end
      when Regexp
        if match = route.partial.match(line)
          puts "#{route.partial} matched #{line}"
          route.block.call(line, match)
        end
      end
    end
  end

private

  def flush_routes!
    @routes = Array.new
  end

  def default_opts
    # Stub
    {}
  end

  def routes
    @routes
  end

  # FIXME Still consider this being a property of a model
  def build_pattern(text)
    /^:(\S+)!\S+ PRIVMSG (#+\S+) :#{session.state.nick}:? #{text}$/
  end

end



