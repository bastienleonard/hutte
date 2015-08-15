Introduction
------------

This is a Ruby library that enables you to execute arbitrary commands
on a remote server through SSH, as well as on your local machine. This
is useful for automating various tasks, such as deployments.

Hutte doesn't assume anything about what you want to execute. This
makes it trivial to customize your tasks, unlike more complex tools.

This is currently in alpha stage, I'm mostly experimenting and trying
to see what's the best way to provide this kind of API in
Ruby. However I maintain a stable branch in an attempt to prevent new
features from introducing bugs in your projects.

Hutte aims to be a sort of port of `Fabric
<http://www.fabfile.org>`_. As such, its API is very close.  Here is a
quick example::

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
