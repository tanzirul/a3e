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

class AVD
  def initialize(avd, opt="")
    @avd = avd
    @opt = opt
  end

  ADR = "android"
  AL = ADR + " list"

  def exists?
    `#{AL} avd`.include? @avd
  end

  def delete
    system("#{ADR} delete avd -n #{@avd}")
  end

  A10 = ADR + "-10"
  AOPT = "-s WQVGA432" # resolution option

  def create
    delete
    system("echo | #{ADR} create avd -n #{@avd} -t #{A10} #{AOPT}")
  end

  EM = "emulator"
  OPT = "-cpu-delay 0 -netfast -no-snapshot-save"

  def start
    system("#{EM} -avd #{@avd} #{OPT} #{@opt} &")
  end

  ARM = EM + "-arm"

  def stop
    p = RUBY_PLATFORM.downcase
    system("pkill #{ARM}")            if p.include? "linux"
    system("killall #{ARM}")          if p.include? "darwin"
    system("taskkill /IM #{ARM}.exe") if p.include? "mswin"
  end
end
