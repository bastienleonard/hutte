# -*- coding: utf-8 -*-

# Copyright 2015 Bastien Léonard. All rights reserved.

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

require 'hutte/options_dsl'

module Hutte
  def self.ssh_exec(ssh, command)
    setup = Hutte::OptionsDsl.new(
            callbacks: [:on_stdout, :on_stderr, :on_exit_status_received]
    )
    yield setup

    ssh.open_channel do |channel|
      channel.on_request 'exit-status' do |ch, data|
        status = data.read_long
        setup.on_exit_status_received.call(status)
      end

      # TODO: make the shell configurable (e.g. for FreeBSD)
      channel.exec('bash -l -c "' + command + '"') do |channel, success|
        raise 'Unimplemented error' unless success  # FIXME

        channel.on_data do |channel, data|
          setup.on_stdout.call(data)
        end

        channel.on_extended_data do |channel, type, data|
          setup.on_stderr.call(data)
        end

        # TODO: review other available callbacks
      end
    end.wait
  end
end
