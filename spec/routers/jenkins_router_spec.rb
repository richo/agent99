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
      endpoint.on :completed_failure do |commit, build|
        @route.completed_failure
      end
      endpoint.on :unknown do |build|
        @route.unknown
      end
    end
  end

  it "should route requests to the unknown handler when the build is unrecognised" do
    env = Rack::MockRequest.env_for("/github/jenkins_status", input: Fixtures::Jenkins::Body.new)
    request = Rack::Request.new(env)
    response = Rack::Response.new(env)

    @route.expects(:unknown)
    @instance.endpoint.call(request, response)
  end

end
