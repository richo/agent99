require 'juici/interface'

class IrcMachine::Plugin::JuiciDeploy < IrcMachine::Plugin::Base
  include IrcMachine::CallbackUrlGenerator
  CONFIG_FILE = "github_juici.json"

  # Public method, to be called with plugin_send
  def deploy_callback_url(project, commit)
    callback = new_callback
    route(:post, callback[:path], lambda { |request, match|
      payload = ::IrcMachine::Models::JuiciNotification.new(request.body.read, :juici_url => juici_url)
      case payload.status
      when Juici::BuildStatus::FAIL
        deploy!(project)
      when Juici::BuildStatus::PASS
        disable!(project)
      end
    })
    callback[:url]
  end

  def callback_path
    '/juici/deploy'
  end

  def deploy!
    # TODO
  end

  def disable!
    # TODO
  end

end
