require 'machinist/active_record'
require 'sham'

require 'faker'

module FluxxEngineBlueprint
ATTRIBUTES = {}

  def self.included(base)
    # For faker formats see http://faker.rubyforge.org/rdoc/

    Sham.document { Tempfile.new('the attached document') }
    Sham.word { Faker::Lorem.words(2).join '' }
    Sham.words { Faker::Lorem.words(3).join ' ' }
    Sham.sentence { Faker::Lorem.sentence }
    Sham.company_name { Faker::Company.name }
    Sham.first_name { Faker::Name.first_name }
    Sham.last_name { Faker::Name.last_name }
    Sham.login { "#{rand(999999)}_#{Faker::Internet.user_name}" }
    Sham.email { "#{rand(999999)}_#{Faker::Internet.email}" }
    Sham.url { "http://#{Faker::Internet.domain_name}/#{Faker::Lorem.words(1).first}"  }
    
    def random_email
      "#{rand(999999)}_#{Faker::Internet.email}"
    end
    def random_login
      "#{rand(999999)}_#{Faker::Internet.user_name}"
    end
    def random_first_name
      "#{rand(999999)}_#{Faker::Name.first_name}"
    end
    def random_last_name
      "#{rand(999999)}_#{Faker::Name.last_name}"
    end
    def random_word
      "#{rand(999999)}_#{Faker::Lorem.words(2).join ''}"
    end
    def random_words
      "#{rand(999999)}_#{Faker::Lorem.words(3).join ' '}"
    end
    def random_sentence
      "#{rand(999999)}_#{Faker::Lorem.sentence}"
    end
    
    RealtimeUpdate.blueprint do
      action 'create'
      model_id 1
      type_name 'Musician'
      model_class 'Musician'
      delta_attributes ''
    end

    MultiElementGroup.blueprint do
    end
    MultiElementValue.blueprint do
    end
    ClientStore.blueprint do
      name random_word
      client_store_type random_word
    end
  
    base.extend(ModelClassMethods)
    base.class_eval do
      include ModelInstanceMethods
    end
  end

  module ModelClassMethods
  end
  
  module ModelInstanceMethods
    def rand_nums
      "#{(99999999/rand).floor}#{Time.now.to_i}"
    end

    def generate_word
      "#{Sham.word}_#{rand_nums}"
    end
    
    def bp_attrs
      ATTRIBUTES
    end
  end
end