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

module Hutte
  def self.rsync(ssh, user, host, options)
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
    extra_options = options[:extra_options]

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

    unless extra_options.nil?
      command << ' ' + extra_options
    end

    command << " #{local_dir}"
    command << " #{user}@#{host}:#{remote_dir}"

    ssh.local(command)
  end
end
