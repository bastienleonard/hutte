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

require 'hutte/local_shell'
require 'hutte/command_failure_exception'
require 'hutte/ssh_exec'

# TODO: print errors on stderr?
module Hutte
  class SshWrapper
    def initialize(user, host, password)
      @user = user
      @host = host
      # TODO: refactor API to use the block versionof start(), to have
      # automatic cleanup
      @session = Net::SSH.start(host, user, password: password)
      @remote_paths = []
      @local_paths = []
    end

    def cleanup
      @session.close unless @session.closed?
    end

    def run(command, *args)
      options = args.empty? ? {} : args[0]
      output = options.fetch(:output, true)
      ok_exit_statuses = options.fetch(:ok_exit_statuses, [0])

      if output
        puts "\n   Executing remote command '#{command}'"
      end

      # TODO: include the cds in the output?
      @remote_paths.reverse_each do |path|
        command = "cd #{path} && #{command}"
      end

      exit_status = nil

      Hutte::ssh_exec(@session, command) do |callback|
        callback.on_stdout do |data|
          if output
            puts "[STDOUT] #{data}\n\n"
          end
        end.on_stderr do |data|
          puts "[STDERR] #{data}\n\n"
        end.on_exit_status_received do |status|
          exit_status = status

          unless ok_exit_statuses.include?(status)
            # We include the cds in the command, which will help if one of the
            # cds caused the error
            raise CommandFailureException.new(
                    :code => status,
                    :command => command
                  )
          end
        end
      end

      exit_status
    end

    # TODO: print dir change
    def cd(path)
      @remote_paths << path

      begin
        yield
      ensure
        @remote_paths.pop
      end

      nil
    end

    def rsync(options)
      missing_options = [:local_dir, :remote_dir].reject do |name|
        options.has_key?(name)
      end

      unless missing_options.empty?
        raise ArgumentError.new(
                'Call to rsync() lacks the following required parameters: ' +
                missing_options.join(', ')
              )
      end

      remote_dir = options[:remote_dir]
      local_dir = options[:local_dir]
      exclude = options.fetch(:exclude, [])
      delete = options.fetch(:delete, false)
      dry_run = options.fetch(:dry_run, false)

      command = 'rsync -pthrv' # --rsh='ssh -p 22'

      exclude = exclude.map do |path|
        "--exclude #{path}"
      end.join(' ')

      unless exclude.empty?
        command << " #{exclude}"
      end

      if delete
        command << ' --delete'
      end

      if dry_run
        command << ' --dry-run'
      end

      command << " #{local_dir}"
      command << " #{@user}@#{@host}:#{remote_dir}"
      local(command)
    end

    def local(command, *args)
      run_local_command(command, *args)
    end

    # TODO: print dir change
    # TODO: handle dir change failures
    def lcd(path)
      @local_paths << path

      begin
        yield
      ensure
        @local_paths.pop
      end
    end

    private

    def run_local_command(command, *args)
      options = args.empty? ? {} : args[0]
      output = options.fetch(:output, true)
      ok_exit_statuses = options.fetch(:ok_exit_statuses, [0])

      if output
        puts "   Executing local command '#{command}'"
      end

      stdout, stderr, exit_code = LocalShell.run(
                command,
                :cd => @local_paths
              )

      if output && !stdout.empty?
        puts "[STDOUT] #{stdout}\n"
      end

      unless stderr.empty?
        puts "[STDERR] #{stderr}\n"
      end

      unless ok_exit_statuses.include?(exit_code)
        # TODO: include cds in the command
        raise CommandFailureException.new(
                :code => exit_code,
                :command => command
              )
      end

      [stdout, stderr]
    end
  end
end
