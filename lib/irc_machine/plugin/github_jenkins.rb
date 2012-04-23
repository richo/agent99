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
    @id = 0
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
    route(:post, %r{^/github/jenkins_status$}, :jenkins_status)
    super(*args)
  end

  def build_branch(request, match)
    commit = ::IrcMachine::Models::GithubNotification.new(request.body.read)

    if repo = @repos[commit.repo_name]
      trigger_build(repo, commit)
    else
      not_found
    end
  end

  def jenkins_status(request, match)
    jenkins = ::IrcMachine::Models::JenkinsNotification.new(request.body.read)

    if build = @builds[jenkins.parameters.ID.to_s]
      case jenkins.phase
      when "STARTED" #{{{
        message = "Build of #{build.commit.repo_name}/#{build.commit.branch} STARTED" #}}}
      when "COMPLETED" #{{{
        case jenkins.status
        when "SUCCESS", "FAILURE" #{{{
          message = "Build of #{build.commit.repo_name}/#{build.commit.branch} was a #{jenkins.status} https://github.com/#{build.commit.repo_name}/#{build.commit.branch}/compare/#{build.commit.before[0..6]}...#{build.commit.after[0..6]} in [time]s"
          if jenkins.status == "FAILURE"
            session.msg settings.notify, "Jenkins output available at [ Jenkins URL ]"
          end
          #}}}
        when "ABORTED" #{{{
          message = "Builds of #{build.commit.repo_name}/#{build.commit.branch} ABORTED" # No real way to work out who did it since we don't all have jenkins logins
          #}}}
        end
       #}}}
        message = "Build status of #{build.commit.repo_name}/#{build.commit.branch} revision #{build.commit.after} changed to #{jenkins.status} PING #{build.commit.author_usernames.join(" ")}"
      when "FINISHED" #{{{
        #}}}
      else #{{{ UNKNOWN
        message = "Unknown phase #{jenkins.phase}"
      end #}}}

      session.msg settings.notify, message

    else
      not_found
    end
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
    @id += 1
  end

  def defaultParams(repo)
    { token: repo.token }
  end
end
