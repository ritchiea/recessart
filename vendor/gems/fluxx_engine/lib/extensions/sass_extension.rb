require 'sass'
module Sass::Script::Functions
  
  # TODO ESH: use this to allow paths and asset image delivery
  def inline_image src
    # Sass::Script::String.new("url('#{path_to_image(src.to_s)}')")
    Sass::Script::String.new("url(#{src.to_s})")
  end
    
end
