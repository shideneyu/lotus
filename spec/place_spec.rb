require_relative 'helper'
require_relative '../lib/lotus/place.rb'

describe Lotus::Place do
  describe "#initialize" do
    it "should store an author" do
      author = mock('author')
      Lotus::Place.new(:author => author).author.must_equal author
    end

    it "should store the address" do
      Lotus::Place.new(:address => "txt").address.must_equal "txt"
    end

    it "should store the position" do
      Lotus::Place.new(:position => "txt").position.must_equal "txt"
    end

    it "should store content" do
      Lotus::Place.new(:content => "txt").content.must_equal "txt"
    end

    it "should store the published date" do
      time = mock('date')
      Lotus::Place.new(:published => time).published.must_equal time
    end

    it "should store the updated date" do
      time = mock('date')
      Lotus::Place.new(:updated => time).updated.must_equal time
    end

    it "should store a display name" do
      Lotus::Place.new(:display_name => "url")
                        .display_name.must_equal "url"
    end

    it "should store a summary" do
      Lotus::Place.new(:summary => "url").summary.must_equal "url"
    end

    it "should store a url" do
      Lotus::Place.new(:url => "url").url.must_equal "url"
    end

    it "should store an id" do
      Lotus::Place.new(:uid => "id").uid.must_equal "id"
    end
  end

  describe "#to_hash" do
    it "should contain the content" do
      Lotus::Place.new(:content => "Hello")
                        .to_hash[:content].must_equal "Hello"
    end

    it "should contain the author" do
      author = mock('Lotus::Person')
      Lotus::Place.new(:author => author).to_hash[:author].must_equal author
    end

    it "should contain the address" do
      Lotus::Place.new(:address => "Hello").to_hash[:address].must_equal "Hello"
    end

    it "should contain the address" do
      Lotus::Place.new(:position => "Foo").to_hash[:position].must_equal "Foo"
    end

    it "should contain the uid" do
      Lotus::Place.new(:uid => "Hello").to_hash[:uid].must_equal "Hello"
    end

    it "should contain the url" do
      Lotus::Place.new(:url => "Hello").to_hash[:url].must_equal "Hello"
    end

    it "should contain the summary" do
      Lotus::Place.new(:summary=> "Hello")
                 .to_hash[:summary].must_equal "Hello"
    end

    it "should contain the display name" do
      Lotus::Place.new(:display_name => "Hello")
                 .to_hash[:display_name].must_equal "Hello"
    end

    it "should contain the published date" do
      date = mock('Time')
      Lotus::Place.new(:published => date).to_hash[:published].must_equal date
    end

    it "should contain the updated date" do
      date = mock('Time')
      Lotus::Place.new(:updated => date).to_hash[:updated].must_equal date
    end
  end

  describe "#to_json" do
    before do
      author = Lotus::Person.new :display_name => "wilkie"
      @note = Lotus::Place.new :content      => "Hello",
                               :author       => author,
                               :position     => "foo",
                               :address      => "bar",
                               :uid          => "id",
                               :url          => "url",
                               :title        => "title",
                               :summary      => "foo",
                               :display_name => "meh",
                               :published    => Time.now,
                               :updated      => Time.now

      @json = @note.to_json
      @data = JSON.parse(@json)
    end

    it "should contain the embedded json for the author" do
      @data["author"].must_equal JSON.parse(@note.author.to_json)
    end

    it "should contain a 'place' objectType" do
      @data["objectType"].must_equal "place"
    end

    it "should contain the id" do
      @data["id"].must_equal @note.uid
    end

    it "should contain the address" do
      @data["address"].must_equal @note.address
    end

    it "should contain the position" do
      @data["position"].must_equal @note.position
    end

    it "should contain the content" do
      @data["content"].must_equal @note.content
    end

    it "should contain the url" do
      @data["url"].must_equal @note.url
    end

    it "should contain the summary" do
      @data["summary"].must_equal @note.summary
    end

    it "should contain the display name" do
      @data["displayName"].must_equal @note.display_name
    end

    it "should contain the published date as rfc3339" do
      @data["published"].must_equal @note.published.to_date.rfc3339 + 'Z'
    end

    it "should contain the updated date as rfc3339" do
      @data["updated"].must_equal @note.updated.to_date.rfc3339 + 'Z'
    end
  end
end
