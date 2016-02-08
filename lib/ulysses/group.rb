module Ulysses
  class Group

    attr_reader :dirname

    def initialize(info_file_path)
      @info_file = info_file_path
      @dirname   = File.dirname(@info_file)
    end

    def info
      @info ||= parse_info
    end

    def display_name
      @display_name ||= info['displayName'].content
    end

    def children
      @children ||= parse_children
    end
    alias :groups :children

    def sheets
      @sheets ||= parse_sheets
    end

    def reload
      @info, @children, @sheets = nil
    end

    private

    def parse_info
      xml  = Nokogiri::XML File.read(@info_file)
      dict = xml.xpath('//dict')
                 .children
                 .select { |child| child.element? }
                 .map { |child| child.name == 'key' ? child.content : child }
      Hash[*dict]
    end

    def parse_sheets
      return [] unless info['sheetClusters']
      info['sheetClusters']
          .children
          .select { |c| c.element? && c.name == 'array' }
          .map { |i| i.children.find { |c| c.element? && c.name == 'string' }.content }
          .map { |dir| Sheet.new File.join(@dirname, dir) }
    end

    def parse_children
      return [] unless info['childOrder']
      info['childOrder']
          .children
          .select { |child| child.element? }
          .map { |child| Group.new File.join(@dirname, child.content, 'Info.ulgroup') }
    end

  end
end
