require File.join(File.dirname(__FILE__), "/../spec_helper")

describe "Agent99::Models::JuiciProject" do

  it "Should respect priority for configured branches" do
    config = { "priorities" => { "master" => 0, "wip/thing" => 15 } }

    project = IrcMachine::Models::JuiciProject.new("test", config)
    project.priorities["master"].should == 0
    project.priorities["wip/thing"].should == 15
    project.priorities["production"].should be_nil
  end

  it "Should interpret regexes in priority" do
    config = { "priorities" => { "master" => 0, "/^wip//" => 20 } }

    project = IrcMachine::Models::JuiciProject.new("test", config)
    project.priorities["wip/thing"].should == 20
    project.priorities["master"].should == 0
    project.priorities["notfound"].should be_nil
  end
end
