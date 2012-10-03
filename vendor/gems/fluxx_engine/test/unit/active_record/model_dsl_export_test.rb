require 'test_helper'

class ModelDslExportTest < ActiveSupport::TestCase
  def setup
    @dsl_export = ActiveRecord::ModelDslExport.new Musician
  end
  
  test "test csv_sql_query" do
    @dsl_export.sql_query = 'query'
    assert_equal 'query', @dsl_export.csv_sql_query
  end

  test "test csv_sql_query with proc" do
    entered_block = false
    local_with_clause = {:name => 'fred'}
    @dsl_export.sql_query = (lambda do |with_clause|
      assert_equal local_with_clause, with_clause
      entered_block = true
      'lambda_query'
    end)
    assert_equal 'lambda_query', @dsl_export.csv_sql_query(local_with_clause)
    assert entered_block
  end

  test "test missing csv_headers that fall back on the class columns" do
    headers = @dsl_export.csv_headers
    assert headers
    assert headers.size > 1
    assert headers.include? 'first_name'
  end

  test "test csv_headers" do
    local_headers = ['first_name', 'last_name']
    @dsl_export.headers = local_headers
    assert_equal local_headers, @dsl_export.headers
    assert_equal local_headers, @dsl_export.csv_headers
  end

  test "test csv_headers with proc" do
    entered_block = false
    local_with_clause = {:name => 'fred'}
    @dsl_export.headers = (lambda do |with_clause|
      assert_equal local_with_clause, with_clause
      entered_block = true
      'lambda_header'
    end)
    assert_equal 'lambda_header', @dsl_export.csv_headers(local_with_clause)
    assert entered_block
  end

  test "test csv_filename" do
    @dsl_export.filename = 'query'
    assert_equal 'query', @dsl_export.csv_filename
  end

  test "test csv_filename with proc" do
    entered_block = false
    local_with_clause = {:name => 'fred'}
    @dsl_export.filename = (lambda do |with_clause|
      assert_equal local_with_clause, with_clause
      entered_block = true
      'lambda_filename'
    end)
    assert_equal 'lambda_filename', @dsl_export.csv_filename(local_with_clause)
    assert entered_block
  end
end