require 'spec_helper'
require 'capybara/rspec'

Capybara.app = Application

feature 'Homepage' do
  before do
    DB[:users].delete
  end

  scenario 'User can Register' do
    visit '/'
    expect(page).to have_content 'Welcome!'
    click_on 'Register'
    fill_in 'Email', :with => 'joe@example.com'
    fill_in 'Password', :with => 'password'
    fill_in 'Password_Confirmation', :with => 'password'
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
    fill_in 'Password_Confirmation', :with => 'password'
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
  scenario 'User attempts to register with blank email address' do
    visit '/'
    expect(page).to have_content 'Welcome!'
    click_on 'Register'
    fill_in 'Email', :with => ''
    fill_in 'Password', :with => ''
    fill_in 'Password_Confirmation', :with => ''
    click_on 'Register'
    expect(page).to have_content 'Email cannot be blank'
  end
  scenario 'User attempts to register with blank email address' do
    visit '/'
    expect(page).to have_content 'Welcome!'
    click_on 'Register'
    fill_in 'Email', :with => 'email@email.com'
    fill_in 'Password', :with => ''
    fill_in 'Password_Confirmation', :with => ''
    click_on 'Register'
    expect(page).to have_content 'Password cannot be blank'
  end
  scenario 'User attempts to register an email that already exists' do
    visit '/'
    click_on 'Register'
    fill_in 'Email', :with => 'joe@example.com'
    fill_in 'Password', :with => 'password'
    fill_in 'Password_Confirmation', :with => 'password'
    click_on 'Register'
    expect(page).to have_content 'Hello, joe@example.com'
    click_on 'Logout'
    click_on 'Register'
    fill_in 'Email', :with => 'joe@example.com'
    fill_in 'Password', :with => 'anything'
    fill_in 'Password_Confirmation', :with => 'anything'
    click_on 'Register'
    expect(page).to have_content 'Email address already exists'
  end
  scenario 'User attempts to register an account with a password less than 3 characters' do
    visit '/'
    click_on 'Register'
    fill_in 'Email', :with => 'joe@example.com'
    fill_in 'Password', :with => '22'
    fill_in 'Password_Confirmation', :with => '22'
    click_on 'Register'
    expect(page).to have_content 'Password must be longer than 2 characters'
  end
  scenario 'Password must match Password Confirmation' do
    visit '/'
    click_on 'Register'
    fill_in 'Email', :with => 'joe@example.com'
    fill_in 'Password', :with => 'password'
    fill_in 'Password_Confirmation', :with => 'notpassword'
    click_on 'Register'
    expect(page).to have_no_content 'Hello, joe@example.com'
    expect(page).to have_content 'Password must match Password Confirmation'
  end
  scenario 'Admin can see Users list' do
    DB[:users].insert(email: 'cheers@cheers.com', password: BCrypt::Password.create('whatever'), admin: true)
    DB[:users].insert(email: 'google.com', password: "password", admin: false)
    DB[:users].insert(email: 'foogle.com', password: "password", admin: false)
    visit '/'
    click_on 'Login'
    fill_in 'Email', :with => 'cheers@cheers.com'
    fill_in 'Password', :with => 'whatever'
    click_on 'Login'
    expect(page).to have_content 'Welcome Admin!'
    click_on 'View all users'
    expect(page).to have_content 'google'
    expect(page).to have_content 'foogle'
    expect(page).to have_content '2'
    expect(page).to have_content '3'
  end
end