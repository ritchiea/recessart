include FluxxEngineBlueprint

Musician.blueprint do
  first_name Sham.first_name
  last_name Sham.last_name
  street_address Sham.word
  city Sham.word
  state Sham.word
  zip Sham.word
  date_of_birth Time.now
end

Instrument.blueprint do
  name Sham.word
  price rand(100000)
  date_of_birth Time.now
end


Orchestra.blueprint do
end

User.blueprint do
  email Sham.email
  first_name Sham.first_name
  last_name Sham.last_name
end

MusicianInstrument.blueprint do
end