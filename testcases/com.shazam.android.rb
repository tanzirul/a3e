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
    ADB.ignite "com.shazam.android.Splash"
  end

  def test_ads
    click "Setup"
    sleep(6)
    click "My Tags"
    assert_ads
    click "Chart"
    assert_ads
    click "Blog"
    assert_ads
    assert_text "Shazamers"
  end

  def test_tagging
    menu
    click "Tag Now"
    sleep(11)
    assert_text "Sorry"
    assert_ads
  end

  def test_settings
    menu
    click "Settings"
    click "Payment"
    assert_text "Upgrade"
    back
    click "Facebook"
    assert_text "Logout"
    click "OK"
    click "About Shazam"
    assert_text "Shazam"
  end

  def teardown
    Timeout.timeout(6) do
      acts = getActivities
      finish
      puts acts
    end
  end

end
