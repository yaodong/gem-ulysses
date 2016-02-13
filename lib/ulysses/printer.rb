module Ulysses
  class Printer

    SHEET_CONTENT_XPATH = '/sheet/string[@xml:space="preserve"]'
    SIMPLE_ELEMENTS = {strong: 'strong', emph: 'em', mark: 'mark',
                       delete: 'del', code: 'code', inlineNative: 'span' }
    HIDDEN_ELEMENTS = [:inlineComment]
    HIDDEN_TAGS     = [:comment]

    def initialize(target)
      @target        = target
      @footnotes     = []
      @annotations   = []
      @html_entities = HTMLEntities.new
    end

    def print
      [print_body, print_footnotes].compact.join("\n")
    end

    private

    def print_body
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

    def print_library(library)
      library.groups.map { |g| print_group(g) }.join("\n")
    end

    def print_group(group)
      group.sheets.map { |s| print_sheet(s) }.join("\n") + group.groups.map { |g| print_group(g) }.join("\n")
    end

    def print_sheet(sheet)
      paragraphs = sheet.xml.xpath(SHEET_CONTENT_XPATH).children.select { |n| n.element? }
      paragraphs.map{ |p| print_paragraph(p) }.compact.join("\n")
    end

    def print_footnotes
      return nil if @footnotes.empty?
      html = '<ol class="footnotes">'
      @footnotes.each_with_index do |fn, index|
        html += "<li><a href=\"#fn-#{index+1}\">&#94;</a> #{fn}</li>"
      end
      html + '</ol>'
    end

    def print_annotations
      return nil if @annotations.empty?
      html = '<ol class="annotations">'
      @annotations.each_with_index do |an, index|
        html += "<li id=\"annotation-#{index + 1}\">#{an}</li>"
      end
      html + '</ol>'
    end

    def print_paragraph(p)
      children = p.children
      tags     = (children.any? && children.first.name === 'tags') ? parse_tags(children.shift) : []
      return nil if (tags & HIDDEN_TAGS).any?

      content = parse_content(children)

      heading_tag = tags.find {|t| t.to_s.start_with? 'heading' }
      if heading_tag
        heading_level = /heading(\d)/.match(heading_tag)[1]
        "<h#{heading_level}>#{content}</h#{heading_level}>"
      else
        "<p class=\"#{parse_line_class(tags)}\">#{content}</p>"
      end
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
          tag.attributes['kind'].value.to_sym
        elsif tag.content === "\t"
          :tab
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
      kind = node.attributes['kind'].value.to_sym
      return '' if HIDDEN_ELEMENTS.include? kind
      return parse_simple_element(kind, node) if SIMPLE_ELEMENTS.has_key?(kind)

      send("parse_element_#{kind}", node)
    end

    def parse_simple_element(kind, node)
      content = parse_content(node.children)
      if (html_tag = SIMPLE_ELEMENTS[kind]) === 'span'
        '<span class="' + snake_case(kind) + '">' + content + '</span>'
      else
        "<#{html_tag}>#{content}</#{html_tag}>"
      end
    end

    def parse_element_link(node)
      attrs   = parse_element_attributes(node)
      content = parse_content(node.children.select{ |child| !child.element? || child.name != 'attribute' })
      '<a href="' + attrs.fetch('URL', '') + '" title="' + attrs.fetch('title', '') + '">' + content + '</a>'
    end

    def parse_element_image(node)
      attrs = parse_element_attributes(node)
      '<img src="' + attrs.fetch('URL', '') + '" alt="' + attrs.fetch('title', '') + '" />'
    end

    def parse_element_video(node)
      attrs = parse_element_attributes(node)
      '<video><source src="' + attrs['URL'] + '" /></video>'
    end

    def parse_element_footnote(node)
      attrs = parse_element_attributes(node)
      @footnotes << attrs['text']
      '<sup class="footnote-ref"><a href="#fn-' + @footnotes.size.to_s + '">' + @footnotes.size.to_s + '</a></sup>'
    end

    def parse_element_annotation(node)
      attrs = parse_element_attributes(node)
      @annotations << attrs['text']
      '<span class="annotation" data-id="' + @annotations.size.to_s + '">' + @annotations.size.to_s + '</span>'
    end

    def parse_element_attributes(element)
      attributes = element.children.select { |child| child.element? && child.name === 'attribute' }
      attributes.map! do |attr|
        [attr.attributes['identifier'].value, parse_content(attr.children)]
      end
      Hash[attributes]
    end

    def snake_case(tag)
      tag.to_s.gsub(/::/, '/')
          .gsub(/([A-Z]+)([A-Z][a-z])/,'\1_\2')
          .gsub(/([a-z\d])([A-Z])/,'\1_\2')
          .gsub(/([a-z])(\d)/i, '\1_\2')
          .tr('-', '_')
          .downcase
    end

    def parse_line_class(tags)
      tabs = tags.count(:tab)
      if tabs > 1
        tags.delete(:tab)
        tags << :"tabs_#{tabs}"
      end
      tags.unshift :line
      tags.uniq.map{ |t| snake_case(t) }.join(' ')
    end

  end
end
