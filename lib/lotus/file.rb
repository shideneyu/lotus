module Lotus
  class File
    include Lotus::Object

    attr_reader :file_url
    attr_reader :mime_type

    attr_reader :length
    attr_reader :md5

    def initialize(options = {})
      super options

      @md5         = options[:md5]
      @file_url    = options[:file_url]
      @mime_type   = options[:mime_type]
      @length      = options[:length]
    end

    def to_hash
      {
        :md5       => @md5,
        :file_url  => @file_url,
        :mime_type => @mime_type,
        :length    => @length
      }.merge(super)
    end

    def to_json_hash
      {
        :objectType  => "file",
        :md5         => @md5,
        :fileUrl     => @file_url,
        :mimeType    => @mime_type,
        :length      => @length
      }.merge(super)
    end
  end
end
