.. highlight:: none

Installation
------------

Currently, installation is only available through Github.  Two
branches are available. *master* is up to date and may very well
contain bugs. On the other hand, I try to only push on *stable* after
the code has been tested sufficiently.

Please note that at the time of writing (8/20/2015), stable is
horribly outdated and should not be used when trying out the library.


Add Hutte to your project with Bundler
^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^

Add this to your project's Gemfile::

   gem 'hutte', github: 'bastienleonard/hutte', branch: 'stable'

If you have cloned Hutte, you can use the local repo like this::

   gem 'hutte', path: '/path/to/repo'

Install your dependencies and you're good to go::

   bundle install


Manual installation
^^^^^^^^^^^^^^^^^^^

Clone the repo::

   git clone git@github.com:bastienleonard/hutte.git

Build the gem::

   gem build hutte.gemspec

Install it::

   # You may have to change this version number
   gem install hutte-0.1.0.gem
