class MusicianInstrument < ActiveRecord::Base
  belongs_to :musician
  belongs_to :instrument
  
  insta_realtime do |insta|
    insta.after_realtime do |model, params|
      model.musician.trigger_realtime_update if model.musician
      model.instrument.trigger_realtime_update if model.instrument
    end
  end
  
end
