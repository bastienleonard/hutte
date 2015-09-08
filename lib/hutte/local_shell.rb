# -*- coding: utf-8 -*-

# Copyright 2014, 2015 Bastien Léonard. All rights reserved.

# Redistribution and use in source and binary forms, with or without
# modification, are permitted provided that the following conditions are
# met:

#    1. Redistributions of source code must retain the above copyright
#       notice, this list of conditions and the following disclaimer.

#    2. Redistributions in binary form must reproduce the above
#       copyright notice, this list of conditions and the following
#       disclaimer in the documentation and/or other materials provided
#       with the distribution.

# THIS SOFTWARE IS PROVIDED BY BASTIEN LÉONARD ``AS IS'' AND ANY EXPRESS
# OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
# WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
# DISCLAIMED. IN NO EVENT SHALL BASTIEN LÉONARD OR CONTRIBUTORS BE
# LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
# CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
# SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR
# BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY,
# WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE
# OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN
# IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

require 'open4'

require 'hutte/options_dsl'

module Hutte
  class LocalShell
    def initialize(command)
      @command = command
      @pid, @stdin, @stdout, @stderr = Open4::popen4('sh')
      @setup = Hutte::OptionsDsl.new(
        callbacks: [:on_stdout, :on_stderr]
      )
      yield @setup
    end

    def self.run(command, &block)
      self.new(command, &block).run
    end

    def run
      @stdin.puts(@command)
      @stdin.close
      @stdin = nil

      begin
        loop do
          begin
            s = @stdout.read_nonblock(1024)
            @setup.on_stdout.call(s)
          rescue IO::WaitReadable
          end

          begin
            s = @stderr.read_nonblock(1024)
            @setup.on_stderr.call(s)
          rescue IO::WaitReadable
          end

          sleep(0.1)
        end
      rescue EOFError
      end

      @stdout.close
      @stdout = nil
      @stderr.close
      @stderr = nil
      pid_, status = Process::waitpid2(@pid)
      status.exitstatus
    end
  end
end
