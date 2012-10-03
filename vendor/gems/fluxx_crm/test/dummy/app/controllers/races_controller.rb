class RacesController < ApplicationController
  insta_show Race do |insta|
    insta.template = 'race_show'
    insta.add_workflow
  end
  insta_put Race do |insta|
    insta.template = 'race_form'
    insta.add_workflow
  end
end
