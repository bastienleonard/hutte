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

require 'hutte/ssh_exec'

module Hutte
  # Note: all the public/protected class methods defined in this class
  # will end as file_* instance methods on SshWrapper
  class File
    def self.test(ssh, test_flag, path)
      ssh.run(
        "test #{test_flag} #{path}",
        :output => true,
        :ok_exit_statuses => [0, 1]
      ) == 0
    end

    def self.exists?(ssh, path)
      self.test(ssh, '-e', path)
    end

    def self.is_dir?(ssh, path)
      self.test(ssh, '-d', path)
    end

    def self.has_content?(ssh, path)
      self.test(ssh, '-s', path)
    end

    def self.is_link?(ssh, path)
      self.test(ssh, '-L', path)
    end

    def self.is_readable?(ssh, path)
      self.test(ssh, '-r', path)
    end

    def self.is_writable?(ssh, path)
      self.test(ssh, '-w', path)
    end

    def self.is_executable?(ssh, path)
      self.test(ssh, '-x', path)
    end

    def self.is_socket?(ssh, path)
      self.test(ssh, '-S', path)
    end
  end
end
