module Ulysses
  class Sheet

    attr_reader :dirname

    def initialize(dirname)
      @dirname = dirname
    end

    def reload
      @content = nil
      @text    = nil
    end

    def content
      @content ||= File.read(File.join(@dirname, 'Content.xml'))
    end

    def text
      @text ||= File.read(File.join(@dirname, 'Text.txt'))
    end

    def to_html
      Exporter.new(content).to_html
    end

  end
end
