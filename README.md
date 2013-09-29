Troyd
=====

Troyd is an integration testing framework for Android apps.  This tool
can test apps while interacting with testers via a command-line interface;
generate scenario-based tests by recording tester commands; and repeat
generated tests as regression tests.

Publications
------------

* [Troyd: Integration Testing for Android.][tr]
  Jinseong Jeon and Jeffrey S. Foster.
  CS-TR-5013, Department of Computer Science, University of Maryland, College Park, Aug 2012.

[tr]: http://hdl.handle.net/1903/12880

Requirements
------------

To get started, install [Android SDK][sdk] first and set paths to Android
base tools, e.g., adb, aapt, etc.  You can do so by adding the followings
to your profile:

    ANDROID_HOME=$HOME/sdk # your own path here!
    export ANDROID_HOME

    PATH=$ANDROID_HOME/tools:$PATH
    PATH=$ANDROID_HOME/platform-tools:$PATH
    export PATH

The main scripts are written in [Ruby][rb] and require [RubyGems][gem], a Ruby
package manager, and [Nokogiri][xml], an XML library to manipulate
manifest files.  This tool is tested under Ruby 1.8.7 and Android 2.3.6.

[rb]: http://www.ruby-lang.org/
[sdk]: http://developer.android.com/sdk/index.html
[gem]: http://rubygems.org/
[xml]: http://nokogiri.org/

Recording
---------

You can either record your commands (to generate testcases)

    $ ruby bin/rec.rb target.apk [options]

or just run commands without recording.

    $ ruby bin/rec.rb target.apk --no-rec [options]

This script starts an emulator (if no real device is connected), rebuilds
Troyd, a controller app, resigns the app under test, installs both the
controller and target apps on the emulator or real device; launches the app,
and then gives a prompt.  At this point, you can control the target app via 
the commands.  Note that all of your commands would be placed at a Ruby unit
testing code.  So, please stick to Ruby grammar, and don't forget quotation
marks for text.  Commands supported by Troyd are as follows:

    > getViews
    > getActivities
    > back
    > down
    > up
    > menu
    > edit(idx,"text")
    > clear "text"
    > click "text"
    > clickOn x.y
    > clickLong "text"
    > clickIdx idx
    > clickImg idx
    > clickItem(idx, item)
    > drag("x.y", "x.y")

In addition to basic assertions in Ruby unit testing, Troyd offers
the following assertions:

    > assert_text "text"
    > assert_not_text "text"
    > assert_checked "text"
    > assert_died
    > assert_ads

Their detailed meanings are explained in our tech. report.
For each meaningful testing scenario, name it:

    > sofar "name"

Then, the script restarts the target app, and the commands you typed
so far become a testcase named "test_name".

The following command stops all the recording, generates testcases,
kills the emulator (if used), and cleans up everything:

    > finish

For instance, suppose you're generating a testcase for the scenario that
clicking the "Refuse" button in the TOS page of ASTRO would stop the app.
First, start Troyd with ASTRO app.

    $ ruby bin/rec.rb com.metago.astro.apk

If you're using a device, it may take a couple of minutes to set up.
Otherwise, this script generates a new virtual device and start an emulator,
which takes much longer than real devices, of course.

If you can see the below prompt, then it's ready to record your commands:

    > 

According to the scenario, you may type the following commands:

    > click "Refuse"

Then, the script actually clicks "Refuse" text on the screen, and kills
the app.  We'd like to check whether the app is indeed finished or not.
Hence, place an assertion like this:

    > assert_died

To finish this scenario, we need to name it somehow.  Since Ruby's unit
test cases are run in alphabetic order, a recommendation is to use capital
letters if you'd like to give priority to certain test cases.  In this
example, once we click "Accept", we won't see the TOS page again.
That is, this refusing scenario should be conducted before everything else;
hence name it a word starting with a capital letter, like this:

    > sofar Refuse

The commands recorded so far would be placed as a testcase as follows:

    def test_Refuse
      click "Refuse"
      assert_died
    end

After finishing the recording by typing the finish command, you may find
the auto-geranted Ruby script, testcases/com.metago.astro.rb, which has
the above testcase.

Other generated testcases (in testcases directory) would be helpful
to learn how to use above commands.

Replaying
---------

Once you recorded test cases, the target apk files and test cases will be
placed at apks and testcases directories, respectively, with the same package
name.  You can run all the test cases:

    $ ruby bin/trun.rb [options]

or particular ones:

    $ ruby bin/trun.rb --only pkg1,pkg2 [options]

Note that its default option for avd is "-no-window", which means,
you would not see any pop-up screen for emulators.

This script automatically generates a new emulator, and then, for each
testcase, rebuilds Troyd, resigns the app, and runs the testcase.
After finishing regression tests, it cleans up all remnants.

