require "spec_helper"

describe Gemnasium::Parser do
  describe ".gemfile" do
    it "requires a single string argument" do
      expect{ Gemnasium::Parser.gemfile }.to raise_error(ArgumentError)
      expect{ Gemnasium::Parser.gemfile("") }.to_not raise_error
    end

    it "returns a Gemfile" do
      Gemnasium::Parser.gemfile("").should be_a(Gemnasium::Parser::Gemfile)
    end

    it "removes CR chars from content" do
      Gemnasium::Parser.gemfile("\r").content.match("\r").should be_nil
    end

  end

  describe ".gemspec" do
    it "requires a single string argument" do
      expect{ Gemnasium::Parser.gemspec }.to raise_error(ArgumentError)
      expect{ Gemnasium::Parser.gemspec("") }.to_not raise_error
    end

    it "returns a Gemspec" do
      Gemnasium::Parser.gemspec("").should be_a(Gemnasium::Parser::Gemspec)
    end

    it "removes CR chars from content" do
      Gemnasium::Parser.gemspec("\r").content.match("\r").should be_nil
    end
  end
end
