## Copyright (c) 2011-2012,
##  Jinseong Jeon <jsjeon@cs.umd.edu>
##  Jeff Foster   <jfoster@cs.umd.edu>
## All rights reserved.
##
## Redistribution and use in source and binary forms, with or without
## modification, are permitted provided that the following conditions are met:
##
## 1. Redistributions of source code must retain the above copyright notice,
## this list of conditions and the following disclaimer.
##
## 2. Redistributions in binary form must reproduce the above copyright notice,
## this list of conditions and the following disclaimer in the documentation
## and/or other materials provided with the distribution.
##
## 3. The names of the contributors may not be used to endorse or promote
## products derived from this software without specific prior written
## permission.
##
## THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
## AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
## IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
## ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
## LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
## CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
## SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
## INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
## CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
## ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
## POSSIBILITY OF SUCH DAMAGE.

module Troyd
  TROYD = File.dirname(__FILE__)

  TD   = "troyd"
  TDIR = TROYD + "/../" + TD

  QUIET = " > /dev/null 2>&1"

  def Troyd.setenv
    aup = "android update project"
    system("#{aup} -t android-10 -p #{TDIR} #{QUIET}")
  end

  require "#{TROYD}/resign"
  require "#{TROYD}/adb"

  def Troyd.rebuild(pkg)
    ADB.uninstall
    system("cd #{TDIR}; ant clean #{QUIET}")
    rename(pkg)
    system("cd #{TDIR}; ant debug #{QUIET}")
    dbg = TDIR + "/bin/#{TD}-debug.apk"
    apk = TDIR + "/bin/#{TD}.apk"
    Resign.resign(dbg, apk)
    ADB.install apk
  end

private

  require 'nokogiri'

  META = TDIR + "/AndroidManifest.xml"

  ROOT = "/manifest"
  INST = ROOT + "/instrumentation"
  TAGT = "android:targetPackage"

  def Troyd.rename(pkg)
    f = File.open(META, 'r')
    doc = Nokogiri::XML(f)
    f.close

    inst = doc.xpath(INST)
    inst.each do |instr|
      instr[TAGT] = pkg
    end

    f = File.open(META, 'w')
    doc.write_xml_to(f)
    f.close
  end
end
