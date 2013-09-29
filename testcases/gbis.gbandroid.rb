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
    ADB.ignite "gbis.gbandroid.InitScreen"
  end

  def test_gb
    click "Yes, Log In"
    back # to remove soft keyboard
    edit(0,"redexer")
    edit(1,"umd.android")
    click "Log in"
    assert_text "gas prices"
    clickImg 2 # settings
    assert_text "Preferences"
    back
    clickImg 4 # favorite stations
    assert_text "Favorites"
    back
    clickImg 5 # Win Gas
    assert_text "Win"
    click "Learn More"
    assert_text "points"
    click "Recent Winners"
    assert_text "Winners"
    back
    back
    back
    clickImg 3 # view profile
    assert_text "Profile"
    menu
    click "Upload"
    assert_text "Photo"
    back
    back
    clickImg 1 # search
    click "Tap"
    assert_text "Regular"
    menu
    click "Map View"
    sleep(2) # wait for map view
    back
    clickIdx 0
    assert_text "Diesel"
    clickImg 1 # station image
    back
    menu
    click "Report Price"
    assert_text "Time"
    back
    menu
    click "Upload"
    assert_text "Photo"
    back
    menu
    click "Add to Favorite"
    assert_text "list"
    back
    menu
    click "Search"
    assert_text "Search"
    back
  end

  def teardown
    Timeout.timeout(6) do
      acts = getActivities
      finish
      puts acts
    end
  end

end
