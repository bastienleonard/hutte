File
====

.. module:: Hutte

.. note::

   Each of these methods are forwarded to :class:`Dsl`, e.g. you can
   use ``dsl.file_exists?(path)`` instead ``File.exists?(dsl, path)``.

.. class:: File

   Remote file utilities. The Unix notion of file is used here, where
   a directory is considered as a special kind of file.

   This class is effectively a wrapper around the `test utility
   <http://pubs.opengroup.org/onlinepubs/9699919799/utilities/test.html>`_.

   .. classmethod:: exists?(dsl, path)

      Return true if *path* exists.

   .. classmethod:: is_dir?(dsl, path)

      Return true if *path* is a directory.

   .. classmethod:: has_content?(dsl, path)

      Return true if *path* has a size greater than zero.

   .. classmethod:: is_link?(dsl, path)

      Return true if *path* is symbolic link.

   .. classmethod:: is_readable?(dsl, path)

      Return true if read permission is granted for *path*.

   .. classmethod:: is_writable?(dsl, path)

      Return true if write permission is granted for *path*.

   .. classmethod:: is_executable?(dsl, path)

      Return true if execute (or search) permission is granted for *path*.

   .. classmethod:: is_socket?(dsl, path)

      Return true if *path* is a socket.

   .. classmethod:: test(dsl, test_flag, path)

      Call the `test utility
      <http://pubs.opengroup.org/onlinepubs/9699919799/utilities/test.html>`_
      on the remote server, passing *test_flag* (e.g. '-s') and *path*
      as arguments.

      Return the result of the evaluation. This may be somewhat
      confusing, as the test utility returns 0 if the expression
      evaluated to true.  As an example, ``test(dsl, '-e',
      '/some/path')`` would return true if */some/path* exists.

      The other methods all call this one with the appropriate *flag*
      value. This method is intended as a way to use the less common
      flags.
