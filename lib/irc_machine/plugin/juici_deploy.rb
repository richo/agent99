require 'net/http'

class IrcMachine::Plugin::JenkinsNotify < IrcMachine::Plugin::Base

  CONFIG_FILE = "juici_deploy.json"

  def build_pass(commit, project, callback)

  end

  def build_fail(commit, project, callback)

  end

  def deploy_project_from(commit)

  end

end
