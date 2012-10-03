require 'test_helper'

class ModelDslTemplateTest < ActiveSupport::TestCase
  def setup
  end
  
  test "test ability to add multi element to a class" do
    
    
    # TODO ESH:
    #  In the DSL, we need an iterator that expects the result of a method to be a list.
    #  What if we have a way to declare other variables as well:
    #    {{declare variable='musician' method='first_instrument' new_variable='musicians_first_instrument'}}
    # That would add a binding for as a context object to allow users to reference objects within a related object
    # The other way to do it would be to have some kind of dot notation that we use to dereference a method
    # that is available as the result of another method call
    
    template = "
    <html>
      <body>
      MDY: {{value variable='today' as='date_mdy'/}}
      FULL: {{value variable='today' as='date_full'/}}
       How are you {{value variable='musician' method='first_name'/}}?
        So your first instrument was the {{value variable='musician' method='first_instrument.name' convert_linebreaks='false'/}}, I like to play that too!
        I see that your name backwards is {{value variable='musician' method='first_name_backwards'/}}.
        <table>
        <tr>
          <td>name</td>
          <td>date_of_birth</td>
        </tr>
        {{iterator method='instruments' new_variable='instrument' variable='musician'}}
          <tr>
            {{if variable='instrument' method='name' is_blank='true'}}
              INSIDE_FALSE_IF_STATEMENT{{value variable='instrument' method='name'/}}
            {{/if}}
              <td>{{value variable='instrument' method='name'/}}</td>
            <td>{{value variable='instrument' method='date_of_birth' as='date_mdy'/}}</td>
            * Currency: {{value variable='instrument' method='price' as='currency' unit='*'/}}
            $ Currency: {{value variable='instrument' method='price' as='currency'/}}
          </tr>
        {{/iterator}}
        {{if variable='musician' method='first_name' is_blank='true'}}
          {{else}}
          WE_ARE_IN_THE_ELSE_CLAUSE
          {{/else}}
        {{/if}}
          Before template:
        {{template file_name='musicians/_musician_show.html.haml' variable='musician' local_variable_name='model'/}}
          After template:
      </body>
      </html>
    "
    
    first_instrument = Instrument.make :name => "Brightest Instrument\n\nIn Town"
    musician = Musician.make :first_instrument => first_instrument
    (1..4).to_a.each do |i|
      instrument = Instrument.make
      MusicianInstrument.make :instrument => instrument, :musician => musician
    end
    musician.reload
    
    result = musician.process_curly_template template, Object.new
    assert result.index "So your first instrument was the #{first_instrument.name}"
    assert result.index "I see that your name backwards is #{musician.first_name_backwards}"
    musician.instruments.each do |instrument|
      assert result.index "<td>#{instrument.name}</td>"
      assert result.index "<td>#{instrument.date_of_birth.mdy}</td>"
      assert !result.index("INSIDE_FALSE_IF_STATEMENT#{instrument.name}")
    end
    assert result.index("WE_ARE_IN_THE_ELSE_CLAUSE")
    offset = result.index("Before template:")
    template_part = result[offset..result.length-1]
    assert template_part.index musician.first_name
    assert template_part.index musician.last_name
    assert template_part.index musician.street_address
  end
end
