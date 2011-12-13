require "spec_helper"

describe Gemnasium::Parser::Gemfile do
  def content(string)
    @content = string.gsub(/^\s+/, "")
  end

  def gemfile
    @gemfile ||= Gemnasium::Parser::Gemfile.new(@content)
  end

  def dependencies
    @dependencies ||= gemfile.dependencies
  end

  def dependency
    dependencies.size.should == 1
    dependencies.first
  end

  it "parses double quotes" do
    content(%(gem "rake", ">= 0.8.7"))
    dependency.name.should == "rake"
    dependency.requirement.should == ">= 0.8.7"
  end

  it "parses single quotes" do
    content(%(gem 'rake', '>= 0.8.7'))
    dependency.name.should == "rake"
    dependency.requirement.should == ">= 0.8.7"
  end

  it "ignores mixed quotes" do
    content(%(gem "rake', ">= 0.8.7"))
    dependencies.size.should == 0
  end

  it "parses non-requirement gems" do
    content(%(gem "rake"))
    dependency.name.should == "rake"
    dependency.requirement.should == ">= 0"
  end

  it "parses multi-requirement gems" do
    content(%(gem "rake", ">= 0.8.7", "<= 0.9.2"))
    dependency.name.should == "rake"
    dependency.requirement.as_list.should == ["<= 0.9.2", ">= 0.8.7"]
  end
end
