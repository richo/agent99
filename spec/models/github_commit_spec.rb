require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')

describe IrcMachine::Models::GithubCommit do

  before(:each) do
    @instance = Fixtures::GithubCommit.new
  end

  it "Should fail to initialize unless correct keys are passed in" do
    lambda {
      ::IrcMachine::Models::GithubCommit.new({ repo: "rawk" })
    }.should raise_error ::IrcMachine::Models::Exceptions::ModelValidationError

    lambda {
      ::IrcMachine::Models::GithubCommit.new({ repo: "repo", commit: "commit", repo_name: "repo_name", branch_name: "branch_name"})
    }.should_not raise_error
  end

  it "Should calculate build time" do
    offset = 120 # Build time of 2 mins
    build_start = Time.now.to_i
    build_finish = build_start + offset

    Time.expects(:now).returns(build_finish)

    @instance.start_time = build_start
    @instance.build_time.should == offset
  end

  it "Should have a zero build time until the build starts" do
    @instance.start_time.should == 0
  end
end
