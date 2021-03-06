module Lotus
  # This class represents an Activity object that represents an action taken
  # by a Person.
  class Activity
    require 'time-lord/units'
    require 'time-lord/scale'
    require 'time-lord/period'

    include Lotus::Object

    STANDARD_TYPES = [:article, :audio, :bookmark, :comment, :file, :folder,
                      :group, :list, :note, :person, :image,
                      :place, :playlist, :product, :review, :service, :status,
                      :video]

    # The object of this activity.
    attr_reader :object

    # The type of object for this activity.
    #
    # The field can be a String for uncommon types. Several are standard:
    #   :article, :audio, :bookmark, :comment, :file, :folder, :group,
    #   :list, :note, :person, :image, :place, :playlist,
    #   :product, :review, :service, :video
    attr_reader :type

    # The action being invoked in this activity.
    #
    # The field can be a String for uncommon verbs. Several are standard:
    #   :favorite, :follow, :like, :"make-friend", :join, :play,
    #   :post, :save, :share, :tag, :update
    attr_reader :verb

    # The target of the action.
    attr_reader :target

    # Holds an Lotus::Person.
    attr_reader :actor

    # Holds the source of this entry as an Lotus::Feed.
    attr_reader :source

    # Holds an array of related Lotus::Activity's that this entry is a response
    # to.
    attr_reader :in_reply_to

    # Holds an array of related Lotus::Activity's that are replies to this one.
    attr_reader :replies

    # Holds an array of Lotus::Person's that have favorited this activity.
    attr_reader :likes

    # Holds an array of Lotus::Person's that have shared this activity.
    attr_reader :shares

    # Holds an array of Lotus::Person's that are mentioned in this activity.
    attr_reader :mentions

    # Create a new entry with the given action and object.
    #
    # options:
    #   :object      => The object of this activity.
    #   :type        => The type of object for this activity.
    #   :target      => The target of this activity.
    #   :verb        => The action of the activity.
    #
    #   :actor        => An Lotus::Person responsible for generating this entry.
    #   :source       => An Lotus::Feed where this Entry originated. This
    #                    should be used when an Entry is copied into this feed
    #                    from another.
    #   :published    => The DateTime depicting when the entry was originally
    #                    published.
    #   :updated      => The DateTime depicting when the entry was modified.
    #   :url          => The canonical url of the entry.
    #   :uid          => The unique id that identifies this entry.
    #   :in_reply_to  => An Lotus::Entry for which this entry is a response.
    #                    Or an array of Lotus::Entry's that this entry is a
    #                    response to. Use this when this Entry is a reply
    #                    to an existing Entry.
    def initialize(options = {})
      @object      = options[:object]

      @type        = options[:type]
      if STANDARD_TYPES.map(&:to_s).include? @type
        @type = @type.intern
      end

      @target      = options[:target]
      @verb        = options[:verb]

      @actor        = options[:actor]
      @source       = options[:source]
      @published    = options[:published]
      @updated      = options[:updated]
      @url          = options[:url]
      @uid          = options[:uid]

      unless options[:in_reply_to].nil? or options[:in_reply_to].is_a?(Array)
        options[:in_reply_to] = [options[:in_reply_to]]
      end

      @in_reply_to  = options[:in_reply_to] || []
      @replies      = options[:replies]     || []

      @mentions     = options[:mentions]    || []
      @likes        = options[:likes]       || []
      @shares       = options[:shares]      || []
    end

    def published_ago_in_words
      TimeLord::Period.new(self.published.to_time, Time.now).to_words
    end

    def updated_ago_in_words
      TimeLord::Period.new(self.updated.to_time, Time.now).to_words
    end

    # Returns a hash of all relevant fields.
    def to_hash
      {
        :source => self.source,

        :in_reply_to => self.in_reply_to.dup,
        :replies => self.replies.dup,

        :mentions => self.mentions.dup,
        :likes => self.likes.dup,
        :shares => self.shares.dup,

        :object => self.object,
        :target => self.target,
        :actor => self.actor,
        :verb => self.verb,
        :type => self.type
      }.merge(super)
    end

    # Returns a string containing the Atom representation of this Activity.
    def to_atom
      require 'lotus/atom/entry'

      Lotus::Atom::Entry.from_canonical(self).to_xml
    end

    # Returns a hash of all relevant fields with JSON activity streams
    # conventions.
    def to_json_hash
      {
        :objectType => "activity",
        :object => @object,
        :actor => @actor,
        :target => @target,
        :type => @type,
        :verb => @verb,
        :source => self.source,
        :in_reply_to => self.in_reply_to.dup,
        :replies => self.replies.dup,
        :mentions => self.mentions.dup,
        :likes => self.likes.dup,
        :shares => self.shares.dup,
      }.merge(super)
    end

    # Generates a sentence describing this activity in the current or given
    # locale.
    #
    # Usage:
    #   # The default locale
    #   Lotus::Activity.new(:verb => :post,
    #                       :object => Lotus::Note(:content => "hello"),
    #                       :actor => Lotus::Person.new(:name => "wilkie"))
    #                  .sentence
    #   # => "wilkie posted a note"
    #
    #   Lotus::Activity.new(:verb => :follow,
    #                       :object => Lotus::Person.new(:name => "carol"),
    #                       :actor => Lotus::Person.new(:name => "wilkie"))
    #                  .sentence
    #   # => "wilkie followed carol"
    #
    #   # In Spanish
    #   Lotus::Activity.new(:verb => :post,
    #                       :object => Lotus::Note(:content => "hello"),
    #                       :actor => Lotus::Person.new(:name => "wilkie"))
    #                  .sentence(:locale => :es)
    #   # => "wilkie puso una nota"
    def sentence(options = {})
      object_owner = nil

      if self.verb == :favorite || self.verb == :share
        if self.object.author
          object_owner = self.object.author.name
        elsif self.object.actor.is_a? Lotus::Person
          object_owner = self.object.actor.name
        end
      end

      object = self.type

      if self.verb == :favorite || self.verb == :share
        if self.object
          object = self.object.type
        end
      end

      actor = nil

      if self.actor
        actor = self.actor.short_name
      end

      person = nil

      if self.object.is_a?(Lotus::Person)
        person = self.object.name
      end

      Lotus::I18n.sentence({
        :actor => actor,
        :object => object,
        :object_owner => object_owner,
        :person => person,
        :verb => self.verb,
        :target => self.target ? self.target.short_name : nil
      }.merge(options))
    end
  end
end
