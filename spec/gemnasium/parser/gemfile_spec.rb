require "spec_helper"

describe Gemnasium::Parser::Gemfile do
  def content(string)
    @content ||= begin
      indent = string.scan(/^[ \t]*(?=\S)/)
      n = indent ? indent.size : 0
      string.gsub(/^[ \t]{#{n}}/, "")
    end
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

  def reset
    @content = @gemfile = @dependencies = nil
  end

  it "parses double quotes" do
    content(%(gem "rake", ">= 0.8.7"))
    dependency.name.should == "rake"
    dependency.requirement.as_list.should == [">= 0.8.7"]
  end

  it "parses single quotes" do
    content(%(gem 'rake', '>= 0.8.7'))
    dependency.name.should == "rake"
    dependency.requirement.as_list.should == [">= 0.8.7"]
  end

  it "ignores mixed quotes" do
    content(%(gem "rake', ">= 0.8.7"))
    dependencies.size.should == 0
  end

  it "parses gems with a period in the name" do
    content(%(gem "pygment.rb", ">= 0.8.7"))
    dependency.name.should == "pygment.rb"
    dependency.requirement.as_list.should == [">= 0.8.7"]
  end

  it "parses non-requirement gems" do
    content(%(gem "rake"))
    dependency.name.should == "rake"
    dependency.requirement.as_list.should == [">= 0"]
  end

  it "parses multi-requirement gems" do
    content(%(gem "rake", ">= 0.8.7", "<= 0.9.2"))
    dependency.name.should == "rake"
    dependency.requirement.as_list.should == ["<= 0.9.2", ">= 0.8.7"]
  end

  it "parses gems with options" do
    content(%(gem "rake", ">= 0.8.7", :require => false))
    dependency.name.should == "rake"
    dependency.requirement.as_list.should == [">= 0.8.7"]
  end

  it "listens for gemspecs" do
    content(%(gemspec))
    gemfile.should be_gemspec
    gemfile.gemspec.should == "*.gemspec"
    reset
    content(%(gem "rake"))
    gemfile.should_not be_gemspec
    gemfile.gemspec.should be_nil
  end

  it "parses gemspecs with a name option" do
    content(%(gemspec :name => "gemnasium-parser"))
    gemfile.gemspec.should == "gemnasium-parser.gemspec"
  end

  it "parses gemspecs with a path option" do
    content(%(gemspec :path => "lib/gemnasium"))
    gemfile.gemspec.should == "lib/gemnasium/*.gemspec"
  end

  it "parses gemspecs with name and path options" do
    content(%(gemspec :name => "parser", :path => "lib/gemnasium"))
    gemfile.gemspec.should == "lib/gemnasium/parser.gemspec"
  end

  it "parses gemspecs with parentheses" do
    content(%(gemspec(:name => "gemnasium-parser")))
    gemfile.should be_gemspec
  end

  it "parses gems of a type" do
    content(%(gem "rake"))
    dependency.type.should == :runtime
    reset
    content(%(gem "rake", :type => :development))
    dependency.type.should == :development
  end

  it "parses gems of a group" do
    content(%(gem "rake"))
    dependency.groups.should == [:default]
    reset
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
    reset
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

  it "parses parentheses" do
    content(%(gem("rake", ">= 0.8.7")))
    dependency.name.should == "rake"
    dependency.requirement.as_list.should == [">= 0.8.7"]
  end

  it "parses gems followed by inline comments" do
    content(%(gem "rake", ">= 0.8.7" # Comment))
    dependency.name.should == "rake"
    dependency.requirement.as_list.should == [">= 0.8.7"]
  end

  it "parses oddly quoted gems" do
    content(%(gem %q<rake>))
    dependency.name.should == "rake"
  end
end
