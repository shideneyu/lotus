module Lotus
  class Note
    # Determines what constitutes a username inside an update text
    USERNAME_REGULAR_EXPRESSION = /(^|[ \t\n\r\f"'\(\[{]+)@([^ \t\n\r\f&?=@%\/\#]*[^ \t\n\r\f&?=@%\/\#.!:;,"'\]}\)])(?:@([^ \t\n\r\f&?=@%\/\#]*[^ \t\n\r\f&?=@%\/\#.!:;,"'\]}\)]))?/

    # Holds the content as plain text.
    attr_reader :text

    # Holds the content as html.
    attr_reader :html

    # Holds a String containing the title of the note.
    attr_reader :title

    # The person responsible for writing this note.
    attr_reader :author

    # Unique id that identifies this note.
    attr_reader :uid

    # The date the note originally was published.
    attr_reader :published

    # The date the note was last updated.
    attr_reader :updated

    # The permanent location for an html representation of the note.
    attr_reader :url

    # Create a new note.
    #
    # options:
    #   :title        => The title of the note. Defaults: "Untitled"
    #   :text         => The content of the note. Defaults: ""
    #   :html         => The content of the note as html.
    #   :author       => An Author that wrote the note.
    #   :url          => Permanent location for an html representation of the
    #                    note.
    #   :published    => When the note was originally published.
    #   :updated      => When the note was last updated.
    #   :uid          => The unique id that identifies this note.
    def initialize(options = {})
      @text      = options[:text] || ""
      @html      = options[:html] || to_html
      @title     = options[:title] || "Untitled"
      @author    = options[:author]
      @url       = options[:url]
      @published = options[:published]
      @updated   = options[:updated]
      @uid       = options[:uid]
    end

    # Produces an HTML string representing the note's content.
    # TODO: A block for resolving usernames to urls
    def to_html
      return @html if @html

      out = CGI.escapeHTML(@text)

      # Replace any absolute addresses with a link
      # Note: Do this first! Otherwise it will add anchors inside anchors!
      out.gsub!(/(http[s]?:\/\/\S+[a-zA-Z0-9\/}])/, "<a href='\\1'>\\1</a>")

      # we let almost anything be in a username, except those that mess with urls.
      # but you can't end in a .:;, or !
      # also ignore container chars [] () "" '' {}
      # XXX: the _correct_ solution will be to use an email validator
      out.gsub!(USERNAME_REGULAR_EXPRESSION) do |match|
        "#{$1}<a href='#'>@#{$2}</a>"
      end

      out.gsub!( /(^|\s+)#(\p{Word}+)/ ) do |match|
        "#{$1}<a href='/search?search=%23#{$2}'>##{$2}</a>"
      end

      out
    end

    def to_hash
      {
        :text      => @text,
        :html      => @html,
        :title     => @title,
        :author    => @author,
        :url       => @url,
        :published => @published,
        :updated   => @updated,
        :uid       => @uid
      }
    end
  end
end