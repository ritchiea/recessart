

class CurlyParser
  
  def parse document
    tokens = tokenize document
    response = build_tree(tokens)
    response.first if response
  end
  
  MAX_LEVEL=100
  def build_tree tokens, offset=0, tree=[], level=0
    return if level==MAX_LEVEL
    while offset<tokens.length && offset >= 0 && tokens[offset] && !tokens[offset].is_closing_tag?
      cur_token = tokens[offset]
      tree << cur_token
      offset += 1
      if cur_token.is_open_tag?
        children, offset = build_tree tokens, offset, [], level+1 
        cur_token.add_children children
      end
    end
    [tree, offset+1]
  end
  
  def tokenize document
    elements = document.scan /(\{\{.+?\}\})/
    token_elements = elements.map do |element| 
      element_string = element.flatten.first
      [element_string, create_token(element_string)]
    end
    all_tokens = []
    last_html = token_elements.inject(document) do |doc, element_pair|
      element, token = element_pair
      offset = doc.index element
      all_tokens << TextToken.new(doc[0..offset-1]) if offset > 0 && doc
      all_tokens << token
      doc && doc[(offset + element.size)..doc.length]
    end
    all_tokens << TextToken.new(last_html) if last_html
    all_tokens
  end
  
  def create_token element
    element_name, attribute_hash, open_status = process_curly element
    CurlyToken.new element_name, attribute_hash, open_status
  end
  
  def process_curly element
    a = element.scan /\{\{(.*?)\}\}/
    element_text = (a ? a.compact.flatten.first : element).strip
    open_status = if element_text[0..0] == '/'
      :closing
    elsif element_text[(element_text.length-1)..(element_text.length-1)] == '/'
      :closed
    else
      :open
    end
    token_content = (element_text).strip
    element_name = token_content.split(' ').first
    attribute_string = token_content.scan /#{element_name}\s?(.*)/
    attribute_hash = attribute_string.flatten.first.scan(/(.*?)\s?=\s?['"](.*?)['"]/).inject({}) do |acc, name_value| 
      name = name_value[0].strip if name_value.length > 0
      value = name_value[1].strip  if name_value.length > 1
      acc[name] = value if name
      acc
    end
    [element_name, attribute_hash, open_status]
  end
end

class CurlyToken
  def initialize element_name, attributes, open_status='closed'
    @element_name = element_name
    @attributes = attributes
    @open_status = open_status
    @children = []
  end
  
  def element_name
    @element_name
  end
  
  def attributes
    @attributes
  end
  
  # Tag opens and closes itself {{value/}}
  def is_tag_closed?
    @open_status == :closed
  end

  # Tag opens and closes itself {{/value}}
  def is_closing_tag?
    @open_status == :closing
  end

  # Tag opens and closes itself {{value}}
  def is_open_tag?
    @open_status == :open
  end

  def children
    @children
  end
  
  def add_children children_param
    @children = @children + children_param
  end
  
  def add_child element
    @children << element
  end
  
  def clear_children
    @children.clear
  end
end

class TextToken < CurlyToken
  attr_accessor :text
  def initialize text
    super 'text', {}
    self.text = text
  end
end

