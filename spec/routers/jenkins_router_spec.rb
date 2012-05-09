require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe IrcMachine::Routers::JenkinsRouter do

  before(:each) do
    builds = Hash.new
    @route = mock()
    @instance = ::IrcMachine::Routers::JenkinsRouter.new(builds) do |endpoint|
      endpoint.on :started do |commit, build|
        @route.started
      end
      endpoint.on :completed, :success do |commit, build|
        @route.completed_success
      end
      endpoint.on :completed, :failure do |commit, build|
        @route.completed_failure
      end
      endpoint.on :unknown do |build|
        @route.unknown
      end
    end
  end

  def get_env(opts={})
    env = Rack::MockRequest.env_for("/github/jenkins_status", input: Fixtures::Jenkins::Body.new(opts))
    request = Rack::Request.new(env)
    response = Rack::Response.new(env)
    [request, response]
  end

  it "should route requests to the unknown handler when the build is unrecognised" do
    request, response = get_env

    @route.expects(:unknown)
    @instance.endpoint.call(request, response)
  end

  it "Should use the default route if no :status is requested" do
    route = mock()
    route.expects(:generic)

    request, response = get_env( ID: 123, phase: "completed" )
    builds = { "123" => mock }

    router = ::IrcMachine::Routers::JenkinsRouter.new(builds) do |endpoint|
      endpoint.on :completed do |commit, build|
        route.generic
      end
      endpoint.on :unknown do |commit, build|
        raise "Whoopsie"
      end
    end

    router.endpoint.call(request, response)
  end

end
