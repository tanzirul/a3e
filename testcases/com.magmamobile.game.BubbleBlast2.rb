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
    ADB.ignite "com.magmamobile.game.BubbleBlast2.Main"
  end

  def test_ads
    click "No"
    click "Close"
    clickImg 0
    assert_ads
    back
    menu
    click "Magma Mobile News"
    assert_text "News"
    back
    clickImg 1
    assert_text "Settings"
  end

  def teardown
    Timeout.timeout(6) do
      acts = getActivities
      finish
      puts acts
    end
  end

end
