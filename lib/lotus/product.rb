module Lotus
  class Product
    include Lotus::Object

    attr_reader :full_image

    def initialize(options = {})
      super options

      @full_image = options[:full_image]
    end

    def to_hash
      {
        :full_image => @full_image
      }.merge(super)
    end

    def to_json_hash
      {
        :objectType => "product",
        :fullImage  => @full_image
      }.merge(super)
    end
  end
end
