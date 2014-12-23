# -*- coding: utf-8 -*-

# Copyright 2014 Bastien Léonard. All rights reserved.

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

require 'hutte/version'

require 'highline/import'
require 'net/ssh/session'
require 'open4'

module Hutte
  class SshSession
    def initialize(user, host, *args)
      @user = user
      @host = host
    end

    def run
      wrapper = SshWrapper.new(
        @user,
        @host,
        prompt("Password for #{@user}@#{@host}"))
      yield wrapper
      nil
    ensure
      unless wrapper.nil?
        wrapper.cleanup
      end
    end

    private

    def prompt(message, **options)
      echo = options.delete(:echo)
      ask("#{message}: ") do |q|
        q.echo = echo
      end
    end
  end

  # FIXME: check command failure
  class SshWrapper
    def initialize(user, host, password)
      @user = user
      @host = host
      @session = Net::SSH::Session.new(host, user, password)
      @session.open
      @local_paths_manager = LocalPathsManager.new
    end

    def cleanup
      @session.close
    end

    def run(command, *args)
      options = args.empty? ? {} : args[0]
      output = options.delete(:output)
      output = true if output.nil?

      if output
        puts "   Executing remote command '#{command}'"
      end

      result = @session.run(command)

      if output && !result.output.rstrip.empty?
        puts "[STDOUT] #{result.output.rstrip}\n\n"
      end

      result.output
    end

    # TODO: check behavior when the block raises an error
    # TODO: find an easier to normalise command component (don't use chomp
    # everywhere)
    def cd(path)
      old_pwd = run('pwd', :output => false)
      old_pwd = old_pwd.chomp
      run("cd #{path}", :output => false)
      yield
      run("cd #{old_pwd.chomp}", :output => false)
      nil
    end

    # TODO: don't ask password again
    def rsync(options)
      # TODO: probably should raise an error if remote_dir or local_dir are
      # absent

      remote_dir = options[:remote_dir]
      local_dir = options[:local_dir]
      exclude = options[:exclude]
      delete = options[:delete]

      if delete.nil?
        delete = false
      end

      command = 'rsync -pthrv' # --rsh='ssh -p 22'

      unless exclude.nil?
        unless exclude.is_a?(Enumerable)
          exclude = [exclude]
        end

        exclude = exclude.map do |path|
          "--exclude #{path}"
        end.join(' ')

        command << " #{exclude}"
      end

      if delete
        command << ' --delete'
      end

      command << " #{local_dir}"
      command << " #{@user}@#{@host}:#{remote_dir}"
      local(command)
    end

    # TODO: print dir change
    def local(command, *args)
      run_local_command(command, args)
    end

    # TODO: print dir change
    # TODO: test what happens if block throws exception
    def lcd(path)
      @local_paths_manager.add(path)
      yield
      @local_paths_manager.pop
    end

    private

    def run_local_command(command, *args)
      options = args.empty? ? {} : args[0]
      output = options.delete(:output) || true

      if output
        puts "   Executing local command '#{command}'"
      end

      stdout, stderr = LocalShell.run(
                command,
                :cd => @local_paths_manager.paths
              )

      # puts "pid        : #{ pid }"
      # puts "stdout     : #{ stdout.read.strip }"
      # puts "stderr     : #{ stderr.read.strip }"
      # puts "status     : #{ status.inspect }"
      # puts "exitstatus : #{ status.exitstatus }"

      if output && !stdout.empty?
        puts "[STDOUT] #{stdout}\n"
      end

      # TODO: print on stderr?
      unless stderr.empty?
        puts "[STDERR] #{stderr}\n"
      end

      [stdout, stderr]
    end
  end

  class LocalPathsManager
    attr_reader :paths

    def initialize
      @paths = []
    end

    def add(path)
      @paths << path
    end

    def pop
      @paths.pop
    end

    def current
      @paths.last
    end
  end

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
