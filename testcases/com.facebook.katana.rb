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
    ADB.ignite "com.facebook.katana.LoginActivity"
  end

  def test_fb
    click "I agree"
    assert_text "account"
    edit(0,"android.umd@gmail.com")
    edit(1,"umd.android")
    click "Login"
    sleep(2) # wait for log in
    assert_text "tips"
    click "Finish"
    assert_text "Posts" # at news feed view
    clickImg 0 # go to home
    click "Notifications"
    assert_text "notifications"
    back
    clickImg 2 # search
    back # remove soft keyboard
    back
    clickImg 4 # profile
    assert_text "Redexer" # first name :)
    back
    clickImg 5 # friends
    assert_text "Friends"
    back
    clickImg 6 # messages
    assert_text "Messages"
    menu
    click "Compose"
    assert_text "Send"
    click "Discard"
    back
    clickImg 7 # places
    assert_text "Check In"
    click "Check In"
    back # remove soft keyboard
    back
    back
    clickImg 8 # groups
    assert_text "groups"
    back
    clickImg 9 # events
    back
    clickImg 10 # photos
    assert_text "albums"
    menu
    click "Create new"
    assert_text "new album"
    click "Cancel"
    back
    clickImg 11 # chat
    menu
    assert_text "Offline"
    click "Go Offline"
    menu
    click "Settings"
    assert_text "Settings"
    back
    menu
    click "About"
    assert_text "About"
    click "OK"
    menu
    click "Logout"
    assert_text "remove"
    click "Yes"
  end

  def teardown
    Timeout.timeout(6) do
      acts = getActivities
      finish
      puts acts
    end
  end

end
