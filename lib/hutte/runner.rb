#! /usr/bin/env ruby
# -*- coding: utf-8 -*-

# Copyright 2019 Bastien Léonard. All rights reserved.

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

def host(host)
  GLOBAL_CONFIG.host = host
end

def user(user)
  GLOBAL_CONFIG.user = user
end

def password(password)
  GLOBAL_CONFIG.password = password
end

def task(name, &proc)
  if name.is_a?(String)
    name = name.to_sym
  end

  # TODO: try to detect any collisions
  if Kernel.methods.include?(name)
    raise "Not defining task #{name} because a builtin method has this name " +
          "(i.e. Kernel.#{name} exists)"
  end

  puts "Defining task #{name}"
  Hutte::Runner::Task.add_task(Hutte::Runner::Task.new(name, proc))
  nil
end

def method_missing(name, *args)
  if Hutte::Runner::Task.include?(name)
    Hutte::Runner::Task.run_task(name, GLOBALS.session, *args)
  else
    super
  end
end

module Hutte::Runner
  class GlobalConfig
    attr_accessor :host, :user, :password, :session
  end

  class Task
    @@tasks = {}

    attr_reader :name, :proc

    def self.validate_name(name)
      unless name.is_a?(Symbol)
        raise "name must be a symbol, found #{name.class}"
      end
    end

    private_class_method :validate_name

    def self.include?(name)
      validate_name(name)
      @@tasks.has_key?(name)
    end

    def self.add_task(task)
      validate_name(task.name)
      @@tasks[task.name] = task
      nil
    end

    def self.run_task(name, session, *args)
      validate_name(name)
      puts "Running task #{name} with args #{args}"
      result = session.instance_eval(&@@tasks[name].proc)

      unless result.nil?
        puts "  -> #{result.inspect}"
      end
    end

    def initialize(name, proc)
      self.class.send(:validate_name, name)

      if proc.nil?
        raise "proc can't be nil"
      end

      @name = name
      @proc = proc
    end
  end
end
