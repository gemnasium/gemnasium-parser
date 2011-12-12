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
  end

  describe ".gemspec" do
    it "requires a single string argument" do
      expect{ Gemnasium::Parser.gemspec }.to raise_error(ArgumentError)
      expect{ Gemnasium::Parser.gemspec("") }.to_not raise_error
    end

    it "returns a Gemspec" do
      Gemnasium::Parser.gemspec("").should be_a(Gemnasium::Parser::Gemspec)
    end
  end
end
