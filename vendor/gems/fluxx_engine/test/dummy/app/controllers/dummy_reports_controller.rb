class DummyReportsController < ApplicationController
  insta_show Instrument do |insta|
    insta.template = 'instrument_show'
  end
  insta_report
end
