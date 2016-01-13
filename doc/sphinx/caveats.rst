Caveats
-------

Here are the caveats that I consider as the most important, roughly in
order of priority.


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
