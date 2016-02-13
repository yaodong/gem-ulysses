module Ulysses
  class Printer

    SHEET_CONTENT_XPATH = '/sheet/string[@xml:space="preserve"]'

    def initialize(target)
      @target        = target
      @footnotes     = []
      @annotations   = []
      @html_entities = HTMLEntities.new
    end

    def print
      if @target.is_a? Library
        print_library(@target)
      elsif @target.is_a? Group
        print_group(@target)
      elsif @target.is_a? Sheet
        print_sheet(@target)
      else
        raise "Unsupported print type: #{@target.class}"
      end
    end

    def footnotes
      @footnotes
    end

    def annotations
      @annotations
    end

    private

    def print_library(library)
      library.groups.map { |g| print_group(g) }.join("\n")
    end

    def print_group(group)
      group.sheets.map { |s| print_sheet(s) }.join("\n") + group.groups.map { |g| print_group(g) }.join("\n")
    end

    def print_sheet(sheet)
      paragraphs = sheet.xml.xpath(SHEET_CONTENT_XPATH).children.select { |n| n.element? }
      paragraphs.map{ |p| print_paragraph(p) }.join("\n")
    end

    def print_paragraph(p)
      children = p.children
      tags     = (children.any? && children.first.name === 'tags') ? parse_tags(children.shift) : []
      content  = parse_content(children)
      "<p class=\"#{tags.join(' ')}\">#{content}</p>"
    end

    def parse_content(nodes)
      nodes.map do |node|
        if node.text?
          node.content
        else
          send("parse_#{node.name}", node)
        end
      end.join
    end

    def parse_tags(tags)
      tags.children.map do |tag|
        if tag.attributes.has_key? 'kind'
          tag.attributes['kind'].value
        elsif tag.content === "\t"
          'tab'
        end
      end
    end

    def parse_escape(node)
      node.content.gsub /\\(.)/, '\1'
    end

    def parse_p(node)
      '<p>' + parse_content(node.children) + '</p>'
    end

    def parse_string(node)
      parse_content node.children
    end

    def parse_element(node)
      send "parse_element_#{node.attributes['kind'].value}", node
    end

  end
end
