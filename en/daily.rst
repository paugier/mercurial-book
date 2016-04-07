.. _chap:daily:


Mercurial in daily use
======================

Telling Mercurial which files to track
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Mercurial does not work with files in your repository unless you tell it to manage them. The ``hg status`` command will tell you which files Mercurial doesn't know about; it uses a “``?``” to display such files.

To tell Mercurial to track a file, use the ``hg add`` command. Once you have added a file, the entry in the output of ``hg status`` for that file changes from “``?``” to “``A``”.

.. include:: examples/results/daily.files.add.lxo


After you run a ``hg commit``, the files that you added before the commit will no longer be listed in the output of ``hg status``. The reason for this is that by default, ``hg status`` only tells you about “interesting” files—those that you have (for example)
modified, removed, or renamed. If you have a repository that contains thousands of files, you will rarely want to know about files that Mercurial is
tracking, but that have not changed. (You can still get this information; we'll return to this later.)

Once you add a file, Mercurial doesn't do anything with it immediately. Instead, it will take a snapshot of the file's state the next time you perform
a commit. It will then continue to track the changes you make to the file every time you commit, until you remove the file.

Explicit versus implicit file naming
------------------------------------

A useful behavior that Mercurial has is that if you pass the name of a directory to a command, every Mercurial command will treat this as “I want to
operate on every file in this directory and its subdirectories”.

.. include:: examples/results/daily.files.add-dir.lxo


Notice in this example that Mercurial printed the names of the files it added, whereas it didn't do so when we added the file named ``myfile.txt`` in
the earlier example.

What's going on is that in the former case, we explicitly named the file to add on the command line. The assumption that Mercurial makes in such cases
is that we know what we are doing, and it doesn't print any output.

However, when we *imply* the names of files by giving the name of a directory, Mercurial takes the extra step of printing the name of each file that
it does something with. This makes it more clear what is happening, and reduces the likelihood of a silent and nasty surprise. This behavior is common
to most Mercurial commands.

Mercurial tracks files, not directories
---------------------------------------

Mercurial does not track directory information. Instead, it tracks the path to a file. Before creating a file, it first creates any missing directory
components of the path. After it deletes a file, it then deletes any empty directories that were in the deleted file's path. This sounds like a
trivial distinction, but it has one minor practical consequence: it is not possible to represent a completely empty directory in Mercurial.

Empty directories are rarely useful, and there are unintrusive workarounds that you can use to achieve an appropriate effect. The developers of
Mercurial thus felt that the complexity that would be required to manage empty directories was not worth the limited benefit this feature would bring.

If you need an empty directory in your repository, there are a few ways to achieve this. One is to create a directory, then ``hg add`` a “hidden” file
to that directory. On Unix-like systems, any file name that begins with a period (“``.``”) is treated as hidden by most commands and GUI tools. This
approach is illustrated below.

.. include:: examples/results/daily.files.hidden.lxo


Another way to tackle a need for an empty directory is to simply create one in your automated build scripts before they will need it.

How to stop tracking a file
~~~~~~~~~~~~~~~~~~~~~~~~~~~

Once you decide that a file no longer belongs in your repository, use the ``hg remove`` command. This deletes the file, and tells Mercurial to stop tracking it (which will occur at the next commit). A removed file is
represented in the output of ``hg status`` with a “``R``”.

.. include:: examples/results/daily.files.remove.lxo


After you ``hg remove`` a file, Mercurial will no longer track changes to that file, even if you recreate a file with the same name in your working
directory. If you do recreate a file with the same name and want Mercurial to track the new file, simply ``hg add`` it. Mercurial will know that the newly added file is not related to the old file of the same name.

Removing a file does not affect its history
-------------------------------------------

It is important to understand that removing a file has only two effects.

-  It removes the current version of the file from the working directory.

-  It stops Mercurial from tracking changes to the file, from the time of the next commit.

Removing a file *does not* in any way alter the *history* of the file.

If you update the working directory to a changeset that was committed when it was still tracking a file that you later removed, the file will reappear
in the working directory, with the contents it had when you committed that changeset. If you then update the working directory to a later changeset,
in which the file had been removed, Mercurial will once again remove the file from the working directory.

Missing files
-------------

Mercurial considers a file that you have deleted, but not used ``hg remove`` to delete, to be *missing*. A missing file is represented with “``!``” in
the output of ``hg status``. Mercurial commands will not generally do anything with missing files.

.. include:: examples/results/daily.files.missing.lxo


If your repository contains a file that ``hg status`` reports as missing, and you want the file to stay gone, you can run ``hg remove`` at any time
later on, to tell Mercurial that you really did mean to remove the file.

.. include:: examples/results/daily.files.remove-after.lxo


On the other hand, if you deleted the missing file by accident, give ``hg revert`` the name of the file to recover. It will reappear, in unmodified
form.

.. include:: examples/results/daily.files.recover-missing.lxo


Aside: why tell Mercurial explicitly to remove a file?
------------------------------------------------------

You might wonder why Mercurial requires you to explicitly tell it that you are deleting a file. Early during the development of Mercurial, it let you
delete a file however you pleased; Mercurial would notice the absence of the file automatically when you next ran a ``hg commit``, and stop tracking the file. In practice, this made it too easy to accidentally remove a file without noticing.

Useful shorthand—adding and removing files in one step
-----------------------------------------------------------

Mercurial offers a combination command, ``hg addremove``, that adds untracked files and marks missing files as removed.

.. include:: examples/results/daily.files.addremove.lxo


The ``hg commit`` command also provides a ``-A`` option that performs this same add-and-remove, immediately followed by a commit.

.. include:: examples/results/daily.files.commit-addremove.lxo


.. _chap:daily.copy:


Copying files
~~~~~~~~~~~~~

Mercurial provides a ``hg copy`` command that lets you make a new copy of a file. When you copy a file using this command, Mercurial makes a record of the fact that the new
file is a copy of the original file. It treats these copied files specially when you merge your work with someone else's.

The results of copying during a merge
-------------------------------------

What happens during a merge is that changes “follow” a copy. To best illustrate what this means, let's create an example. We'll start with the usual
tiny repository that contains a single file.

.. include:: examples/results/daily.copy.init.lxo


We need to do some work in parallel, so that we'll have something to merge. So let's clone our repository.

.. include:: examples/results/daily.copy.clone.lxo


Back in our initial repository, let's use the ``hg copy`` command to make a copy of the first file we created.

.. include:: examples/results/daily.copy.copy.lxo


If we look at the output of the ``hg status`` command afterwards, the copied file looks just like a normal added file.

.. include:: examples/results/daily.copy.status.lxo


But if we pass the ``-C`` option to ``hg status``, it prints another line of output: this is the file that our newly-added file was copied *from*.

.. include:: examples/results/daily.copy.status-copy.lxo


Now, back in the repository we cloned, let's make a change in parallel. We'll add a line of content to the original file that we created.

.. include:: examples/results/daily.copy.other.lxo


Now we have a modified ``file`` in this repository. When we pull the changes from the first repository, and merge the two heads, Mercurial will
propagate the changes that we made locally to ``file`` into its copy, ``new-file``.

.. include:: examples/results/daily.copy.merge.lxo


.. _sec:daily:why-copy:


Why should changes follow copies?
---------------------------------

This behavior—of changes to a file propagating out to copies of the file—might seem esoteric, but in most cases it's highly desirable.

First of all, remember that this propagation *only* happens when you merge. So if you ``hg copy`` a file, and subsequently modify the original file
during the normal course of your work, nothing will happen.

The second thing to know is that modifications will only propagate across a copy as long as the changeset that you're merging changes from *hasn't yet
seen* the copy.

The reason that Mercurial does this is as follows. Let's say I make an important bug fix in a source file, and commit my changes. Meanwhile, you've
decided to ``hg copy`` the file in your repository, without knowing about the bug or having seen the fix, and you have started hacking on your copy of
the file.

If you pulled and merged my changes, and Mercurial *didn't* propagate changes across copies, your new source file would now contain the bug, and
unless you knew to propagate the bug fix by hand, the bug would *remain* in your copy of the file.

By automatically propagating the change that fixed the bug from the original file to the copy, Mercurial prevents this class of problem. To my
knowledge, Mercurial is the *only* revision control system that propagates changes across copies like this.

Once your change history has a record that the copy and subsequent merge occurred, there's usually no further need to propagate changes from the
original file to the copied file, and that's why Mercurial only propagates changes across copies at the first merge, and not afterwards.

How to make changes *not* follow a copy
---------------------------------------

If, for some reason, you decide that this business of automatically propagating changes across copies is not for you, simply use your system's normal
file copy command (on Unix-like systems, that's ``cp``) to make a copy of a file, then ``hg add`` the new copy by hand. Before you do so, though,
please do reread :ref:`sec:daily:why-copy <sec:daily:why-copy>`, and make an informed decision that this behavior is not appropriate to your specific case.

Behavior of the ``hg copy`` command
-----------------------------------

When you use the ``hg copy`` command, Mercurial makes a copy of each source file as it currently stands in the working directory. This means that if
you make some modifications to a file, then ``hg copy`` it without first having committed those changes, the new copy will also contain the
modifications you have made up until that point. (I find this behavior a little counterintuitive, which is why I mention it here.)

The ``hg copy`` command acts similarly to the Unix ``cp`` command (you can use the ``hg cp`` alias if you prefer). We must supply two or more arguments, of which the last is treated as the *destination*, and all others are
*sources*.

If you pass ``hg copy`` a single file as the source, and the destination does not exist, it creates a new file with that name.

.. include:: examples/results/daily.copy.simple.lxo


If the destination is a directory, Mercurial copies its sources into that directory.

.. include:: examples/results/daily.copy.dir-dest.lxo


Copying a directory is recursive, and preserves the directory structure of the source.

.. include:: examples/results/daily.copy.dir-src.lxo


If the source and destination are both directories, the source tree is recreated in the destination directory.

.. include:: examples/results/daily.copy.dir-src-dest.lxo


As with the ``hg remove`` command, if you copy a file manually and then want Mercurial to know that you've copied the file, simply use the ``--after``
option to ``hg copy``.

.. include:: examples/results/daily.copy.after.lxo


Renaming files
~~~~~~~~~~~~~~

It's rather more common to need to rename a file than to make a copy of it. The reason I discussed the ``hg copy`` command before talking about
renaming files is that Mercurial treats a rename in essentially the same way as a copy. Therefore, knowing what Mercurial does when you copy a file
tells you what to expect when you rename a file.

When you use the ``hg rename`` command, Mercurial makes a copy of each source file, then deletes it and marks the file as removed.

.. include:: examples/results/daily.rename.rename.lxo


The ``hg status`` command shows the newly copied file as added, and the copied-from file as removed.

.. include:: examples/results/daily.rename.status.lxo


As with the results of a ``hg copy``, we must use the ``-C`` option to ``hg status`` to see that the added file is really being tracked by Mercurial as a copy of the original,
now removed, file.

.. include:: examples/results/daily.rename.status-copy.lxo


As with ``hg remove`` and ``hg copy``, you can tell Mercurial about a rename after the fact using the ``--after`` option. In most other respects, the
behavior of the ``hg rename`` command, and the options it accepts, are similar to the ``hg copy`` command.

If you're familiar with the Unix command line, you'll be glad to know that ``hg rename`` command can be invoked as ``hg mv``.

Renaming files and merging changes
----------------------------------

Since Mercurial's rename is implemented as copy-and-remove, the same propagation of changes happens when you merge after a rename as after a copy.

If I modify a file, and you rename it to a new name, and then we merge our respective changes, my modifications to the file under its original name
will be propagated into the file under its new name. (This is something you might expect to “simply work,” but not all revision control systems
actually do this.)

Whereas having changes follow a copy is a feature where you can perhaps nod and say “yes, that might be useful,” it should be clear that having them
follow a rename is definitely important. Without this facility, it would simply be too easy for changes to become orphaned when files are renamed.

Divergent renames and merging
-----------------------------

The case of diverging names occurs when two developers start with a file—let's call it ``foo``\ —in their respective repositories.

.. include:: examples/results/rename.divergent.clone.lxo


Anne renames the file to ``bar``.

.. include:: examples/results/rename.divergent.rename.anne.lxo


Meanwhile, Bob renames it to ``quux``. (Remember that ``hg mv`` is an alias for ``hg rename``.)

.. include:: examples/results/rename.divergent.rename.bob.lxo


I like to think of this as a conflict because each developer has expressed different intentions about what the file ought to be named.

What do you think should happen when they merge their work? Mercurial's actual behavior is that it always preserves *both* names when it merges
changesets that contain divergent renames.

.. include:: examples/results/rename.divergent.merge.lxo


Notice that while Mercurial warns about the divergent renames, it leaves it up to you to do something about the divergence after the merge.

Convergent renames and merging
------------------------------

Another kind of rename conflict occurs when two people choose to rename different *source* files to the same *destination*. In this case, Mercurial
runs its normal merge machinery, and lets you guide it to a suitable resolution.

Other name-related corner cases
-------------------------------

Mercurial has a longstanding bug in which it fails to handle a merge where one side has a file with a given name, while another has a directory with
the same name. This is documented as `issue 29 <https://bz.mercurial-scm.org/show_bug.cgi?id=29>`__.

.. include:: examples/results/issue29.go.lxo


Recovering from mistakes
~~~~~~~~~~~~~~~~~~~~~~~~

Mercurial has some useful commands that will help you to recover from some common mistakes.

The ``hg revert`` command lets you undo changes that you have made to your working directory. For example, if you ``hg add`` a file by accident, just
run ``hg revert`` with the name of the file you added, and while the file won't be touched in any way, it won't be tracked for adding by Mercurial any
longer, either. You can also use ``hg revert`` to get rid of erroneous changes to a file.

It is helpful to remember that the ``hg revert`` command is useful for changes that you have not yet committed. Once you've committed a change, if you
decide it was a mistake, you can still do something about it, though your options may be more limited.

For more information about the ``hg revert`` command, and details about how to deal with changes you have already committed, see :ref:`chap:undo\ <chap:undo\>`.

Dealing with tricky merges
~~~~~~~~~~~~~~~~~~~~~~~~~~

In a complicated or large project, it's not unusual for a merge of two changesets to result in some headaches. Suppose there's a big source file
that's been extensively edited by each side of a merge: this is almost inevitably going to result in conflicts, some of which can take a few tries to
sort out.

Let's develop a simple case of this and see how to deal with it. We'll start off with a repository containing one file, and clone it twice.

.. include:: examples/results/ch04-resolve.init.lxo


In one clone, we'll modify the file in one way.

.. include:: examples/results/ch04-resolve.left.lxo


In another, we'll modify the file differently.

.. include:: examples/results/ch04-resolve.right.lxo


Next, we'll pull each set of changes into our original repo.

.. include:: examples/results/ch04-resolve.pull.lxo


We expect our repository to now contain two heads.

.. include:: examples/results/ch04-resolve.heads.lxo


Normally, if we run ``hg merge`` at this point, it will drop us into a GUI that will let us manually resolve the conflicting edits to ``myfile.txt``. However, to simplify
things for presentation here, we'd like the merge to fail immediately instead. Here's one way we can do so.

.. include:: examples/results/ch04-resolve.export.lxo


We've told Mercurial's merge machinery to run the command ``false`` (which, as we desire, fails immediately) if it detects a merge that it can't sort
out automatically.

If we now fire up ``hg merge``, it should grind to a halt and report a failure.

.. include:: examples/results/ch04-resolve.merge.lxo


Even if we don't notice that the merge failed, Mercurial will prevent us from accidentally committing the result of a failed merge.

.. include:: examples/results/ch04-resolve.cifail.lxo


When ``hg commit`` fails in this case, it suggests that we use the unfamiliar ``hg resolve`` command. As usual, ``hg help resolve`` will print a
helpful synopsis.

File resolution states
----------------------

When a merge occurs, most files will usually remain unmodified. For each file where Mercurial has to do something, it tracks the state of the file.

-  A *resolved* file has been successfully merged, either automatically by Mercurial or manually with human intervention.

-  An *unresolved* file was not merged successfully, and needs more attention.

If Mercurial sees *any* file in the unresolved state after a merge, it considers the merge to have failed. Fortunately, we do not need to restart the
entire merge from scratch.

The ``--list`` or ``-l`` option to ``hg resolve`` prints out the state of each merged file.

.. include:: examples/results/ch04-resolve.list.lxo


In the output from ``hg resolve``, a resolved file is marked with ``R``, while an unresolved file is marked with ``U``. If any files are listed with ``U``, we know that
an attempt to commit the results of the merge will fail.

Resolving a file merge
----------------------

We have several options to move a file from the unresolved into the resolved state. By far the most common is to rerun ``hg resolve``. If we pass the
names of individual files or directories, it will retry the merges of any unresolved files present in those locations. We can also pass the ``--all``
or ``-a`` option, which will retry the merges of *all* unresolved files.

Mercurial also lets us modify the resolution state of a file directly. We can manually mark a file as resolved using the ``--mark`` option, or as
unresolved using the ``--unmark`` option. This allows us to clean up a particularly messy merge by hand, and to keep track of our progress with each
file as we go.

More useful diffs
~~~~~~~~~~~~~~~~~

The default output of the ``hg diff`` command is backwards compatible with the regular ``diff`` command, but this has some drawbacks.

Consider the case where we use ``hg rename`` to rename a file.

.. include:: examples/results/ch04-diff.rename.basic.lxo


The output of ``hg diff`` above obscures the fact that we simply renamed a file. The ``hg diff`` command accepts an option, ``--git`` or ``-g``, to
use a newer diff format that displays such information in a more readable form.

.. include:: examples/results/ch04-diff.rename.git.lxo


This option also helps with a case that can otherwise be confusing: a file that appears to be modified according to ``hg status``, but for which
``hg diff`` prints nothing. This situation can arise if we change the file's execute permissions.

.. include:: examples/results/ch04-diff.chmod.lxo


The normal ``diff`` command pays no attention to file permissions, which is why ``hg diff`` prints nothing by default. If we supply it with the ``-g`` option, it tells us what really happened.

.. include:: examples/results/ch04-diff.chmod.git.lxo


Which files to manage, and which to avoid
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Revision control systems are generally best at managing text files that are written by humans, such as source code, where the files do not change much
from one revision to the next. Some centralized revision control systems can also deal tolerably well with binary files, such as bitmap images.

For instance, a game development team will typically manage both its source code and all of its binary assets (e.g. geometry data, textures, map
layouts) in a revision control system.

Because it is usually impossible to merge two conflicting modifications to a binary file, centralized systems often provide a file locking mechanism
that allow a user to say “I am the only person who can edit this file”.

Compared to a centralized system, a distributed revision control system changes some of the factors that guide decisions over which files to manage
and how.

For instance, a distributed revision control system cannot, by its nature, offer a file locking facility. There is thus no built-in mechanism to
prevent two people from making conflicting changes to a binary file. If you have a team where several people may be editing binary files frequently,
it may not be a good idea to use Mercurial—or any other distributed revision control system—to manage those files.

When storing modifications to a file, Mercurial usually saves only the differences between the previous and current versions of the file. For most
text files, this is extremely efficient. However, some files (particularly binary files) are laid out in such a way that even a small change to a
file's logical content results in many or most of the bytes inside the file changing. For instance, compressed files are particularly susceptible to
this. If the differences between each successive version of a file are always large, Mercurial will not be able to store the file's revision history
very efficiently. This can affect both local storage needs and the amount of time it takes to clone a repository.

To get an idea of how this could affect you in practice, suppose you want to use Mercurial to manage an OpenOffice document. OpenOffice stores
documents on disk as compressed zip files. Edit even a single letter of your document in OpenOffice, and almost every byte in the entire file will
change when you save it. Now suppose that file is 2MB in size. Because most of the file changes every time you save, Mercurial will have to store all
2MB of the file every time you commit, even though from your perspective, perhaps only a few words are changing each time. A single frequently-edited
file that is not friendly to Mercurial's storage assumptions can easily have an outsized effect on the size of the repository.

Even worse, if both you and someone else edit the OpenOffice document you're working on, there is no useful way to merge your work. In fact, there
isn't even a good way to tell what the differences are between your respective changes.

There are thus a few clear recommendations about specific kinds of files to be very careful with.

-  Files that are very large and incompressible, e.g. ISO CD-ROM images, will by virtue of sheer size make clones over a network very slow.

-  Files that change a lot from one revision to the next may be expensive to store if you edit them frequently, and conflicts due to concurrent edits
   may be difficult to resolve.

Backups and mirroring
~~~~~~~~~~~~~~~~~~~~~

Since Mercurial maintains a complete copy of history in each clone, everyone who uses Mercurial to collaborate on a project can potentially act as a
source of backups in the event of a catastrophe. If a central repository becomes unavailable, you can construct a replacement simply by cloning a copy
of the repository from one contributor, and pulling any changes they may not have seen from others.

It is simple to use Mercurial to perform off-site backups and remote mirrors. Set up a periodic job (e.g. via the ``cron`` command) on a remote server
to pull changes from your master repositories every hour. This will only be tricky in the unlikely case that the number of master repositories you
maintain changes frequently, in which case you'll need to do a little scripting to refresh the list of repositories to back up.

If you perform traditional backups of your master repositories to tape or disk, and you want to back up a repository named ``myrepo``, use ``hg clone -U myrepo myrepo.bak`` to create a clone of ``myrepo`` before you start your backups. The ``-U`` option doesn't check out a working
directory after the clone completes, since that would be superfluous and make the backup take longer.

If you then back up ``myrepo.bak`` instead of ``myrepo``, you will be guaranteed to have a consistent snapshot of your repository that won't be pushed
to by an insomniac developer in mid-backup.
