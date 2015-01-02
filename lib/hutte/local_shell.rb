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

module Hutte
  # TODO: refactor, make it more friendly for one-shot shells since that's how
  # we use it now
  class LocalShell
    def initialize
      @pid, @stdin, @stdout, @stderr = Open4::popen4('sh')
    end

    def self.run(command, *args)
      begin
        shell = self.new
        shell.run(command, *args)
      ensure
        shell.cleanup unless shell.nil?
      end
    end

    def run(command, *args)
      options = args.empty? ? {} : args[0]
      dirs = options[:cd]

      unless dirs.nil?
        unless dirs.is_a?(Enumerable)
          dirs = [dirs]
        end

        dirs.each do |dir|
          @stdin.puts("cd #{dir}")
        end
      end

      @stdin.puts(command)
      @stdin.close
      [@stdout.read, @stderr.read]
    end

    def cleanup
#      @stdin.close
      @stdin = nil
      @stdout = nil
      @stderr.close
      @stderr = nil
      pid_, status = Process::waitpid2(@pid)
    end
  end
end
