# Welcome to Hutte

This is a Ruby library that enables you to execute arbitrary commands
on a remote server through SSH, as well as on your local machine.
This is useful for automating various tasks, such as deployments.

Hutte doesn't assume anything about what you want to execute.  This
makes it trivial to customize your tasks, unlike more complex tools.

Hutte aims to be a sort of port of [Fabric](http://www.fabfile.org/).
As such, its API is very close.

This is currently in alpha stage, I'm mostly experimenting and trying
to see what's the best way to provide this kind of API in
Ruby. However I maintain a stable branch in an attempt to prevent new
features from introducing bugs in your projects.

## Example

```ruby
require 'hutte'

Hutte::SshSession.run('user', 'host') do |ssh|
  # Execute some local commands, from /tmp
  ssh.lcd '/tmp' do
    ssh.local 'pwd'
    ssh.local 'ls -l'
  end

  # Execute some remote commands, from /home
  ssh.cd '/home' do
    ssh.run 'pwd'
    ssh.run 'ls -l'
  end

  # Use Rsync to synchronize a directory
  ssh.rsync(
    remote_dir: '/some/remote/dir',
    local_dir: '/some/local/dir',
    delete: false,
    exclude: %w(test a b c)
  )
end
```

If you get tired of always typing `ssh.something`, you can drop the block
parameter.
Then the block will be invoked with `self` referring to the same object as
`ssh` in the previous example:

```ruby
Hutte::SshSession.run('user', 'host') do
  cd '/tmp' do
    run 'pwd'
  end
end
```