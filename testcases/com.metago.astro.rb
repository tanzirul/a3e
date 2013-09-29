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
    ADB.ignite "com.metago.astro.FileManagerActivity"
  end

  def test_Refuse
    click "Refuse"
    assert_died
  end

  def test_ads_and_exit
    click "Accept"
    assert_ads
    menu
    click "More"
    click "Exit"
    assert_died
  end

  def test_menu_etc
    menu
    click "Bookmarks"
    assert_text "Bookmarks"
    back
    menu
    click "More"
    click "Help"
    assert_text "Help"
    back
    menu
    click "More"
    click "Preferences"
    assert_text "Preferences"
    clickIdx 2 # click "Toolbar Preferences"
    assert_text "Toolbar"
    back
    click "Cache"
    assert_text "Thumbnail"
    back
    click "Edit File Extensions"
    assert_text "Extension"
  end

  def test_navi
    click "Up"
    click "Up"
    click "Up"
    assert_text "system"
    click "Home"
    assert_text "sdcard"
    menu
    click "More"
    click "Navigation"
    click "Home"
    assert_text "sdcard"
  end

  def test_details
    click "Up"
    clickLong "sdcard"
    assert_text "Details"
    click "Details"
    click "OK"
  end

  def test_search_refresh
    click "Search"
    edit(0,"STH_UNEXPECTED")
    back
    click "Search"
    assert_not_text "STH_UNEXPECTED"
  end

# TODO: need sliding top menu
#  def test_sftp
#    click "Network"
#    click "New"
#    click "SFTP"
#    click "Test"
#    assert_text "localhost"
#    assert_text "refused"
#  end

  def test_icons
    menu
    click "View"
    click "Change View"
    click "Icons"
    menu
    click "View"
    click "Change View"
    assert_checked "Icons"
    click "List"
    menu
    click "View"
    click "Change View"
    assert_checked "List"
  end

  def test_app
    menu
    click "Tools"
    click "Application"
    assert_text "Application"
    menu
    click "Preferences"
    assert_text "Preferences"
    back
    clickLong "Troyd"
    assert_text "Details"
    click "Details"
  end

  def test_sd_usage
    menu
    click "Tools"
    click "Usage"
    assert_text "sdcard"
    assert_ads
  end

  def test_proc
    menu
    click "Tools"
    click "Process"
    assert_text "Process"
    assert_ads
    menu
    click "Settings"
    assert_text "Remove"
    click "Remove"
  end

  def teardown
    Timeout.timeout(6) do
      acts = getActivities
      finish
      puts acts
    end
  end

end
