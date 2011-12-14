require "spec_helper"

describe Gemnasium::Parser::Gemspec do
  def content(string)
    @content ||= begin
      indent = string.scan(/^[ \t]*(?=\S)/)
      n = indent ? indent.size : 0
      string.gsub(/^[ \t]{#{n}}/, "")
    end
  end

  def gemspec
    @gemspec ||= Gemnasium::Parser::Gemspec.new(@content)
  end

  def dependencies
    @dependencies ||= gemspec.dependencies
  end

  def dependency
    dependencies.size.should == 1
    dependencies.first
  end

  def reset
    @content = @gemspec = @dependencies = nil
  end

  it "parses double quotes" do
    content(<<-EOF)
      Gem::Specification.new do |gem|
        gem.add_dependency "rake", ">= 0.8.7"
      end
    EOF
    dependency.name.should == "rake"
    dependency.requirement.should == ">= 0.8.7"
  end

  it "parses single quotes" do
    content(<<-EOF)
      Gem::Specification.new do |gem|
        gem.add_dependency 'rake', '>= 0.8.7'
      end
    EOF
    dependency.name.should == "rake"
    dependency.requirement.should == ">= 0.8.7"
  end

  it "ignores mixed quotes" do
    content(<<-EOF)
      Gem::Specification.new do |gem|
        gem.add_dependency "rake', ">= 0.8.7"
      end
    EOF
    dependencies.size.should == 0
  end

  it "parses non-requirement gems" do
    content(<<-EOF)
      Gem::Specification.new do |gem|
        gem.add_dependency "rake"
      end
    EOF
    dependency.name.should == "rake"
    dependency.requirement.should == ">= 0"
  end

  it "parses multi-requirement gems" do
    content(<<-EOF)
      Gem::Specification.new do |gem|
        gem.add_dependency "rake", ">= 0.8.7", "<= 0.9.2"
      end
    EOF
    dependency.name.should == "rake"
    dependency.requirement.as_list.should == ["<= 0.9.2", ">= 0.8.7"]
  end

  it "parses single-element array requirement gems" do
    content(<<-EOF)
      Gem::Specification.new do |gem|
        gem.add_dependency "rake", [">= 0.8.7"]
      end
    EOF
    dependency.name.should == "rake"
    dependency.requirement.should == ">= 0.8.7"
  end

  it "parses multi-element array requirement gems" do
    content(<<-EOF)
      Gem::Specification.new do |gem|
        gem.add_dependency "rake", [">= 0.8.7", "<= 0.9.2"]
      end
    EOF
    dependency.name.should == "rake"
    dependency.requirement.as_list.should == ["<= 0.9.2", ">= 0.8.7"]
  end

  it "records dependency line numbers" do
    content(<<-EOF)
      Gem::Specification.new do |gem|
        gem.add_dependency "rake"
        gem.add_dependency "rails"
      end
    EOF
    dependencies[0].instance_variable_get(:@line).should == 2
    dependencies[1].instance_variable_get(:@line).should == 3
  end
end
