require 'test_helper'

class OrchestraTest < ActiveSupport::TestCase
  def setup
    @orchestra = Orchestra.make
  end
  
  test "test orchestra search" do
    list = Orchestra.model_search '', {:created_at => '11234'}
  end
  
  test "test locking with sphinx" do
    user = Musician.make
    @orchestra.add_lock user
    @orchestra.remove_lock user
  end
  
  test "test blank page_by_ids" do
    assert_equal [], Orchestra.page_by_ids([])
  end
  
  test "test single page_by_ids" do
    list = WillPaginate::Collection.create 1, 20, 20 do |pager|
      pager.replace [@orchestra.id]
    end
    assert_equal @orchestra, Orchestra.page_by_ids(list).first
  end
  
end