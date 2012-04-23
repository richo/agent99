require 'net/http'
# * Configuration
# Project needs to be configured in jenkins with two parameters:
# - SHA1 : Takes a sha hash to build
# - ID   : Takes unique ID, purely for passing back to work out which build it
#          was that we're looking at
#
# Then configuration in the .json file is
# - {
#     "settings": {
#       "notify": "#builds"
#     },
#     "builds": {
#       "reponame": {
#         "builder_url": "URL GOES HERE",
#         "token"      : "JENKINS_TOKEN",
#       }
#     }
#   }
#
class IrcMachine::Plugin::GithubJenkins < IrcMachine::Plugin::Base

  CONFIG_FILE = "github_jenkins.json"

  attr_reader :settings
  def initialize(*args)
    @repos = Hash.new
    @builds = Hash.new
    conf = load_config

    conf["builds"].each do |k, v|
      @repos[k] = OpenStruct.new(v)
      # Kludge until we go live with this
    end

    @settings = OpenStruct.new(conf["settings"])
    @usernames = conf["usernames"] || {}

    route(:post, %r{^/github/jenkins$}, :build_branch)

    initialize_jenkins_notifier
    super(*args)
  end

  def initialize_jenkins_notifier
    @notifier = JenkinsNotifier.new(@builds) do |endpoint|
      endpoint.on :success do |commit, build|#{{{ Success
        notify format_msg(commit, build)
      end #}}}

      endpoint.on :failure do |commit, build| #{{{ Failure
        notify format_msg(commit, build)
        notify "Jenkins output available at #{build.full_url}"
      end #}}}

      endpoint.on :aborted do |commit, build| #{{{ Aborted
        notify "Build of #{commit.repo_name}/#{commit.branch} ABORTED"
      end #}}}

      endpoint.on :unknown do |build| #{{{ Unknown
        notify "Unknown build of #{build.parameters.SHA1} completed with status #{build.status}"
      end #}}}
    end
    route(:post, %r{^/github/jenkins_status$}, :jenkins_notifier_endpoint)
  end

  def jenkins_notifier_endpoint(request, match)
    @notifier.process(request.body.read)
  end

  def build_branch(request, match)
    commit = ::IrcMachine::Models::GithubNotification.new(request.body.read)

    if repo = @repos[commit.repo_name]
      trigger_build(repo, commit)
    else
      not_found
    end
  end

  def notify(msg)
    session.msg settings.notify, msg
  end

private

  def get_nick(author)
    @usernames[author] || author
  end

  def trigger_build(repo, commit)
    uri = URI(repo.builder_url)
    id = next_id
    @builds[id.to_s] = OpenStruct.new({ repo: repo, commit: commit})
    params = defaultParams(repo).merge ({SHA1: commit.after, ID: id})

    uri.query = URI.encode_www_form(params)
    return Net::HTTP.get(uri).is_a? Net::HTTPSuccess
  end

  def load_config
    JSON.load(open(File.expand_path(CONFIG_FILE)))
  end

  def next_id
    Time.now.to_i
  end

  def defaultParams(repo)
    { token: repo.token }
  end

  def format_msg(commit, build)
    "Build of #{commit.repo_name}/#{commit.branch} was a #{build.status} #{commit.respository.url}/compare/#{commit.before[0..6]}...#{commit.after[0..6]} in [time]s PING #{commit.author_usernames.join(" ")}"
  end
end
