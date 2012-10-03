require 'test_helper'

class ControllerDslShowTest < ActiveSupport::TestCase
  def setup
    @dsl_show = ActionController::ControllerDslShow.new Musician
  end

  test "check that we can perform_show" do
    @musician = Musician.make
    new_musician = @dsl_show.perform_show({:id => @musician.id})
    assert new_musician
    assert new_musician.is_a? Musician
  end
  
  test "check that we can calculate_show_options" do
    @musician = Musician.make
    @dsl_show.template = 'template'
    @dsl_show.footer_template = 'footer_template'
    options = @dsl_show.calculate_show_options @musician, {}
    
    assert_equal 'template', options[:template]
    assert_equal 'footer_template', options[:footer_template]
  end
  
  test "check that we can calculate_show_options with audit_id" do
    @musician = Musician.make
    @dsl_show.template = 'template'
    @dsl_show.audit_template = 'audit_template'
    @dsl_show.footer_template = 'footer_template'
    @dsl_show.audit_footer_template = 'audit_footer_template'
    @dsl_show.footer_template = 'footer_template'
    options = @dsl_show.calculate_show_options @musician, {:audit_id => 1}
    
    assert_equal 'audit_template', options[:template]
    assert_equal 'audit_footer_template', options[:footer_template]
    assert_equal @musician.id, options[:full_model].id
  end

  
  test "check that we can calculate_show_options with mode" do
    @musician = Musician.make
    @dsl_show.template = 'template'
    @dsl_show.mode_template = {'candy' => 'mode_template'}
    @dsl_show.footer_template = 'footer_template'
    @dsl_show.footer_template = 'footer_template'
    options = @dsl_show.calculate_show_options @musician, {:mode => 'candy'}
    
    assert_equal 'mode_template', options[:template]
    assert_equal 'footer_template', options[:footer_template]
  end
end

