# frozen_string_literal: true

require 'test_helper'

class AdminSmokeTest < ActionDispatch::IntegrationTest
  setup do
    get '/users/sign_in'
    assert_response :success
    post '/users/sign_in',
         params: {user: {email: 'admin@wehub.com', password: 'testadmin'}}
    assert_response :redirect
    follow_redirect!
    assert_response :success
    assert_equal 'Signed in successfully.', flash[:notice]
    assert_select 'div', 'Signed in successfully.'
  end

  test 'base index pages' do
    %w[expeditions organisations users choices surveys locations roles].each do |item|
      puts "Testing index #{item}"
      get "/#{item}"
      assert_response :success
    end
  end

  test 'base edit pages home' do
    %w[expeditions organisations users choices surveys locations roles].each do |item|
      puts "Testing edit #{item}"
      m = item.singularize.classify.constantize
      get "/#{item}/#{m.first.id}/edit"
      assert_response :success
    end
  end

  test 'base show pages home' do
    %w[expeditions organisations users choices surveys locations roles].each do |item|
      puts "Testing show #{item}"
      m = item.singularize.classify.constantize
      get "/#{item}/#{m.first.id}"
      assert_response :success
    end
  end
end
