# auto-generated via bin/rec.rb
require 'test/unit'
require 'timeout'

class TroydTest < Test::Unit::TestCase

  SCRT = File.dirname(__FILE__) + "/../bin"
  require "#{SCRT}/cmd"
  include Commands

  def assert_text(txt)
    found = search txt
    assert(found.include? "true")
  end

  def assert_not_text(txt)
    found = search txt
    assert(found.include? "false")
  end

  def assert_checked(txt)
    check = checked txt
    assert(check.include? "true")
  end

  def assert_died
    assert_raise(Timeout::Error) {
      Timeout.timeout(6) do
        getViews
      end
    }
  end

  def assert_ads
    found = false
    views = getViews
    views.each do |v|
      found = found || (v.include? "AdView")
    end
    assert(found)
  end

  def setup
    ADB.ignite "com.pandora.android.Main"
  end

  def test_sign_in_out_and_station
    click "Continue"
    assert_text "Welcome"
    click "I am new to Pandora"
    assert_text "Account"
    back # remove input method
    back # back to previous activity
    click "I have a Pandora account"
    assert_text "Password"
    click "forgot"
    assert_text "Email my Password"
    back
    edit(0,"android.umd@gmail.com")
    edit(1,"umd.android")
    click "Sign In"
    sleep(3) # wait for signing in
    menu
    click "Create"
    assert_text "artist"
    edit(0,"Darren Hayes")
    click "Search"
    sleep(9) # wait for loading station
    assert_text "ads"
    menu
    click "Preferences"
    click "Sign Out"
    click "I have a Pandora account"
    edit(0,"android.umd@gmail.com")
    edit(1,"umd.android")
    click "Sign In"
    sleep(3) # wait for signing in
    assert_text "Darren Hayes"
    clickLong "Darren Hayes"
    click "Delete"
    assert_not_text "Darren Hayes"
  end

  def teardown
    Timeout.timeout(6) do
      acts = getActivities
      finish
      puts acts
    end
  end

end
