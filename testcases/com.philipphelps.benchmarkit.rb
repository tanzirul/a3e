# auto-generated via bin/rec.rb
require 'test/unit'

class TroydTest < Test::Unit::TestCase

  SCRT = File.dirname(__FILE__) + "/../bin"
  require "#{SCRT}/cmd"
  include Commands

  def setup
    ADB.ignite "com.philipphelps.benchmarkit.BenchmarkItActivity"
  end

  def test_contacts
    click "Contacts"
    edit(0,"100")
    click "Go"
    sleep(1)
  end

  def test_internet
    click "Internet"
    # already hard-coded
    # edit(0,"http://cs.umd.edu/")
    # edit(1,"100")
    click "Go"
    sleep(16)
  end

  def test_location
    click "Fine Location"
    edit(0,"10")
    click "Go"
    sleep(20)
  end

  def test_settings
    click "Settings"
    edit(1,"1000")
    click "Go"
    sleep(2)
  end

  def teardown
    finish
  end

end
