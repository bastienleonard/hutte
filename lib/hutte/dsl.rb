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

require 'net/ssh'

require 'hutte/command_failure_exception'
require 'hutte/file'
require 'hutte/local_shell'
require 'hutte/rsync'
require 'hutte/ssh_exec'

# TODO: print errors on stderr?
module Hutte
  class Dsl
    # An easier to use the File methods:
    # Hutte::File.exists?(s, path) becomes file_exists?(path)
    Hutte::File.singleton_methods(false).each do |name|
      define_method "file_#{name}" do |*args|
        Hutte::File.send(name, self, *args)
      end
    end

    def initialize(user, host, ssh, *args)
      options = args.first || {}
      @user = user
      @host = host
      @session = ssh
      @remote_paths = []
      @local_paths = []
      @verbose = options.fetch(:verbose, false)
      @dry_run = options.fetch(:dry_run, false)
    end

    def run(command, *args)
      options = args.first || {}
      output = options.fetch(:output, true) || @verbose
      ok_exit_statuses = options.fetch(:ok_exit_statuses, [0])
      dry_run = options.fetch(:dry_run, @dry_run)
      full_command = command.dup

      @remote_paths.reverse_each do |path|
        full_command = "cd #{path} && #{full_command}"
      end

      printed_command = @verbose ? full_command : command

      if output
        puts "\n   Executing remote command '#{printed_command}'"
      end

      exit_status = nil

      if dry_run
        # FIXME: return ok_exit_statuses.first, in local() as well
        exit_status = 0
      else
        Hutte::ssh_exec(@session, full_command) do |callback|
          callback.on_stdout do |data|
            if output
              puts "[STDOUT] #{data}\n\n"
            end
          end.on_stderr do |data|
            puts "[STDERR] #{data}\n\n"
          end.on_exit_status_received do |status|
            exit_status = status

            if @verbose
              puts "Command exited with status #{exit_status}: #{full_command}"
            end

            unless ok_exit_statuses.include?(status)
              # We include the cds in the command, which will help if one of the
              # cds caused the error
              raise CommandFailureException.new(
                      code: status,
                      command: command
                    )
            end
          end
        end
      end

      exit_status
    end

    def cd(path)
      @remote_paths << path

      if @verbose
        puts "Set the remote working directory to #{path}"
      end

      begin
        yield
      ensure
        @remote_paths.pop
      end

      nil
    end

    def rsync(options)
      Hutte::rsync(self, @user, @host, {
                     verbose: @verbose,
                     dry_run: @dry_run
                   }.merge(options))
    end

    def local(command, *args)
      run_local_command(command, *args)
    end

    # TODO: print dir change
    # TODO: handle dir change failures
    def lcd(path)
      @local_paths << path

      if @verbose
        puts "Set the local working directory to #{path}"
      end

      begin
        yield
      ensure
        @local_paths.pop
      end
    end

    private

    def run_local_command(command, *args)
      options = args.first || {}
      output = options.fetch(:output, true) || @verbose
      ok_exit_statuses = options.fetch(:ok_exit_statuses, [0])
      dry_run = options.fetch(:dry_run, @dry_run)
      full_command = command.dup

      @local_paths.reverse_each do |path|
        full_command = "cd #{path} && #{full_command}"
      end

      printed_command = @verbose ? full_command : command

      if output
        puts "   Executing local command '#{printed_command}'"
      end

      if dry_run
        return 0
      end

      exit_status = LocalShell.run(command) do |callback|
        callback.on_stdout do |data|
          if output
            puts "[STDOUT] #{data}\n\n"
          end
        end.on_stderr do |data|
          puts "[STDERR] #{data}\n\n"
        end
      end

      unless ok_exit_statuses.include?(exit_status)
        # TODO: include cds in the command
        raise CommandFailureException.new(
                code: exit_status,
                command: command
              )
      end

      exit_status
    end
  end
end
