require 'spec_helper'
require 'capybara/rspec'

Capybara.app = Application

feature 'Homepage' do
  before do
    DB[:users].delete
  end

  scenario 'Shows the welcome message' do
    visit '/'

    expect(page).to have_content 'Welcome!'
    click_on 'Register'
    fill_in 'Email', :with => 'joe@example.com'
    fill_in 'Password', :with => 'password'
    click_on 'Register'
    expect(page).to have_content 'Hello, joe@example.com'
    click_on 'Logout'
    expect(page).to have_content 'Welcome!'
    click_on 'Login'
    fill_in 'Email', :with => 'joe@example.com'
    fill_in 'Password', :with => 'password'
    click_on 'Login'
    expect(page).to have_content 'Hello, joe@example.com'

  end
  scenario 'User can not sign in with invalid email' do
    visit '/'
    click_on 'Login'
    fill_in 'Email', :with => 'hello'
    fill_in 'Password', :with => 'whatever'
    click_on 'Login'
    expect(page).to have_no_content 'Hello, hello'
    expect(page).to have_content 'Invalid email or password'
  end
  scenario 'User attempts to login with incorrect password' do
    visit '/'
    click_on 'Register'
    fill_in 'Email', :with => 'joe@example.com'
    fill_in 'Password', :with => 'password'
    click_on 'Register'
    expect(page).to have_content 'Hello, joe@example.com'
    click_on 'Logout'
    click_on 'Login'
    fill_in 'Email', :with => 'joe@example.com'
    fill_in 'Password', :with => 'incorrect_password'
    click_on 'Login'
    expect(page).to have_content 'Invalid email or password'
    expect(page).to have_no_content 'Hello, joe@example.com'

  end
end