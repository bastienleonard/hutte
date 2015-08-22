Caveats
-------

Here are the caveats that I consider as the most important, roughly in
order of priority.


DSL inconsistency
^^^^^^^^^^^^^^^^^

The DSL kind of falls apart when you want to break code into
methods, e.g.::

   Hutte::SshSession.run('user', 'host') do
     setup(self)
     sync_code(self)
     restart(self)
   end

   def setup(dsl)
     dsl.run '...'
   end

   def sync_code(self)
     dsl.run '...'
   end

   def restart(self)
     dsl.run '...'
   end


Passwordless authentication
^^^^^^^^^^^^^^^^^^^^^^^^^^^

Authentication currently isn't very smart. If you don't specify ``''``
as the password, a prompt will always ask for one, even there's no
need for one (in that cas, just press Enter).


Interactive programs
^^^^^^^^^^^^^^^^^^^^

Interactive programs don't work. I want to at least support password
prompts.


Command output
^^^^^^^^^^^^^^

Output isn't as pretty and useful as it could be. Also, stderr is
always printed on screen, which I guess won't be ideal in some cases.
