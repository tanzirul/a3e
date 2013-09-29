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
    ADB.ignite "com.dropbox.android.activity.DropboxBrowser"
  end

  def test_Login_and_out
    click "I'm new to Dropbox"
    assert_text "Account"
    back # remove soft keyboard
    back
    click "I'm already a Dropbox user"
    assert "Login"
    edit(0,"android.umd@gmail.com")
    edit(1,"umd.android")
    click "Log in"
    sleep(6) # wait for log in
    assert_text "Dropbox"
    menu
    click "Settings"
    assert_text "settings"
    click "Unlink device from Dropbox"
    click "Unlink" # go back to the launcher
    click "I'm already a Dropbox user"
    edit(0,"android.umd@gmail.com")
    edit(1,"umd.android")
    click "Log in"
    sleep(4) # wait for log in
  end

  def test_dropbox
    click "Photos"
    assert_text "Photos"
    click "Sample"
    assert_text "Sample"
    click "Boston"
    sleep(3) # wait for gallery loading
    back
    back
    back
    menu
    click "Help"
    sleep(3) # wait for manual loading
    back
    back
    menu
    click "New"
    assert_text "create"
    click "Text file"
    assert_text "New Text File"
    back # remove soft keyboard
    edit(0,"Hello, DropBox")
    menu
    click "Save file"
    assert_text "File Name"
    edit(0,"test.txt")
    click "OK"
    back
    sleep(2) # waiting for uploading
    assert_text "test.txt"
    clickLong "test.txt"
    assert_text "test.txt"
    click "Delete"
    click "Delete"
    sleep(3) # waiting for deleting
    assert_not_text "test.txt"
  end

  def teardown
    Timeout.timeout(6) do
      acts = getActivities
      finish
      puts acts
    end
  end

end
