.. _chap:scaling:


Scaling Mercurial
=================

Scalability issues
~~~~~~~~~~~~~~~~~~

Mercurial has been used in deployments containing over 100 000 files and 200 000 changesets, `still working very
well <https://mercurial.selenic.com/wiki/BigRepositories>`__. It has received, release after release, improvements to scalability.

Even so, some repositories manage to outgrow the default Mercurial setup.

One possible scaling issue is due to a very large amount of changesets. Mercurial stores history efficiently, but repository size does grow as more
and more history accumulates. This can result in slower clones and pulls, as the amount of data to download keeps increasing. We can handle this issue
using so-called "shallow clones".

A second issue is handling binary files. Changes to binary files are not stored as efficiently as changes to text files, which results in the
repository growing very fast. This also results in slower clones and pulls. This problem can be tackled with the largefiles extension.

Repositories with hundreds of thousands of files can also pose scalability issues. Some common Mercurial commands (like 'hg status') need to check all
of the files in the repository. This is almost not noticeable on small repositories, but can become an issue if you have a lot of files. The
hgwatchman extension automatically detects and remembers repository changes, to avoid a slowdown. Additionally, if you don't require all files in the
repository, the narrowhg extension allows you to only clone the subset of files you are interested in.

Large repositories can also be quite resource-intensive for servers that host them. A central Mercurial server can provide repositories to hundreds or
thousands of users. Every time a user clones a repository, the server generates a bundle containing the contents of that repository. This bundle is
transmitted to the user and extracted. Generating a bundle for a large repository takes a lot of processing power and disk access. A feature called
'clonebundles' allows reusing pre-generated bundles, resulting in a much-reduced load for the server.

Finally, a very branchy history can also impact performance. Specifically, older versions of Mercurial do not efficiently store changes in lots of
different branches developed at the same time. As a result, the size of the history can grow much faster than when development is mostly linear. Newer
versions of Mercurial use a specific encoding. This makes it possible to store changes more efficiently when using many branches.

Scaling up to many changesets with ``remotefilelog``
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

You may have wondered, especially if you've used centralized version control systems before, if it's really necessary to copy all of the history when
you make a clone. Why not download it on-the-fly?

Well, in many cases, the history isn't really that big, and only the initial clone will take quite a bit of time. Additionally, having all of the
history locally makes a lot of operations (like diff and log) much faster.

However, if you have an extremely large project with hundreds of developers adding history and hundreds of thousands of changesets, this can result in
slow pulls and a very large amount of disk space being used. In this case, the benefits of local history may be outweighed by its downsides.

Luckily, there's a solution: the remotefilelog extension. This extension allows you to make 'shallow clones', keeping all of the different file
versions purely on the server. As an example, here are the sizes of the history for a large repository (mozilla-central) with and without the full
history:

-  with history: 2256 MB

-  without history: 557 MB

In other words, this extension results in downloading 4 times less data from the server on the initial clone! We can reduce this even further by
combining this change with efficient storage of many branches as mentioned in :ref:`sec:scaling:branches <sec:scaling:branches>`.

To get started with remotefilelog, clone the extension from `Bitbucket <https://bitbucket.org/facebook/remotefilelog>`__ and add it to your hgrc:

::

    [extensions]
    remotefilelog = /path/to/remotefilelog/remotefilelog

The remotefilelog extension requires configuration both on the server and the client side. On the server side, all you need to do is enable the server
functionality. Additionally, you can configure the maximum time downloaded files are cached:

::

    [remotefilelog]
    server = True
    #keep cached files for 10 days (default 30)
    serverexpiration = 10

On the client side, the only \_required\_ option is the ``cachepath``. This specifies where file versions will be cached.

It's enough to specify the following configuration if you want to be able to make shallow clones:

::

    [remotefilelog]
    #Path where revisions will be cached locally
    cachepath = /path/to/hgcache
    #Maximum size of the local cache in GB
    cachelimit = 10

Once you've specified all of the configuration options, you should be able to make a shallow clone, simply by using the ``--shallow`` flag:

.. include:: examples/results/ch15-remotefilelog.clone.lxo


How do we know it's actually a shallow clone? You can still run all regular Mercurial commands, so you might not notice. One way to find out is to
look into the .hg directory. All file history is contained in ``.hg/store/data``, so we should see a completely empty directory there:

.. include:: examples/results/ch15-remotefilelog.check-shallow.lxo


We've successfully made a shallow clone! So far, you'll only be able to do so for clones over ssh, other protocols aren't supported yet.

We can configure quite a few additional client settings. Most importantly, remotefilelog allows configuring a `memcached caching
server <http://memcached.org>`__, greatly improving performance if you are on a fast network. To add memcached support to your client configuration,
you need to configure the cacheprocess parameter. The extension contains a file ``cacheclient.py``, which we can use to communicate with a memcached
server.

::

    [remotefilelog]
    cacheprocess = /path/to/remotefilelog/remotefilelog/cacheclient.py MEMCACHEIP:MEMCACHEPORT MEMCACHEPREFIX

One major downside to using remotefilelog is that your history is no longer kept locally. This means you will no longer be able to update to any
revision you want without network access. This may not be a major issue for your use case, but it's a trade-off you shouldn't forget.

.. _sec:scaling:largefiles:


Handle large binaries with the ``largefiles`` extension
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Mercurial is very good at managing source code and text files. It only needs to store the difference between two versions of the file, rather than
keeping each version completely. This avoids the repository from growing quickly. However, what happens if we have to deal with (large) binaries?

It would appear we're not so lucky: each version of the binary is stored without delta compression. Add a 10 MB binary to your repository and it grows
by 10 MB. Change a single byte in that binary and commit your new changeset: another 10 MB gets added! Additionally, every person that wants to clone
your repository will have to download every version of the binary, which quickly starts to add up.

Luckily, Mercurial has a solution for this problem: the largefiles extension. It was added to Mercurial 2.0 in 2011. The extension stores large files
(large binaries) on a server on the network, rather than in the repository history itself. The only information saved in the repository itself is a
40-byte hash of the file, which is placed in the '.hglf/' subdirectory. Largefiles are not downloaded when you pull changes. Instead, only the
largefiles for a specific revision are downloaded, when you update to that revision. This way, if you add a new version of your 10 MB binary to your
repository, it only grows by a few bytes. If a new user clones your code and updates to the latest revision, they will only need to download one 10 MB
binary, rather than every single one.

To enable the largefiles extension, simply add the following to your hgrc file:

::

    [extensions]
    largefiles =
        

If you're concerned one of your users will forget to enable the extension, don't worry! Upon cloning, an informative error message will show up:

::

    abort: repository requires features unknown to this Mercurial: largefiles!
    (see http://mercurial.selenic.com/wiki/MissingRequirement for more information)

So how do we start using the largefiles extension to manage our large binaries? Let's setup a repository and create a large binary file:

.. include:: examples/results/ch15-largefiles.init.lxo


Normally, we would add the 'randomdata' file by simply executing:

.. include:: examples/results/ch15-largefiles.add-regular.lxo


However, we've enabled the largefiles extension. This allows us to execute:

.. include:: examples/results/ch15-largefiles.add-largefile.lxo


Using the additional '--large' flag, we've clarified that we want this file to be stored as a largefile.

The repository now not only contains the 'randomdata' file, it also contains a '.hglf/' directory, containing a textfile called 'randomdata'. That
file in turn contains a 40-byte hash that allows Mercurial to know what contents should actually be placed in the 'randomdata' file when updating to a
specific revision.

Largefiles are propagated by pushing or pulling. If you push new revisions to another repository, all of the largefiles changed in those revisions
will be pushed as well. This allows you to upload all of your largefiles to a central server.

If you pull new revisions from another repository, by default the changed largefiles will not be pulled into your local repository! That only happens
when you update to a revision containing the new version of a largefile. This ensures you don't have to download huge amounts of data, just to have a
single version of a largefile available.

If you want to explicitly get all of the largefiles into your repository, you can use lfpull:

::

    $ hg lfpull --rev relevantrevisions

Alternatively, you can also use the '--lfrev' flag:

::

    $ hg pull --lfrev relevantrevisions

This allows you to easily download all largefiles, be it for offline access or for backup purposes.

Once you've added a single largefile to a repository, new files over 10 MB that you add to the repository will automatically be added as largefile.
It's possible to configure your system in a different way, using two specific configuration options.

-  The largefiles.minsize option allows specifying a size (in MB). All new files larger than this size will automatically be added as largefile.

-  The largefiles.patterns option allow specifying regex or glob patterns. All files that match one of the patterns will automatically be added as
   largefile, even if they are smaller than largefiles.minsize!

An example configuration:

::

    [largefiles]
    # Add all files over 3 MB as largefile
    minsize = 3
    # All files matching one of the below patterns will be added as largefile
    patterns =
      *.jpg
      re:.*\.(png|bmp)$
      library.zip
      content/audio/*

The largefiles extension comes with a trade-off. It's very useful for scalability, allowing people to use Mercurial for large files and binaries
without letting the repository size grow enormously. However, that's exactly where the downside lies as well: not all file versions are downloaded
automatically when pulling. This means the largefiles extension removes part of the distributed nature of Mercurial.

Suppose you are on a plane without network access. Can you still update to each revision when largefiles are in use? Not necessarily. Suppose the disk
containing your central repository crashes. Can you simply clone from a user repository and carry on? Not unless that user repository has all of the
largefiles you need.

In conclusion: the largefiles extension is very useful, but keep in mind its downsides before you start using it!

Scaling repositories with many files
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Repositories with hundreds of thousands of files have their own set of scalability issues. Running a command like ``hg status`` or ``hg update``
requires accessing every file in the repository to check if it has changed. This is not even noticeable on small repositories, but can become a
problem with very large repositories.

Most operating systems provide the possibility to *watch* a certain directory and be informed automatically when files change. This avoids having to
scan through all files. A tool called *watchman* handles watching files on different operating systems.

.. _sec:scaling:branches:


Scaling repositories with many branches
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

TODO