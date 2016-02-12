module Ulysses
  class Sheet

    attr_reader :dirname

    def initialize(dirname)
      @dirname = dirname
    end

    def markup
      @markup ||= parse_markup
    end

    def xml
      @xml ||=  Nokogiri::XML(File.read(File.join(@dirname, 'Content.xml')))
    end

    def to_html
      @html ||= Exporter.new(xml).to_html
    end

    def reload
      @markup, @xml, @html = nil
    end

    private

    def parse_xml_attributes(node)
      Hash[node.attributes.map { |nm, el| [nm.to_sym, el.value] }]
    end

    def parse_markup
      segment = xml.xpath('/sheet/markup')[0]
      markup  = parse_xml_attributes(segment)
      markup[:definitions] = begin
        defines = segment.children.select { |node| node.element? }.map do |node|
          attrs = parse_xml_attributes(node)
          [attrs[:definition].to_sym, attrs]
        end
        Hash[defines]
      end
      markup
    end

  end
end
