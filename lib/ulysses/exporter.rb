module Ulysses
  class Exporter

    def initialize(sheet_xml)
      @xml   = Nokogiri::XML sheet_xml
      @coder = HTMLEntities.new
      @annotations = []
      @footnotes   = []
    end

    def to_html
      tree = xml_to_tree @xml.xpath('/sheet/string[@xml:space="preserve"]')
      html = tree_to_html tree
      html = parse_prefix_tags(html)
      html = append_footnotes(html)
      html = append_annotations(html)
      Kramdown::Document.new(html).to_html
    end

    private

    def xml_to_tree(xml)
      xml.children.map do |child|
        if child.text?
          child.content
        elsif child.element?
          {
              name: child.name,
              attributes: Hash[child.attribute_nodes.map { |an| [an.node_name, an.content] }],
              children: child.children.length > 0 ? xml_to_tree(child) : []
          }
        else
          raise "Unknown node type: #{child.class}"
        end
      end
    end

    def tree_to_html(tree)
      html = ''
      tree.each do |node|
        if node.is_a?(String)
          html += @coder.encode node
        else
          case node[:name]
            when 'p'
              html += p_to_html node
            when 'tags'
              html += tree_to_html(node[:children])
            when 'tag'
              html += prefix_tag_to_placeholder node
            when 'element'
              html += element_to_html(node)
            when 'attribute'
              html += attribute_to_html(node)
            when 'string'
              html += string_to_html(node)
            else
              raise "Unknown tree node type: #{node[:name]}"
          end
        end
      end
      html
    end

    def p_to_html(node)
      if node[:children].any?
        tree_to_html(node[:children])
      else
        ''
      end
    end

    def inline_tag_to_html(node, tag, attr = nil)
      open_tag = attr.nil? ? "<#{tag} #{attr}>" : "<#{tag}>"
      if node[:children].any?
        open_tag + tree_to_html(node[:children]) + "</#{tag}>"
      else
        "#{open_tag}</#{tag}>"
      end
    end

    def link_to_html(link)
      string = '<a'
      text = ''
      link[:children].each do |child|
        if child.is_a? String
          text = child
        else
          identifier = child[:attributes]['identifier']
          case
            when 'URL'
              string += ' url="'+ child[:children].first + '"'
            when 'title'
              string += ' title="'+ child[:children].first + '"'
            else
              raise "unknown link attr identifier #{identifier}"
          end
        end
      end
      string + '>' + text + '</a>'
    end

    def image_to_html(node)
      html = '<img'
      node[:children].each do |child|
        case child[:attributes]['identifier']
          when 'URL'
            html += ' url="'+ child[:children].first + '"'
          when 'title'
            html += ' title="'+ child[:children].first + '"'
          else
            # skip
        end
      end
      html + ' />'
    end

    def video_to_html(node)
      source = ''
      node[:children].each do |child|
        case child[:attributes]['identifier']
          when 'URL'
            source = child[:children].first
          else
            # skip
        end
      end
      '<video><source src="' + source + '"></video>'
    end

    def element_to_html(node)
      case node[:attributes]['kind']
        when 'strong'
          inline_tag_to_html(node, 'strong')
        when 'emph'
          inline_tag_to_html(node, 'em')
        when 'mark'
          inline_tag_to_html(node, 'span', 'class="marked"')
        when 'delete'
          inline_tag_to_html(node, 'del')
        when 'inlineComment'
          inline_tag_to_html(node, 'span', 'class="comment"')
        when 'code'
          inline_tag_to_html(node, 'code')
        when 'inlineNative'
          inline_tag_to_html(node, 'span', 'class="native"')
        when 'link'
          link_to_html(node)
        when 'annotation'
          @annotations << [node[:children].last, tree_to_html(node[:children].first[:children])]
          "<placeholder-annotation-#{@annotations.size - 1}/>"
        when 'image'
          image_to_html(node)
        when 'video'
          video_to_html(node)
        when 'footnote'
          string_node = node[:children].first[:children].first
          @footnotes << tree_to_html(string_node[:children])
          "<placeholder-footnote-#{@footnotes.size - 1}/>"
        else
          raise node
      end
    end

    def prefix_tag_to_placeholder(node)
      case node[:attributes]['kind']
        when 'codeblock'
          string = '<<prefix-tag-code-block>>'
        when 'comment'
          string = '<<prefix-tag-comment>>'
        when 'divider'
          string = '<hr class="divider" />'
        when 'nativeblock'
          string = '<<prefix-tag-native-block>>'
        when 'blockquote'
          string = '<<prefix-tag-block-quote>>'
        when 'orderedList'
          string = node[:children].first
        when 'unorderedList'
          string = node[:children].first
        when 'heading1'
          string = '<<prefix-tag-heading-1>>'
        when 'heading2'
          string = '<<prefix-tag-heading-2>>'
        when 'heading3'
          string = '<<prefix-tag-heading-5>>'
        when 'heading4'
          string = '<<prefix-tag-heading-4>>'
        when 'heading5'
          string = '<<prefix-tag-heading-5>>'
        when 'heading6'
          string = '<<prefix-tag-heading-6>>'
        else
          if node[:attributes].empty? && node[:children].first == "\t"
            string = "\t"
          else
            raise node
          end
      end
      string
    end

    def attribute_to_html(node)
      case node[:attributes]['identifier']
        when 'text'
          html = tree_to_html node[:children]
        else
          raise "Unknown attribute node type: #{node[:attributes]['identifier']}"
      end
      html
    end

    def string_to_html(node)
      case node[:attributes]['space']
        when 'preserve'
          html = tree_to_html node[:children]
        else
          raise "Unknown string node: #{node[:attributes]['space']}"
      end
      html
    end

    def parse_prefix_tags(html)
      lines = html.split("\n")

      prefix_tags = []
      lines = lines.map do |line|
        if /\A<<(prefix-tag[a-z0-9\-]+)>>(.*)\Z/i.match line
          prefix_tags << $1
          "<#{$1}>" + $2 + "</#{$1}>"
        else
          line
        end
      end

      html = lines.join("\n")
      prefix_tags.uniq.each do |prefix|
        case prefix
          when 'prefix-tag-code-block'
            html_tag = 'pre-code'
          when 'prefix-tag-native-block'
            html_tag = 'pre-raw'
          when 'prefix-tag-comment'
            html_tag = 'should-delete'
          when 'prefix-tag-block-quote'
            html_tag = 'blockquote'
          when /\Aprefix-tag-heading-(\d)\Z/i
            html_tag = "h#{$1}"
          else
            raise "Unknown prefix tag: #{prefix}"
        end
        html.gsub! %r/(<\/?)#{prefix}>/, "\\1#{html_tag}>"
        html.gsub! %r/<\/#{html_tag}>(\n*)<#{html_tag}>/, "\\1"
      end

      html.gsub! /<should-delete>.*<\/should-delete>\n?/, ''

      html.gsub! /<pre-code>/, '<pre><code>'
      html.gsub! /<\/pre-code>/, '</code></pre>'

      html.gsub! /<pre-raw>/, '<p class="raw">'
      html.gsub! /<\/pre-raw>/, '</p>'

      html
    end

    def append_footnotes(html)
      return html if @footnotes.empty?
      footnote_html = '<div class="footnotes">'
      @footnotes.each_with_index do |fn, index|
        html.gsub! /<placeholder-footnote-#{index}\/>/, "<sup><a href=\"#fn#{index}\" id=\"ref#{index}\">#{index}</a></sup>"
        footnote_html += "<sup id=\"fn#{index}\">#{index}. " + fn + '</sup>'
      end
      html + "\n\n" + footnote_html + "</div>\n"
    end

    def append_annotations(html)
      return html if @annotations.empty?
      annotations_html = '<div class="annotations">'
      @annotations.each_with_index do |at, index|
        html.gsub! /<placeholder-annotation-#{index}/, "<span class=\"annotated\" data-annotation=\"#{index}\">#{at[0]}</span>"
        annotations_html += "<section data-annotation=\"#{index}\">" + at[1] + '</section>'
      end
      html + "\n\n" + annotations_html + "</div>\n"
    end

  end
end
