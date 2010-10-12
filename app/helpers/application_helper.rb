module ApplicationHelper
  def haml_cdata(&block)
    text = capture_haml(&block)

    # You only need two spaces of indentation because Haml will automatically
    # indent the text you return properly
    text.gsub!("\n", "\n  ")

    "<![[CDATA\n  #{text}\n]]>"
  end
  
end
