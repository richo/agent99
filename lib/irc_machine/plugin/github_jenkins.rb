require 'net/http'
# * Configuration
# Project needs to be configured in jenkins with two parameters:
# - SHA1 : Takes a sha hash to build
# - ID   : Takes unique ID, purely for passing back to work out which build it
#          was that we're looking at
#
# Then configuration in the .json file is
# - {
#     "reponame": {
#       "builder_url": "URL GOES HERE",
#       "token"      : "JENKINS_TOKEN",
#     }
#   }
#

class IrcMachine::Plugin::GithubJenkins < IrcMachine::Plugin::Base

  CONFIG_FILE = "github_jenkins.json"

  USERNAME_MAPPING = {
    "richoH" => "richo"
  }

  def initialize(*args)
    @id = 0
    @build_cache = {}
    @repos = Hash.new
    load_config.each do |k, v|
      @repos[k] = OpenStruct.new(v)
    end

    route(:post, %r{^/github/jenkins$}, :build_branch)
    route(:post, %r{^/github/jenkins_status$}, :jenkins_status)
    super(*args)
  end

  def build_branch
    commit = Models::GithubNotification.new(request.body.read)

    if repo = @repos[commit.repo_name]
      trigger_build(repo, commit)
    else
      not_found
    end
  end

  def jenkins_status
    jenkins = Models::JenkinsNotification.new(request.body.read)

    if repo = @repos[jenkins.repo_name]

    else
      not_found
    end
  end

private

  def trigger_build(repo, commit)
    uri URI(repo.builder_url)
    params = { SHA1: commit.after, ID: next_id }

    uri.query = URI.encode_www_form(params)
    return Net::HTTP.get(uri).is_a? Net::HTTPSuccess
  end

  def load_config
    JSON.load(open(File.expand_path(CONFIG_FILE)))
  end

  def next_id
    @id += 1
  end

end
