module Ulysses
  class Sheet

    attr_reader :dirname

    def initialize(dirname)
      @dirname = dirname
    end

    def xml
      @xml ||= File.read(File.join(@dirname, 'Content.xml'))
    end

    def to_html
      @html ||= Exporter.new(xml).to_html
    end

    def reload
      @xml, @html = nil
    end

  end
end
