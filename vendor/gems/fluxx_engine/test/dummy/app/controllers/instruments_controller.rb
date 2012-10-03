class InstrumentsController < ApplicationController
  def self.add_test_headers insta, format_type = :html
    insta.pre do |controller_dsl|
      response.headers[:pre_invoked] = true
    end
    insta.post do |controller_dsl|
      response.headers[:post_invoked] = true
    end
    insta.format do |format|
      format.send(format_type) do |triple|
        controller_dsl, outcome, default_block = triple
        response.headers[:format_invoked] = true
        render :text => 'howdy'
      end
    end
  end

  insta_index Instrument do |insta|
    InstrumentsController.add_test_headers insta, :xml
    insta.template = 'instrument_list'

  end
  insta_show Instrument do |insta|
    InstrumentsController.add_test_headers insta
    insta.template = 'instrument_show'
  end
  insta_new Instrument do |insta|
    InstrumentsController.add_test_headers insta
    insta.template = 'instrument_form'
  end
  insta_edit Instrument do |insta|
    InstrumentsController.add_test_headers insta
    insta.template = 'instrument_form'
  end
  insta_post Instrument do |insta|
    InstrumentsController.add_test_headers insta
    insta.template = 'instrument_form'
  end
  insta_put Instrument do |insta|
    InstrumentsController.add_test_headers insta
    insta.template = 'instrument_form'
  end
  insta_delete Instrument do |insta|
    InstrumentsController.add_test_headers insta
    insta.template = 'instrument_form'
  end
  
  insta_report
  
end
