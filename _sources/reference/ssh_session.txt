SshSession
==========

.. module:: Hutte

.. class:: SshSession

   .. classmethod:: run(user, host[, options])

      Currently, a prompt always asks for a password, even if no
      password is required; in this case the user should press Enter
      without typing a password.

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

      Options include:

      * ``dry_run``: run the script normally, but don't actually run
        any commands. :meth:`Dsl#rsync` is the exception: the rsync
        program will be called, but with the ``--dry_run`` option
        (which can also be accomplished with :meth:`Dsl#rsync`'s
        ``dry_run`` option). Commands will always succeed, so it's not
        always possible to test all possibilities with this
        option. False by default.
      * ``verbose``: print additional information, may be useful for
        debugging. False by default.
