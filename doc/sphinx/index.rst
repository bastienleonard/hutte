.. Hutte documentation master file, created by
   sphinx-quickstart on Mon Jul 27 23:08:58 2015.
   You can adapt this file completely to your liking, but it should at least
   contain the root `toctree` directive.

Welcome to Hutte's documentation!
=================================

This is a Ruby library that enables you to execute arbitrary commands
on a remote server through SSH, as well as on your local machine. This
is useful for automating various tasks, such as deployments.

Hutte doesn't assume anything about what you want to execute. This
makes it trivial to customize your tasks, unlike more complex tools.

Hutte aims to be a sort of port of `Fabric
<http://www.fabfile.org>`_. As such, its API is very close.

This is currently in alpha stage, I'm mostly experimenting and trying
to see what's the best way to provide this kind of API in
Ruby. However I maintain a stable branch in an attempt to prevent new
features from introducing bugs in your projects.

Example::

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

Contents:

.. toctree::
   :maxdepth: 2

   reference/index

Indices and tables
==================

* :ref:`genindex`
* :ref:`modindex`
* :ref:`search`

