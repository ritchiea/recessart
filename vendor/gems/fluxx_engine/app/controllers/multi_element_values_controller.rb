class MultiElementValuesController < ApplicationController
  insta_index MultiElementValue do |insta|
    insta.results_per_page = 1200
  end
end