class MusiciansController < ApplicationController
  insta_index Musician do |insta|
    insta.template = 'musician_list'
  end
  insta_show Musician do |insta|
    insta.template = 'musician_show'
  end
  insta_new Musician do |insta|
    insta.template = 'musician_form'
  end
  insta_edit Musician do |insta|
    insta.template = 'musician_form'
  end
  insta_post Musician do |insta|
    insta.template = 'musician_form'
  end
  insta_put Musician do |insta|
    insta.template = 'musician_form'
  end
  insta_delete Musician do |insta|
    insta.template = 'musician_form'
  end
  insta_related Musician do |insta|
    insta.add_related do |related|
      related.display_name = 'Instrument 1'
      related.for_search do |model|
        Instrument.all
      end
      related.display_template = 'template'
    end
  end
end
