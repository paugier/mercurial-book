.. _chap:template:


Customizing the output of Mercurial
===================================

Mercurial provides a powerful mechanism to let you control how it displays information. The mechanism is based on templates. You can use templates to
generate specific output for a single command, or to customize the entire appearance of the built-in web interface.

.. _sec:style:


Using precanned output styles
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Packaged with Mercurial are some output styles that you can use immediately. A style is simply a precanned template that someone wrote and installed
somewhere that Mercurial can find.

Before we take a look at Mercurial's bundled styles, let's review its normal output.

.. include:: examples/results/template.simple.normal.lxo




This is somewhat informative, but it takes up a lot of space—five lines of output per changeset. The ``compact`` style reduces this to three
lines, presented in a sparse manner.

.. include:: examples/results/template.simple.compact.lxo


The ``changelog`` style hints at the expressive power of Mercurial's templating engine. This style attempts to follow the GNU Project's changelog
guidelinesweb:changelog.

.. include:: examples/results/template.simple.changelog.lxo


You will not be shocked to learn that Mercurial's default output style is named ``default``.

Setting a default style
-----------------------

You can modify the output style that Mercurial will use for every command by editing your ``~/.hgrc`` file, naming the style you would prefer to use.

::

    [ui]
    style = compact

If you write a style of your own, you can use it by either providing the path to your style file, or copying your style file into a location where
Mercurial can find it (typically the ``templates`` subdirectory of your Mercurial install directory).

Commands that support styles and templates
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

All of Mercurial's “``log``-like” commands let you use styles and templates: ``hg incoming``, ``hg log``, ``hg outgoing``, and ``hg tip``.

As I write this manual, these are so far the only commands that support styles and templates. Since these are the most important commands that need
customizable output, there has been little pressure from the Mercurial user community to add style and template support to other commands.

The basics of templating
~~~~~~~~~~~~~~~~~~~~~~~~

At its simplest, a Mercurial template is a piece of text. Some of the text never changes, while other parts are *expanded*, or replaced with new text,
when necessary.

Before we continue, let's look again at a simple example of Mercurial's normal output.

.. include:: examples/results/template.simple.normal.lxo




Now, let's run the same command, but using a template to change its output.

.. include:: examples/results/template.simple.simplest.lxo


The example above illustrates the simplest possible template; it's just a piece of static text, printed once for each changeset. The ``--template``
option to the ``hg log`` command tells Mercurial to use the given text as the template when printing each changeset.

Notice that the template string above ends with the text “``\n``”. This is an *escape sequence*, telling Mercurial to print a newline at the end of
each template item. If you omit this newline, Mercurial will run each piece of output together. See :ref:`sec:template:escape <sec:template:escape>` for more details of
escape sequences.

A template that prints a fixed string of text all the time isn't very useful; let's try something a bit more complex.

.. include:: examples/results/template.simple.simplesub.lxo


As you can see, the string “``{desc}``” in the template has been replaced in the output with the description of each changeset. Every time Mercurial
finds text enclosed in curly braces (“``{``” and “``}``”), it will try to replace the braces and text with the expansion of whatever is inside. To
print a literal curly brace, you must escape it, as described in :ref:`sec:template:escape <sec:template:escape>`.

.. _sec:template:keyword:


Common template keywords
~~~~~~~~~~~~~~~~~~~~~~~~

You can start writing simple templates immediately using the keywords below.

-  ``author``: String. The unmodified author of the changeset.

-  ``branches``: String. The name of the branch on which the changeset was committed. Will be empty if the branch name was ``default``.

-  ``date``: Date information. The date when the changeset was committed. This is *not* human-readable; you must pass it through a filter that will
   render it appropriately. See :ref:`sec:template:filter <sec:template:filter>` for more information on filters. The date is expressed as a pair of numbers. The first
   number is a Unix UTC timestamp (seconds since January 1, 1970); the second is the offset of the committer's timezone from UTC, in seconds.

-  ``desc``: String. The text of the changeset description.

-  ``files``: List of strings. All files modified, added, or removed by this changeset.

-  ``file_adds``: List of strings. Files added by this changeset.

-  ``file_dels``: List of strings. Files removed by this changeset.

-  ``node``: String. The changeset identification hash, as a 40-character hexadecimal string.

-  ``parents``: List of strings. The parents of the changeset.

-  ``rev``: Integer. The repository-local changeset revision number.

-  ``tags``: List of strings. Any tags associated with the changeset.

A few simple experiments will show us what to expect when we use these keywords; you can see the results below.

.. include:: examples/results/template.simple.keywords.lxo


As we noted above, the date keyword does not produce human-readable output, so we must treat it specially. This involves using a *filter*, about which
more in :ref:`sec:template:filter <sec:template:filter>`.

.. include:: examples/results/template.simple.datekeyword.lxo


.. _sec:template:escape:


Escape sequences
~~~~~~~~~~~~~~~~

Mercurial's templating engine recognises the most commonly used escape sequences in strings. When it sees a backslash (“``\``”) character, it looks at
the following character and substitutes the two characters with a single replacement, as described below.

-  ``\``: Backslash, “``\``”, ASCII 134.

-  ``\n``: Newline, ASCII 12.

-  ``\r``: Carriage return, ASCII 15.

-  ``\t``: Tab, ASCII 11.

-  ``\v``: Vertical tab, ASCII 13.

-  ``\{``: Open curly brace, “``{``”, ASCII 173.

-  ``\}``: Close curly brace, “``}``”, ASCII 175.

As indicated above, if you want the expansion of a template to contain a literal “``\``”, “``{``”, or “``{``” character, you must escape it.

.. _sec:template:filter:


Filtering keywords to change their results
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Some of the results of template expansion are not immediately easy to use. Mercurial lets you specify an optional chain of *filters* to modify the
result of expanding a keyword. You have already seen a common filter, ``isodate``, in action above, to make a date readable.

Below is a list of the most commonly used filters that Mercurial supports. While some filters can be applied to any text, others can only be used in
specific circumstances. The name of each filter is followed first by an indication of where it can be used, then a description of its effect.

-  ``addbreaks``: Any text. Add an XHTML “``<br/>``” tag before the end of every line except the last. For example, “``foo\nbar``” becomes
   “``foo<br/>\nbar``”.

-  ``age``: ``date`` keyword. Render the age of the date, relative to the current time. Yields a string like “``10 minutes``”.

-  ``basename``: Any text, but most useful for the ``files`` keyword and its relatives. Treat the text as a path, and return the basename. For
   example, “``foo/bar/baz``” becomes “``baz``”.

-  ``date``: ``date`` keyword. Render a date in a similar format to the Unix ``date`` command, but with timezone included. Yields a string like “``Mon Sep 04 15:13:13 2006 -0700``”.

-  ``domain``: Any text, but most useful for the ``author`` keyword. Finds the first string that looks like an email address, and extract just the
   domain component. For example, “``Bryan O'Sullivan <bos@serpentine.com>``” becomes “``serpentine.com``”.

-  ``email``: Any text, but most useful for the ``author`` keyword. Extract the first string that looks like an email address. For example,
   “``Bryan O'Sullivan <bos@serpentine.com>``” becomes “``bos@serpentine.com``”.

-  ``escape``: Any text. Replace the special XML/XHTML characters “``&``”, “``<``” and “``>``” with XML entities.

-  ``fill68``: Any text. Wrap the text to fit in 68 columns. This is useful before you pass text through the ``tabindent`` filter, and still want it
   to fit in an 80-column fixed-font window.

-  ``fill76``: Any text. Wrap the text to fit in 76 columns.

-  ``firstline``: Any text. Yield the first line of text, without any trailing newlines.

-  ``hgdate``: ``date`` keyword. Render the date as a pair of readable numbers. Yields a string like “``1157407993 25200``”.

-  ``isodate``: ``date`` keyword. Render the date as a text string in ISO 8601 format. Yields a string like “``2006-09-04 15:13:13 -0700``”.

-  ``obfuscate``: Any text, but most useful for the ``author`` keyword. Yield the input text rendered as a sequence of XML entities. This helps to
   defeat some particularly stupid screen-scraping email harvesting spambots.

-  ``person``: Any text, but most useful for the ``author`` keyword. Yield the text before an email address. For example, “``Bryan O'Sullivan <bos@serpentine.com>``” becomes “``Bryan O'Sullivan``”.

-  ``rfc822date``: ``date`` keyword. Render a date using the same format used in email headers. Yields a string like “``Mon, 04 Sep 2006 15:13:13 -0700``”.

-  ``short``: Changeset hash. Yield the short form of a changeset hash, i.e. a 12-character hexadecimal string.

-  ``shortdate``: ``date`` keyword. Render the year, month, and day of the date. Yields a string like “``2006-09-04``”.

-  ``strip``: Any text. Strip all leading and trailing whitespace from the string.

-  ``tabindent``: Any text. Yield the text, with every line except the first starting with a tab character.

-  ``urlescape``: Any text. Escape all characters that are considered “special” by URL parsers. For example, ``foo bar`` becomes ``foo%20bar``.

-  ``user``: Any text, but most useful for the ``author`` keyword. Return the “user” portion of an email address. For example, “``Bryan O'Sullivan <bos@serpentine.com>``” becomes “``bos``”.

.. include:: examples/results/template.simple.manyfilters.lxo

|


.. Note::

    If you try to apply a filter to a piece of data that it cannot process, Mercurial will fail and print a Python exception. For example, trying to
    run the output of the ``desc`` keyword into the ``isodate`` filter is not a good idea.

Combining filters
-----------------

It is easy to combine filters to yield output in the form you would like. The following chain of filters tidies up a description, then makes sure that
it fits cleanly into 68 columns, then indents it by a further 8 characters (at least on Unix-like systems, where a tab is conventionally 8 characters
wide).

.. include:: examples/results/template.simple.combine.lxo


Note the use of “``\t``” (a tab character) in the template to force the first line to be indented; this is necessary since ``tabindent`` indents all
lines *except* the first.

Keep in mind that the order of filters in a chain is significant. The first filter is applied to the result of the keyword; the second to the result
of the first filter; and so on. For example, using ``fill68|tabindent`` gives very different results from ``tabindent|fill68``.

From templates to styles
~~~~~~~~~~~~~~~~~~~~~~~~

A command line template provides a quick and simple way to format some output. Templates can become verbose, though, and it's useful to be able to
give a template a name. A style file is a template with a name, stored in a file.

More than that, using a style file unlocks the power of Mercurial's templating engine in ways that are not possible using the command line
``--template`` option.

The simplest of style files
---------------------------

Our simple style file contains just one line:

.. include:: examples/results/template.simple.rev.lxo


This tells Mercurial, “if you're printing a changeset, use the text on the right as the template”.

Style file syntax
-----------------

The syntax rules for a style file are simple.

-  The file is processed one line at a time.

-  Leading and trailing white space are ignored.

-  Empty lines are skipped.

-  If a line starts with either of the characters “``#``” or “``;``”, the entire line is treated as a comment, and skipped as if empty.

-  A line starts with a keyword. This must start with an alphabetic character or underscore, and can subsequently contain any alphanumeric character
   or underscore. (In regexp notation, a keyword must match ``[A-Za-z_][A-Za-z0-9_]*``.)

-  The next element must be an “``=``” character, which can be preceded or followed by an arbitrary amount of white space.

-  If the rest of the line starts and ends with matching quote characters (either single or double quote), it is treated as a template body.

-  If the rest of the line *does not* start with a quote character, it is treated as the name of a file; the contents of this file will be read and
   used as a template body.

Style files by example
~~~~~~~~~~~~~~~~~~~~~~

To illustrate how to write a style file, we will construct a few by example. Rather than provide a complete style file and walk through it, we'll
mirror the usual process of developing a style file by starting with something very simple, and walking through a series of successively more complete
examples.

Identifying mistakes in style files
-----------------------------------

If Mercurial encounters a problem in a style file you are working on, it prints a terse error message that, once you figure out what it means, is
actually quite useful.

.. include:: examples/results/template.svnstyle.syntax.input.lxo


Notice that ``broken.style`` attempts to define a ``changeset`` keyword, but forgets to give any content for it. When instructed to use this style
file, Mercurial promptly complains.

.. include:: examples/results/template.svnstyle.syntax.error.lxo


This error message looks intimidating, but it is not too hard to follow.

-  The first component is simply Mercurial's way of saying “I am giving up”.

   ::

       ___abort___: broken.style:1: parse error

-  Next comes the name of the style file that contains the error.

   ::

       abort: ___broken.style___:1: parse error

-  Following the file name is the line number where the error was encountered.

   ::

       abort: broken.style:___1___: parse error

-  Finally, a description of what went wrong.

   ::

       abort: broken.style:1: ___parse error___

-  The description of the problem is not always clear (as in this case), but even when it is cryptic, it is almost always trivial to visually inspect
   the offending line in the style file and see what is wrong.

Uniquely identifying a repository
---------------------------------

If you would like to be able to identify a Mercurial repository “fairly uniquely” using a short string as an identifier, you can use the first
revision in the repository.

.. include:: examples/results/template.svnstyle.id.lxo


This is likely to be unique, and so it is useful in many cases. There are a few caveats.

-  It will not work in a completely empty repository, because such a repository does not have a revision zero.

-  Neither will it work in the (extremely rare) case where a repository is a merge of two or more formerly independent repositories, and you still
   have those repositories around.

Here are some uses to which you could put this identifier:

-  As a key into a table for a database that manages repositories on a server.

-  As half of a {*repository ID*, *revision ID*} tuple. Save this information away when you run an automated build or other activity, so that you can
   “replay” the build later if necessary.

Listing files on multiple lines
-------------------------------

Suppose we want to list the files changed by a changeset, one per line, with a little indentation before each file name.

.. include:: examples/results/ch10-multiline.go.lxo


Mimicking Subversion's output
-----------------------------

Let's try to emulate the default output format used by another revision control tool, Subversion.

.. include:: examples/results/template.svnstyle.short.lxo


Since Subversion's output style is fairly simple, it is easy to copy-and-paste a hunk of its output into a file, and replace the text produced above
by Subversion with the template values we'd like to see expanded.

.. include:: examples/results/template.svnstyle.template.lxo


There are a few small ways in which this template deviates from the output produced by Subversion.

-  Subversion prints a “readable” date (the “``Wed, 27 Sep 2006``” in the example output above) in parentheses. Mercurial's templating engine does not
   provide a way to display a date in this format without also printing the time and time zone.

-  We emulate Subversion's printing of “separator” lines full of “``-``” characters by ending the template with such a line. We use the templating
   engine's ``header`` keyword to print a separator line as the first line of output (see below), thus achieving similar output to Subversion.

-  Subversion's output includes a count in the header of the number of lines in the commit message. We cannot replicate this in Mercurial; the
   templating engine does not currently provide a filter that counts the number of lines the template generates.

It took me no more than a minute or two of work to replace literal text from an example of Subversion's output with some keywords and filters to give
the template above. The style file simply refers to the template.

.. include:: examples/results/template.svnstyle.style.lxo


We could have included the text of the template file directly in the style file by enclosing it in quotes and replacing the newlines with “``\n``”
sequences, but it would have made the style file too difficult to read. Readability is a good guide when you're trying to decide whether some text
belongs in a style file, or in a template file that the style file points to. If the style file will look too big or cluttered if you insert a literal
piece of text, drop it into a template instead.