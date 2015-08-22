# Welcome to Hutte

A super simple and flexible Ruby DSL for writing scripts that execute
on remote servers, through SSH. This is useful for automating various
tasks, such as deployments.

Hutte aims to be a sort of port of [Fabric](http://www.fabfile.org/).
As such, its API is very close.

This is currently in alpha stage, I'm mostly experimenting and trying
to see what's the best way to provide this kind of API in
Ruby. However, I maintain a stable branch in an attempt to prevent new
features from introducing bugs in your projects. Please note that
stable is currently massively lagging behind master.

## Documentation

Documentation for the master branch is available here:
https://bastienleonard.github.io/hutte

Make sure you read the
[Caveats](https://bastienleonard.github.io/hutte/caveats.html) page!

## Bug tracker

https://github.com/bastienleonard/hutte/issues

## Example

```ruby
require 'hutte'

Hutte::SshSession.run('user', 'host') do
  # Execute some local commands, from /tmp
  lcd '/tmp' do
    local 'pwd'
    local 'ls -l'
  end

  # Execute some remote commands, from /home
  cd '/home' do
    run 'pwd'
    run 'ls -l'
  end

  # Use Rsync to synchronize a directory
  rsync(
    remote_dir: '/some/remote/dir',
    local_dir: '/some/local/dir',
    delete: false,
    exclude: %w(test a b c)
  )
end
```
