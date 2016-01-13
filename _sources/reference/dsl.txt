Dsl
===

.. module:: Hutte

.. class:: Dsl

   The block you pass to :meth:`SshSession.run` is given an instance
   of this class, and this is the main API in Hutte.

   This class conveniently includes the methods from the :class:`File`
   class, e.g. ``dsl.file_exists?(path)`` will call
   :meth:`File.exists?`.

   .. method:: cd(path)

      Change the remote directory.

      This doesn't have any immediate effect. A block with remote
      commands should be passed; their working directory will be
      changed as intended.

      Calls to this method can be nested::

        cd '/home' do
          run 'pwd' # Prints /home
          cd 'bastien' do
            run 'pwd' # Prints /home/bastienn
            run 'ls'  # Prints the content of /home/bastien
          end
        end

   .. method:: dsl

      Call the given block with *self* bound to this :class:`Dsl` object.

      Useful when decomposing the program into functions::

        def print_home(s)
          s.dsl do
            # Note we don't need to write ``s.run''
            run 'ls -l /home'
          end
        end

        Hutte::SshSession.run('user', 'host') do
          print_home(self)
        end

   .. method:: lcd(path)

      Same as :meth:`cd`, but locally.

   .. method:: local(command[, options])

      Execute *command* (a string) locally, blocking until it is
      completed and return a :class:`CommandResult` instance.

      Options include:

      * ``output``: whether the output of the command should be
        printed (currently, the content of stderr is always
        printed). True by default.
      * ``ok_exit_statuses``: an array of process exit statuses that
        indicate success. [0] by default.
      * ``dry_run``: the value you set in :class:`SshSession`'s
        options. May be overriden.
      * ``verbose``: the value you set in :class:`SshSession`'s
        options. May be overriden.

   .. method:: rsync(options)

      Call the rsync tool to synchronize a local directory with the
      server.

      *options* is a hash that must include the following keys:

      * ``remote_dir``: the remote directory that will be synced.
      * ``local_dir``: the local directory that will be synced. Add a
        trailing ``/`` if you want the content of ``local_dir`` to be
        dropped inside ``remote_dir``. Otherwise, rsync will place the
        files at ``remote_dir/local_dir``.

      These keys are optional:

      * ``exclude``: an array of strings for the paths that rsync
        should ignore, using a ``--exclude`` option for each item in
        the array. [] by default.
      * ``delete``: pass the ``--delete`` options to rsync. Of course,
        you should be very careful with this. False by default.
      * ``dry_run``: pass the ``--dry_run`` options to rsync. False by default.
        Please note that unfortunately, rsync will still perform some checks. For
        example, it will raise an error if a directory doesn't exist.
      * ``verbose``: pass the ``--verbose`` options to rsync. False by default.
      * ``extra_options``: a string that will be appended to the rsync
        command.

   .. method:: run(command[, options])

      Execute *command* (a string) on the server, blocking until it is
      completed and return a :class:`CommandResult` instance.

      .. highlight:: none

      The final command will look like this::

         bash -l -c "{escaped_command}"

      .. highlight:: ruby

      Options include:

      * ``output``: whether the output of the command should be
        printed (currently, the content of stderr is always
        printed). True by default.
      * ``ok_exit_statuses``: an array of process exit statuses that
        indicate success. [0] by default.
      * ``dry_run``: the value you set in :class:`SshSession`'s
        options. May be overriden.
      * ``verbose``: the value you set in :class:`SshSession`'s
        options. May be overriden.
      * ``characters_to_escape``: the value you set in :class:`SshSession`'s
        options. May be overriden.
      * ``shell``: the value you set in :class:`SshSession`'s
        options. May be overriden.
