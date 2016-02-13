module Ulysses
  class Printer

    def parse_element_strong(node)
      '<strong>' + node.content + '</strong>'
    end

    def parse_element_emph(node)
      '<em>' + node.content + '</em>'
    end

    def parse_element_mark(node)
      '<span class="marked">' + node.content + '</span>'
    end

    def parse_element_delete(node)
      '<del>' + node.content + '</del>'
    end

    def parse_element_inlineComment(node)
      '<span class="inline-comment">' + node.content + '</span>'
    end

    def parse_element_code(node)
      '<code>' + node.content + '</code>'
    end

    def parse_element_inlineNative(node)
      '<span class="inline-native">' + node.content + '</span>'
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
      '<sup class="footnote-ref"><a href="#fn' + @footnotes.size.to_s + '">' + @footnotes.size.to_s + '</a></sup>'
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

  end
end
