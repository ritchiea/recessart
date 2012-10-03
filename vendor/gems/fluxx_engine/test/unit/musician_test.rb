require 'test_helper'

class MusicianTest < ActiveSupport::TestCase
  def setup
    @musician = Musician.make
  end
  
  test "test musician search" do
    list = Musician.model_search ''
  end
  
  test "test locking without sphinx" do
    user = Musician.make
    @musician.add_lock user
    @musician.remove_lock user
  end
end