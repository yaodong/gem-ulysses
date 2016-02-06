module Ulysses
  class Group

    attr_reader :dirname

    def initialize(info_file_path)
      @dirname = File.dirname(info_file_path)
      @info    = parse_info(info_file_path)
    end

    def children
      @info['childOrder'].children.map do |child|
        Group.new File.join(@dirname, child.content, 'Info.ulgroup') if child.element?
      end.compact
    end

    def sheets
      list = @info['sheetClusters'].children.find { |child| child.element? && child.name == 'array' }
      list.children.map do |child|
        Sheet.new File.join(@dirname, child.content) if child.element? && child.name == 'string'
      end.compact
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
