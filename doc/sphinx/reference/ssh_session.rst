SshSession
==========

.. module:: Hutte

.. class:: SshSession

   .. classmethod:: run(user, host, *args)

      *args* can contain at most two values. A string value is
      interpreted as a password; a hash value is interpreted as an
      options hash.

      ::

         Hutte::SshSession.run('user', 'host')
         Hutte::SshSession.run('user', 'host', 'password')
         Hutte::SshSession.run('user', 'host', { verbose: true })
         Hutte::SshSession.run('user', 'host', 'password', {
           dry_run: true
         })

      If no password is provided, a prompt asks the user for a
      password, *even if no password is required*; in this case the
      user should press Enter without typing a password.

      Must be called with a block. It will be passed a :class:`Dsl`
      instance with methods such as :meth:`Dsl#run` and
      :meth:`Dsl#cd`.

      ::

         Hutte::SshSession.run('user', 'host') do |s|
           s.cd '/home' do
             s.run 'pwd'
             s.run 'ls -l'
           end
         end

      If the block accepts no parameters, its *self* value will be
      bound to the DSL object instead, which allows for a less verbose
      style. This is the recommended way, at least for large scripts.

      ::

         Hutte::SshSession.run('user', 'host') do
           cd '/home' do
             run 'pwd'
             run 'ls -l'
           end
         end

      If you have an SSH config file (e.g. in ``~/.ssh/config``), it
      can be used by passing its ``Host`` value instead of the actual
      hostname. The username should be nil if it is to be deduced from
      a config file (``''`` won't work). Not all options can be read,
      see
      https://net-ssh.github.io/ssh/v2/api/classes/Net/SSH/Config.html.

      Options include:

      * ``dry_run``: run the script normally, but don't actually run
        any commands. :meth:`Dsl#rsync` is the exception: the rsync
        program will be called, but with the ``--dry_run`` option
        (which can also be accomplished with :meth:`Dsl#rsync`'s
        ``dry_run`` option). Note that this mode is pretty limited:
        commands will always succeed and won't produce any
        output. False by default.
      * ``verbose``: print additional information, may be useful for
        debugging. False by default.
      * ``characters_to_escape``: an array of characters that should
        be escaped (by prepending them with ``\``) before running the
        command. Currently, only double quotes are escaped by default.
      * ``shell``: this is effectively a way to wrap the command in
        another string, though the goal is to select the shell and its
        options. ``false`` can be passed; this will execute the
        command without any "wrapping". Occurences of ``{{command}}``
        will be replaced by the command to be executed. ``bash -l -c
        "{{command}}"`` by default.
