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

require 'hutte/local_paths_manager'
require 'hutte/local_shell'
require 'hutte/ssh_wrapper'
require 'hutte/command_failure_exception'

module Hutte
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

      # TODO: find how to get stderr
      if output && !result.output.rstrip.empty?
        puts "[STDOUT] #{result.output.rstrip}\n\n"
      end

      if result.error?
        raise CommandFailureException.new
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

      stdout, stderr, exit_code = LocalShell.run(
                command,
                :cd => @local_paths_manager.paths
              )

      if output && !stdout.empty?
        puts "[STDOUT] #{stdout}\n"
      end

      # TODO: print on stderr?
      unless stderr.empty?
        puts "[STDERR] #{stderr}\n"
      end

      if exit_code != 0
        raise CommandFailureException.new(
                :code => exit_code
              )
      end

      [stdout, stderr]
    end
  end
end
