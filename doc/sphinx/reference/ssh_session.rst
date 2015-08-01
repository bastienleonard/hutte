SshSession
==========

.. module:: Hutte

.. class:: SshSession

   .. method:: initialize(user, host)

      Currently, a prompt always asks for a password, even if no
      password is required; in this case the user should press Enter
      without typing a password.

   .. method:: run

      .. todo:: Document SshWrapper, cd, run and so on

      Must be called with a block. It will be passed a DSL object with
      methods such as *run* and *cd*.

      If the block accepts no parameters, its *self* value will be
      bound to the DSL object instead, which allows for a less verbose
      style.
