require "spec_helper"

RSpec::Matchers.define :have_requirement do |expected|
  match do |actual|
    if actual.respond_to? :requirement
      actual.requirement == expected
    else
      actual == expected
    end
  end
  diffable
end

RSpec::Matchers.define :have_a_dependency_with_name do |expected|
  match do |actual|
    actual.dependencies.detect {|d| d.name == expected}
  end
end

RSpec::Matchers.define :have_a_runtime_dependency do |expected|
  match do |actual|
    actual.dependencies.detect {|d| d.type == :runtime}
  end
end

RSpec::Matchers.define :have_a_development_dependency do |expected|
  match do |actual|
    actual.dependencies.detect {|d| d.type == :development}
  end
end

RSpec::Matchers.define :have_a_dependency_with_requirement do |expected|
  match do |actual|
    actual.dependencies.detect {|d| d.requirement == expected }
  end
end

RSpec::Matchers.define :have_a_dependency_with_list_of_requirements do |expected|
  match do |actual|
    actual.dependencies.collect {|d| d.requirement.as_list == expected}
  end
end

RSpec::Matchers.define :be_in_the_default_group do |expected|
  match do |actual|
    actual.dependencies.collect {|d| d.groups.include? :default}
  end
end

describe Gemnasium::Parser::Gemfile do

  let(:gemfile) {Gemnasium::Parser::Gemfile.new(@content)}
  let(:subject) { gemfile }
  def content(string)
    @content ||= begin
      indent = string.scan(/^[ \t]*(?=\S)/)
      n = indent ? indent.size : 0
      string.gsub(/^[ \t]{#{n}}/, "")
    end
  end

  def dependencies
    @dependencies ||= gemfile.dependencies
  end

  def dependency
    dependencies.size.should == 1
    dependencies.first
  end

  def reset
    @content = @gemfile = @dependencies = nil
  end

  context "given a gem call" do
    context "with double quotes" do
      before { content(%(gem "rake", ">= 0.8.7")) }
      it {should have_a_dependency_with_name "rake"}
      it {should have_a_dependency_with_requirement ">= 0.8.7"}
      it {should_not be_gemspec}
      it {should have_a_runtime_dependency}
      it {should be_in_the_default_group}
      its(:gemspec) {should be_nil}
    end

    context "with single quotes" do
      before { content(%(gem 'rake', '>= 0.8.7')) }
      it { should have_a_dependency_with_name "rake" }
      it { should have_a_dependency_with_requirement ">= 0.8.7"}
    end

    context "with mixed quotes" do
      before {content(%(gem "rake', ">= 0.8.7"))}
      it 'ignores the line' do
        gemfile.dependencies.should be_empty
      end
    end

    context "with a period in the gem name" do
      before { content(%(gem "pygment.rb", ">= 0.8.7")) }

      it {should have_a_dependency_with_name "pygment.rb"}
      it {should have_a_dependency_with_requirement ">= 0.8.7"}
    end

    context "without a requirement" do
      before {content(%(gem "rake"))}

      it { should have_a_dependency_with_name "rake" }
      it { should have_a_dependency_with_requirement ">= 0"}
    end

    context "with multiple requirements" do
      before {content(%(gem "rake", ">= 0.8.7", "<= 0.9.2"))}

      it { should have_a_dependency_with_name "rake" }
      it { should have_a_dependency_with_list_of_requirements ["<= 0.9.2", ">= 0"]}
    end

    context "with options" do
      before { content(%(gem "rake", ">= 0.8.7", :require => false)) }
      it { should have_a_dependency_with_name "rake" }
      it { should have_a_dependency_with_requirement ">= 0.8.7" }
    end

    context "with a :development type option" do
      before { content(%(gem "rake", :group => :development)) }
      it { should have_a_development_dependency}
    end

  end

  context 'given a gemspec call' do

    context 'with no options' do
      before {content(%(gemspec))}

      it {should be_gemspec}
      its(:gemspec) {should == "*.gemspec"}
    end

    context "with a name option" do
      before {content(%(gemspec :name => "gemnasium-parser"))}
      its(:gemspec) {should == "gemnasium-parser.gemspec"}
    end

    context "with a path option" do
      before {content(%(gemspec :path => "lib/gemnasium"))}

      its(:gemspec) {should == "lib/gemnasium/*.gemspec" }
    end

    context "with both name and path options" do
      before {content(%(gemspec :name => "parser", :path => "lib/gemnasium"))}
      its(:gemspec) {should == "lib/gemnasium/parser.gemspec" }
    end

    context "with parentheses" do
      before {content(%(gemspec(:name => "gemnasium-parser")))}
      it {should be_gemspec}
    end
  end

  it "parses gems of a group" do
    content(%(gem "rake", :group => :development))
    dependency.groups.should == [:development]
  end

  it "parses gems of multiple groups" do
    content(%(gem "rake", :group => [:development, :test]))
    dependency.groups.should == [:development, :test]
  end

  it "recognizes :groups" do
    content(%(gem "rake", :groups => [:development, :test]))
    dependency.groups.should == [:development, :test]
  end

  it "parses gems in a group" do
    content(<<-EOF)
      gem "rake"
      group :production do
        gem "pg"
      end
      group :development do
        gem "sqlite3"
      end
    EOF
    dependencies[0].groups.should == [:default]
    dependencies[1].groups.should == [:production]
    dependencies[2].groups.should == [:development]
  end

  it "parses gems in a group with parentheses" do
    content(<<-EOF)
      group(:production) do
        gem "pg"
      end
    EOF
    dependency.groups.should == [:production]
  end

  it "parses gems in multiple groups" do
    content(<<-EOF)
      group :development, :test do
        gem "sqlite3"
      end
    EOF
    dependency.groups.should == [:development, :test]
  end

  it "parses multiple gems in a group" do
    content(<<-EOF)
      group :development do
        gem "rake"
        gem "sqlite3"
      end
    EOF
    dependencies[0].groups.should == [:development]
    dependencies[1].groups.should == [:development]
  end

  it "parses multiple gems in multiple groups" do
    content(<<-EOF)
      group :development, :test do
        gem "rake"
        gem "sqlite3"
      end
    EOF
    dependencies[0].groups.should == [:development, :test]
    dependencies[1].groups.should == [:development, :test]
  end

  it "ignores h4x" do
    path = File.expand_path("../h4x.txt", __FILE__)
    content(%(gem "h4x", :require => "\#{`touch #{path}`}"))
    dependencies.size.should == 0
    begin
      File.should_not exist(path)
    ensure
      FileUtils.rm_f(path)
    end
  end

  it "ignores gems with a git option" do
    content(%(gem "rails", :git => "https://github.com/rails/rails.git"))
    dependencies.size.should == 0
  end

  it "ignores gems with a github option" do
    content(%(gem "rails", :github => "rails/rails"))
    dependencies.size.should == 0
  end

  it "ignores gems with a path option" do
    content(%(gem "rails", :path => "vendor/rails"))
    dependencies.size.should == 0
  end

  it "ignores gems in a git block" do
    content(<<-EOF)
      git "https://github.com/rails/rails.git" do
        gem "rails"
      end
    EOF
    dependencies.size.should == 0
  end

  it "ignores gems in a git block with parentheses" do
    content(<<-EOF)
      git("https://github.com/rails/rails.git") do
        gem "rails"
      end
    EOF
    dependencies.size.should == 0
  end

  it "ignores gems in a path block" do
    content(<<-EOF)
      path "vendor/rails" do
        gem "rails"
      end
    EOF
    dependencies.size.should == 0
  end

  it "ignores gems in a path block with parentheses" do
    content(<<-EOF)
      path("vendor/rails") do
        gem "rails"
      end
    EOF
    dependencies.size.should == 0
  end

  it "records dependency line numbers" do
    content(<<-EOF)
      gem "rake"

      gem "rails"
    EOF
    dependencies[0].instance_variable_get(:@line).should == 1
    dependencies[1].instance_variable_get(:@line).should == 3
  end

  it "maps groups to types" do
    content(<<-EOF)
      gem "rake"
      gem "pg", :group => :production
      gem "mysql2", :group => :staging
      gem "sqlite3", :group => :development
    EOF
    dependencies[0].type.should == :runtime
    dependencies[1].type.should == :runtime
    dependencies[2].type.should == :development
    dependencies[3].type.should == :development
  end

  context "when a custom runtime group is specified" do
    it "maps groups to types" do
    Gemnasium::Parser.runtime_groups << :staging
    content(<<-EOF)
      gem "rake"
      gem "pg", :group => :production
      gem "mysql2", :group => :staging
      gem "sqlite3", :group => :development
    EOF
    dependencies[0].type.should == :runtime
    dependencies[1].type.should == :runtime
    dependencies[2].type.should == :runtime
    dependencies[3].type.should == :development
    end
  end

  it "parses parentheses" do
    content(%(gem("rake", ">= 0.8.7")))
    dependency.name.should == "rake"
    dependency.should have_requirement ">= 0.8.7"
  end

  it "parses gems followed by inline comments" do
    content(%(gem "rake", ">= 0.8.7" # Comment))
    dependency.name.should == "rake"
    dependency.should have_requirement ">= 0.8.7"
  end

  it "parses oddly quoted gems" do
    content(%(gem %q<rake>))
    dependency.name.should == "rake"
  end

end
