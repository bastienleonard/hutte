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

require 'highline/import'

require 'hutte/dsl'

module Hutte
  class SshSession
    def self.run(*args, &block)
      self.new(*args).run(&block)
    end

    def initialize(user, host, *args)
      @user = user
      @host = host
      @password = args.find { |x| x.is_a?(String) }
      options = args.find { |x| x.is_a?(Hash) } || {}
      @verbose = options.fetch(:verbose, false)
      @dry_run = options.fetch(:dry_run, false)
      @characters_to_escape = options.fetch(:characters_to_escape, %w("))
      @shell = options.fetch(:shell, 'bash -l -c "{{command}}"')
    end

    def run(&block)
      Net::SSH.start(
        @host,
        @user,
        # TODO: use IO#getpass()
        password: @password || prompt("Password for #{@user}@#{@host}")
      ) do |ssh|
        wrapper = dsl(ssh)

        if block.arity == 0
          wrapper.instance_eval(&block)
        else
          block.call(wrapper)
        end
      end

      nil
    end

    def dsl(ssh = nil)
      Hutte::Dsl.new(
        @user, @host, ssh || @session,
        dry_run: @dry_run,
        verbose: @verbose,
        characters_to_escape: @characters_to_escape,
        shell: @shell
      )
    end

    private

    def prompt(message, *args)
      options = args.first || {}
      echo = options.delete(:echo)
      ask("#{message}: ") do |q|
        q.echo = echo
      end
    end

    # TODO: remove
    def start
      @session = Net::SSH.start(
        @host,
        @user,
        password: @password || prompt("Password for #{@user}@#{@host}")
      )
      finalizer = proc do
        STDERR.puts(
          "Warning: SshSession object hasn't been properly cleaned up by calling stop()"
        ) unless @session.closed?
      end

      ObjectSpace.define_finalizer(
        @session,
        finalizer
      )
    end

    def stop
      @session.close
    end
  end
end
