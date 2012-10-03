require 'test_helper'

class CurlyParserTest < ActiveSupport::TestCase
  test "test parsing a document" do
    document = "  <html>
      <body>
        How are you {{value variable='user' method='first_name'/}}?
        I see that your birthday is {{value variable='user' method='birthday'/}}.
        {{iterator method='children' from_variable='user' variable='child' as_entity='user'}}
          {{value variable='child' method='first_name'/}}
          {{value variable='child' method='last_name'/}}
        {{/iterator}}
      
      </body>
      </html>
    "
    c = CurlyParser.new
    a = c.parse document
    assert_equal 7, a.size
    assert_equal TextToken, a.first.class
    iterator_token = a[5]
    assert_equal CurlyToken, iterator_token.class
  end
end