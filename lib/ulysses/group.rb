module Ulysses
  class Group

    attr_reader :dirname

    def initialize(info_file_path)
      @dirname = File.dirname(info_file_path)
      @info    = parse_info(info_file_path)
    end

    def display_name
      @display_name = @info['displayName'].content
    end

    def children
      @info['childOrder'].children.map do |child|
        Group.new File.join(@dirname, child.content, 'Info.ulgroup') if child.element?
      end.compact
    end

    def sheets
      list = @info['sheetClusters'].children.select { |c| c.element? && c.name == 'array' }
      list = list.map do |i|
        content_node = i.children.find { |c| c.element? && c.name == 'string' }
        content_node.content
      end
      list.map do |dirname|
        Sheet.new File.join(@dirname, dirname)
      end
    end

    private

    def parse_info(file_path)
      xml  = Nokogiri::XML File.read(file_path)
      dict = xml.xpath('//dict').children.map do |child|
        (child.name == 'key' ? child.content : child) if child.element?
      end.compact
      Hash[*dict]
    end

  end
end
