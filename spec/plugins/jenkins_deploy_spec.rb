require File.join(File.dirname(__FILE__), "/../spec_helper")

describe IrcMachine::Plugin::JenkinsNotify do
  it "Initializes cleanly without any hooks" do
    IrcMachine::Plugin::JenkinsNotify.any_instance.expects(:load_config).returns({
      :agent99 => {
        "deploy_url" => "https://github.com/99designs/agent99",
        "name" => "agent99" }})
    plugin = IrcMachine::Plugin::JenkinsNotify.new(nil)

    plugin.rest_fail({}, ["", "agent99"])
    plugin.rest_success({}, ["", "agent99"])
  end

  it "Calls string hooks" do
    IrcMachine::Plugin::JenkinsNotify.any_instance.expects(:load_config).returns({
      :agent99 => {
        "deploy_url" => "https://github.com/99designs/agent99",
        "name" => "agent99",
        "hooks" => {
          "success" => ""}}})
    plugin = IrcMachine::Plugin::JenkinsNotify.new(nil)
    Hook.any_instance.expects(:call)
    MutexApp.any_instance.expects(:succeed).returns(true)
    MutexApp.any_instance.expects(:notify)
    plugin.rest_success({}, ["", "agent99"])
  end

end
