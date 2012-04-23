# This is not a valid plugin, it can't be directly attached to an endpoint.
#
# I just couldn't work out where else this code belonged.
#
# Usage:
#  def initialize_jenkins_notifier
#    @notifier = JenkinsNotifier.new(@builds) do |endpoint|
#      endpoint.on :success do |commit, build|#{{{ Success
#        notify format_msg(commit, build)
#      end #}}}
#
#      endpoint.on :failure do |commit, build| #{{{ Failure
#        notify format_msg(commit, build)
#        notify "Jenkins output available at #{build.full_url}"
#      end #}}}
#    end
#  end
#
#  With subsequent calls to
#  @notifier.process([body of jenkins notification])
class IrcMachine::Plugin::JenkinsNotifier
  attr_reader :builds, :triggers
  def initialize(builds)
    @builds = builds
    @triggers = {}
    if block_given?
      yield self
    end
  end

  def on(sym, &block)
    triggers[sym] = block
  end

  def process(message)
    build = ::IrcMachine::Models::JenkinsNotification.new(message)

    if build.phase == "COMPLETED"
      if commit = @builds[build.parameters.ID.to_s]
        if block = triggers[build.status.downcase.to_sym]
          # TODO Bail on nil commit?
          block.call(commit, build)
        end
      else
        if block = triggers[:unknown]
          block.call(build)
        end
      end
    end
  end

  def endpoint
    lambda { |request, match| process(request.body.read) }
  end
end

