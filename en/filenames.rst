.. _chap:names:


File names and pattern matching
===============================

Mercurial provides mechanisms that let you work with file names in a consistent and expressive way.

Simple file naming
~~~~~~~~~~~~~~~~~~

Mercurial uses a unified piece of machinery “under the hood” to handle file names. Every command behaves uniformly with respect to file names. The way
in which commands work with file names is as follows.

If you explicitly name real files on the command line, Mercurial works with exactly those files, as you would expect.

.. include:: examples/results/filenames.files.lxo

When you provide a directory name, Mercurial will interpret this as “operate on every file in this directory and its subdirectories”. Mercurial
traverses the files and subdirectories in a directory in alphabetical order. When it encounters a subdirectory, it will traverse that subdirectory
before continuing with the current directory.

.. include:: examples/results/filenames.dirs.lxo


Running commands without any file names
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Mercurial's commands that work with file names have useful default behaviors when you invoke them without providing any file names or patterns. What
kind of behavior you should expect depends on what the command does. Here are a few rules of thumb you can use to predict what a command is likely to
do if you don't give it any names to work with.

-  Most commands will operate on the entire working directory. This is what the ``hg add`` command does, for example.

-  If the command has effects that are difficult or impossible to reverse, it will force you to explicitly provide at least one name or pattern (see
   below). This protects you from accidentally deleting files by running ``hg remove`` with no arguments, for example.

It's easy to work around these default behaviors if they don't suit you. If a command normally operates on the whole working directory, you can invoke
it on just the current directory and its subdirectories by giving it the name “``.``”.

.. include:: examples/results/filenames.wdir-subdir.lxo


Along the same lines, some commands normally print file names relative to the root of the repository, even if you're invoking them from a
subdirectory. Such a command will print file names relative to your subdirectory if you give it explicit names. Here, we're going to run ``hg status`` from a subdirectory, and get it to operate on the entire working directory while printing file names relative to our subdirectory, by
passing it the output of the ``hg root`` command.

.. include:: examples/results/filenames.wdir-relname.lxo


Telling you what's going on
~~~~~~~~~~~~~~~~~~~~~~~~~~~

The ``hg add`` example in the preceding section illustrates something else that's helpful about Mercurial commands. If a command operates on a file
that you didn't name explicitly on the command line, it will usually print the name of the file, so that you will not be surprised what's going on.

The principle here is of *least surprise*. If you've exactly named a file on the command line, there's no point in repeating it back at you. If
Mercurial is acting on a file *implicitly*, e.g. because you provided no names, or a directory, or a pattern (see below), it is safest to tell you
what files it's operating on.

For commands that behave this way, you can silence them using the ``-q`` option. You can also get them to print the name of every file, even those
you've named explicitly, using the ``-v`` option.

Using patterns to identify files
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

In addition to working with file and directory names, Mercurial lets you use *patterns* to identify files. Mercurial's pattern handling is expressive.

On Unix-like systems (Linux, MacOS, etc.), the job of matching file names to patterns normally falls to the shell. On these systems, you must
explicitly tell Mercurial that a name is a pattern. On Windows, the shell does not expand patterns, so Mercurial will automatically identify names
that are patterns, and expand them for you.

To provide a pattern in place of a regular name on the command line, the mechanism is simple:

::

    syntax:patternbody

That is, a pattern is identified by a short text string that says what kind of pattern this is, followed by a colon, followed by the actual pattern.

Mercurial supports two kinds of pattern syntax. The most frequently used is called ``glob``; this is the same kind of pattern matching used by the
Unix shell, and should be familiar to Windows command prompt users, too.

When Mercurial does automatic pattern matching on Windows, it uses ``glob`` syntax. You can thus omit the “``glob:``” prefix on Windows, but it's safe
to use it, too.

The ``re`` syntax is more powerful; it lets you specify patterns using regular expressions, also known as regexps.

By the way, in the examples that follow, notice that I'm careful to wrap all of my patterns in quote characters, so that they won't get expanded by
the shell before Mercurial sees them.

Shell-style ``glob`` patterns
-----------------------------

This is an overview of the kinds of patterns you can use when you're matching on glob patterns.

The “``*``” character matches any string, within a single directory.

.. include:: examples/results/filenames.glob.star.lxo


The “``**``” pattern matches any string, and crosses directory boundaries. It's not a standard Unix glob token, but it's accepted by several popular
Unix shells, and is very useful.

.. include:: examples/results/filenames.glob.starstar.lxo


The “``?``” pattern matches any single character.

.. include:: examples/results/filenames.glob.question.lxo


The “``[``” character begins a *character class*. This matches any single character within the class. The class ends with a “``]``” character. A class
may contain multiple *range*\ s of the form “``a-f``”, which is shorthand for “``abcdef``”.

.. include:: examples/results/filenames.glob.range.lxo


If the first character after the “``[``” in a character class is a “``!``”, it *negates* the class, making it match any single character not in the
class.

A “``{``” begins a group of subpatterns, where the whole group matches if any subpattern in the group matches. The “``,``” character separates
subpatterns, and “``}``” ends the group.

.. include:: examples/results/filenames.glob.group.lxo


Watch out!
~~~~~~~~~~

Don't forget that if you want to match a pattern in any directory, you should not be using the “``*``” match-any token, as this will only match within
one directory. Instead, use the “``**``” token. This small example illustrates the difference between the two.

.. include:: examples/results/filenames.glob.star-starstar.lxo


Regular expression matching with ``re`` patterns
------------------------------------------------

Mercurial accepts the same regular expression syntax as the Python programming language (it uses Python's regexp engine internally). This is based on
the Perl language's regexp syntax, which is the most popular dialect in use (it's also used in Java, for example).

I won't discuss Mercurial's regexp dialect in any detail here, as regexps are not often used. Perl-style regexps are in any case already exhaustively
documented on a multitude of web sites, and in many books. Instead, I will focus here on a few things you should know if you find yourself needing to
use regexps with Mercurial.

A regexp is matched against an entire file name, relative to the root of the repository. In other words, even if you're already in subbdirectory
``foo``, if you want to match files under this directory, your pattern must start with “``foo/``”.

One thing to note, if you're familiar with Perl-style regexps, is that Mercurial's are *rooted*. That is, a regexp starts matching against the
beginning of a string; it doesn't look for a match anywhere within the string. To match anywhere in a string, start your pattern with “``.*``”.

Filtering files
~~~~~~~~~~~~~~~

Not only does Mercurial give you a variety of ways to specify files; it lets you further winnow those files using *filters*. Commands that work with
file names accept two filtering options.

-  ``-I``, or ``--include``, lets you specify a pattern that file names must match in order to be processed.

-  ``-X``, or ``--exclude``, gives you a way to *avoid* processing files, if they match this pattern.

You can provide multiple ``-I`` and ``-X`` options on the command line, and intermix them as you please. Mercurial interprets the patterns you provide
using glob syntax by default (but you can use regexps if you need to).

You can read a ``-I`` filter as “process only the files that match this filter”.

.. include:: examples/results/filenames.filter.include.lxo


The ``-X`` filter is best read as “process only the files that don't match this pattern”.

.. include:: examples/results/filenames.filter.exclude.lxo


Permanently ignoring unwanted files and directories
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

When you create a new repository, the chances are that over time it will grow to contain files that ought to *not* be managed by Mercurial, but which
you don't want to see listed every time you run ``hg status``. For instance, “build products” are files that are created as part of a build but which should not be managed by a revision control
system. The most common build products are output files produced by software tools such as compilers. As another example, many text editors litter a
directory with lock files, temporary working files, and backup files, which it also makes no sense to manage.

To have Mercurial permanently ignore such files, create a file named ``.hgignore`` in the root of your repository. You *should* ``hg add`` this file so that it gets tracked with the rest of your repository contents, since your collaborators will probably find it useful too.

By default, the ``.hgignore`` file should contain a list of regular expressions, one per line. Empty lines are skipped. Most people prefer to describe
the files they want to ignore using the “glob” syntax that we described above, so a typical ``.hgignore`` file will start with this directive:

::

    syntax: glob

This tells Mercurial to interpret the lines that follow as glob patterns, not regular expressions.

Here is a typical-looking ``.hgignore`` file.

::

    syntax: glob
    # This line is a comment, and will be skipped.
    # Empty lines are skipped too.

    # Backup files left behind by the Emacs editor.
    *~

    # Lock files used by the Emacs editor.
    # Notice that the "#" character is quoted with a backslash.
    # This prevents it from being interpreted as starting a comment.
    .\#*

    # Temporary files used by the vim editor.
    .*.swp

    # A hidden file created by the Mac OS X Finder.
    .DS_Store

.. _sec:names:case:


Case sensitivity
~~~~~~~~~~~~~~~~

If you're working in a mixed development environment that contains both Linux (or other Unix) systems and Macs or Windows systems, you should keep in
the back of your mind the knowledge that they treat the case (“N” versus “n”) of file names in incompatible ways. This is not very likely to affect
you, and it's easy to deal with if it does, but it could surprise you if you don't know about it.

Operating systems and filesystems differ in the way they handle the *case* of characters in file and directory names. There are three common ways to
handle case in names.

-  Completely case insensitive. Uppercase and lowercase versions of a letter are treated as identical, both when creating a file and during subsequent
   accesses. This is common on older DOS-based systems.

-  Case preserving, but insensitive. When a file or directory is created, the case of its name is stored, and can be retrieved and displayed by the
   operating system. When an existing file is being looked up, its case is ignored. This is the standard arrangement on Windows and MacOS. The names
   ``foo`` and ``FoO`` identify the same file. This treatment of uppercase and lowercase letters as interchangeable is also referred to as *case
   folding*.

-  Case sensitive. The case of a name is significant at all times. The names ``foo`` and ``FoO`` identify different files. This is the way Linux and
   Unix systems normally work.

On Unix-like systems, it is possible to have any or all of the above ways of handling case in action at once. For example, if you use a USB thumb
drive formatted with a FAT32 filesystem on a Linux system, Linux will handle names on that filesystem in a case preserving, but insensitive, way.

Safe, portable repository storage
---------------------------------

Mercurial's repository storage mechanism is *case safe*. It translates file names so that they can be safely stored on both case sensitive and case
insensitive filesystems. This means that you can use normal file copying tools to transfer a Mercurial repository onto, for example, a USB thumb
drive, and safely move that drive and repository back and forth between a Mac, a PC running Windows, and a Linux box.

Detecting case conflicts
------------------------

When operating in the working directory, Mercurial honours the naming policy of the filesystem where the working directory is located. If the
filesystem is case preserving, but insensitive, Mercurial will treat names that differ only in case as the same.

An important aspect of this approach is that it is possible to commit a changeset on a case sensitive (typically Linux or Unix) filesystem that will
cause trouble for users on case insensitive (usually Windows and MacOS) users. If a Linux user commits changes to two files, one named ``myfile.c``
and the other named ``MyFile.C``, they will be stored correctly in the repository. And in the working directories of other Linux users, they will be
correctly represented as separate files.

If a Windows or Mac user pulls this change, they will not initially have a problem, because Mercurial's repository storage mechanism is case safe.
However, once they try to ``hg update`` the working directory to that changeset, or ``hg merge`` with that changeset, Mercurial will spot the conflict between the two file names that the filesystem would treat as the same, and forbid
the update or merge from occurring.

Fixing a case conflict
----------------------

If you are using Windows or a Mac in a mixed environment where some of your collaborators are using Linux or Unix, and Mercurial reports a case
folding conflict when you try to ``hg update`` or ``hg merge``, the procedure to fix the problem is simple.

Just find a nearby Linux or Unix box, clone the problem repository onto it, and use Mercurial's ``hg rename`` command to change the names of any
offending files or directories so that they will no longer cause case folding conflicts. Commit this change, ``hg pull`` or ``hg push`` it across to
your Windows or MacOS system, and ``hg update`` to the revision with the non-conflicting names.

The changeset with case-conflicting names will remain in your project's history, and you still won't be able to ``hg update`` your working directory
to that changeset on a Windows or MacOS system, but you can continue development unimpeded.