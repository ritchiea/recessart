require 'test_helper'

class BlobStructTest < ActiveSupport::TestCase
  def setup
    @blob = BlobStruct.new
  end
  
  test "test adding a new attribute to blob" do
    @blob.name = 'eric'
    assert_equal 'eric', @blob.name
    assert @blob.store
    assert_equal 'eric', @blob.store['name']
  end
  
  test "test adding nothing to blob returns nil" do
    @blob.name = 
    assert_equal nil, @blob.name
  end

  test "test adding a new block to blob" do
    @blob.some_block = lambda{ }
    
    assert @blob.some_block
    assert @blob.some_block.is_a? Proc
  end

  test "test adding a new block without equals to blob" do
    @blob.some_block do
     
    end
    
    assert @blob.some_block
    assert @blob.some_block.is_a? Proc
  end
  
  test "test initing with a hash" do
    hash = {:name => 'Eric', :address => '111 Main Street'}
    blob = BlobStruct.new hash
    assert 'Eric', blob.name
    assert '111 Main Street', blob.address
  end

  test "test id and class" do
    hash = {:id => 'Eric', :class => '111 Main Street'}
    blob = BlobStruct.new hash
    assert 'Eric', blob.id
    assert '111 Main Street', blob.class
  end
end