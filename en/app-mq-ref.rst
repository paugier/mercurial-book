.. _chap:mqref:


Mercurial Queues reference
==========================

.. _sec:mqref:cmdref:


MQ command reference
~~~~~~~~~~~~~~~~~~~~

For an overview of the commands provided by MQ, use the command ``hg help mq``.

``qapplied``\ —print applied patches
-----------------------------------------

The ``qapplied`` command prints the current stack of applied patches. Patches are printed in oldest-to-newest order, so the last patch in the list is
the “top” patch.

``qcommit``\ —commit changes in the queue repository
---------------------------------------------------------

The ``qcommit`` command commits any outstanding changes in the ``.hg/patches`` repository. This command only works if the ``.hg/patches`` directory is
a repository, i.e. you created the directory using ``hg qinit`` or ran ``hg init`` in the directory after running ``qinit``.

This command is shorthand for ``hg commit --cwd .hg/patches``.

``qdelete``\ —delete a patch from the ``series`` file
----------------------------------------------------------

The ``qdelete`` command removes the entry for a patch from the ``series`` file in the ``.hg/patches`` directory. It does not pop the patch if the
patch is already applied. By default, it does not delete the patch file; use the ``-f`` option to do that.

Options:

-  ``-f``: Delete the patch file.

``qdiff``\ —print a diff of the topmost applied patch
----------------------------------------------------------

The ``qdiff`` command prints a diff of the topmost applied patch. It is equivalent to ``hg diff -r-2:-1``.

``qfinish``\ —move applied patches into repository history
---------------------------------------------------------------

The ``hg qfinish`` command converts the specified applied patches into permanent changes by moving them out of MQ's control so that they will be
treated as normal repository history.

``qfold``\ —merge (“fold”) several patches into one
--------------------------------------------------------

The ``qfold`` command merges multiple patches into the topmost applied patch, so that the topmost applied patch makes the union of all of the changes
in the patches in question.

The patches to fold must not be applied; ``qfold`` will exit with an error if any is. The order in which patches are folded is significant;
``hg qfold a b`` means “apply the current topmost patch, followed by ``a``, followed by ``b``”.

The comments from the folded patches are appended to the comments of the destination patch, with each block of comments separated by three asterisk
(“``*``”) characters. Use the ``-e`` option to edit the commit message for the combined patch/changeset after the folding has completed.

Options:

-  ``-e``: Edit the commit message and patch description for the newly folded patch.

-  ``-l``: Use the contents of the given file as the new commit message and patch description for the folded patch.

-  ``-m``: Use the given text as the new commit message and patch description for the folded patch.

``qheader``\ —display the header/description of a patch
------------------------------------------------------------

The ``qheader`` command prints the header, or description, of a patch. By default, it prints the header of the topmost applied patch. Given an
argument, it prints the header of the named patch.

``qimport``\ —import a third-party patch into the queue
------------------------------------------------------------

The ``qimport`` command adds an entry for an external patch to the ``series`` file, and copies the patch into the ``.hg/patches`` directory. It adds
the entry immediately after the topmost applied patch, but does not push the patch.

If the ``.hg/patches`` directory is a repository, ``qimport`` automatically does an ``hg add`` of the imported patch.

``qinit``\ —prepare a repository to work with MQ
-----------------------------------------------------

The ``qinit`` command prepares a repository to work with MQ. It creates a directory called ``.hg/patches``.

Options:

-  ``-c``: Create ``.hg/patches`` as a repository in its own right. Also creates a ``.hgignore`` file that will ignore the ``status`` file.

When the ``.hg/patches`` directory is a repository, the ``qimport`` and ``qnew`` commands automatically ``hg add`` new patches.

``qnew``\ —create a new patch
----------------------------------

The ``qnew`` command creates a new patch. It takes one mandatory argument, the name to use for the patch file. The newly created patch is created
empty by default. It is added to the ``series`` file after the current topmost applied patch, and is immediately pushed on top of that patch.

If ``qnew`` finds modified files in the working directory, it will refuse to create a new patch unless the ``-f`` option is used (see below). This
behavior allows you to ``qrefresh`` your topmost applied patch before you apply a new patch on top of it.

Options:

-  ``-f``: Create a new patch if the contents of the working directory are modified. Any outstanding modifications are added to the newly created
   patch, so after this command completes, the working directory will no longer be modified.

-  ``-m``: Use the given text as the commit message. This text will be stored at the beginning of the patch file, before the patch data.

``qnext``\ —print the name of the next patch
-------------------------------------------------

The ``qnext`` command prints the name name of the next patch in the ``series`` file after the topmost applied patch. This patch will become the
topmost applied patch if you run ``qpush``.

``qpop``\ —pop patches off the stack
-----------------------------------------

The ``qpop`` command removes applied patches from the top of the stack of applied patches. By default, it removes only one patch.

This command removes the changesets that represent the popped patches from the repository, and updates the working directory to undo the effects of
the patches.

This command takes an optional argument, which it uses as the name or index of the patch to pop to. If given a name, it will pop patches until the
named patch is the topmost applied patch. If given a number, ``qpop`` treats the number as an index into the entries in the series file, counting from
zero (empty lines and lines containing only comments do not count). It pops patches until the patch identified by the given index is the topmost
applied patch.

The ``qpop`` command does not read or write patches or the ``series`` file. It is thus safe to ``qpop`` a patch that you have removed from the
``series`` file, or a patch that you have renamed or deleted entirely. In the latter two cases, use the name of the patch as it was when you applied
it.

By default, the ``qpop`` command will not pop any patches if the working directory has been modified. You can override this behavior using the ``-f``
option, which reverts all modifications in the working directory.

Options:

-  ``-a``: Pop all applied patches. This returns the repository to its state before you applied any patches.

-  ``-f``: Forcibly revert any modifications to the working directory when popping.

-  ``-n``: Pop a patch from the named queue.

The ``qpop`` command removes one line from the end of the ``status`` file for each patch that it pops.

``qprev``\ —print the name of the previous patch
-----------------------------------------------------

The ``qprev`` command prints the name of the patch in the ``series`` file that comes before the topmost applied patch. This will become the topmost
applied patch if you run ``qpop``.

.. _sec:mqref:cmd:qpush:


``qpush``\ —push patches onto the stack
--------------------------------------------

The ``qpush`` command adds patches onto the applied stack. By default, it adds only one patch.

This command creates a new changeset to represent each applied patch, and updates the working directory to apply the effects of the patches.

The default data used when creating a changeset are as follows:

-  The commit date and time zone are the current date and time zone. Because these data are used to compute the identity of a changeset, this means
   that if you ``qpop`` a patch and ``qpush`` it again, the changeset that you push will have a different identity than the changeset you popped.

-  The author is the same as the default used by the ``hg commit`` command.

-  The commit message is any text from the patch file that comes before the first diff header. If there is no such text, a default commit message is
   used that identifies the name of the patch.

If a patch contains a Mercurial patch header, the information in the patch header overrides these defaults.

Options:

-  ``-a``: Push all unapplied patches from the ``series`` file until there are none left to push.

-  ``-l``: Add the name of the patch to the end of the commit message.

-  ``-m``: If a patch fails to apply cleanly, use the entry for the patch in another saved queue to compute the parameters for a three-way merge, and
   perform a three-way merge using the normal Mercurial merge machinery. Use the resolution of the merge as the new patch content.

-  ``-n``: Use the named queue if merging while pushing.

The ``qpush`` command reads, but does not modify, the ``series`` file. It appends one line to the ``hg status`` file for each patch that it pushes.

``qrefresh``\ —update the topmost applied patch
----------------------------------------------------

The ``qrefresh`` command updates the topmost applied patch. It modifies the patch, removes the old changeset that represented the patch, and creates a
new changeset to represent the modified patch.

The ``qrefresh`` command looks for the following modifications:

-  Changes to the commit message, i.e. the text before the first diff header in the patch file, are reflected in the new changeset that represents the
   patch.

-  Modifications to tracked files in the working directory are added to the patch.

-  Changes to the files tracked using ``hg add``, ``hg copy``, ``hg remove``, or ``hg rename``. Added files and copy and rename destinations are added
   to the patch, while removed files and rename sources are removed.

Even if ``qrefresh`` detects no changes, it still recreates the changeset that represents the patch. This causes the identity of the changeset to
differ from the previous changeset that identified the patch.

Options:

-  ``-e``: Modify the commit and patch description, using the preferred text editor.

-  ``-m``: Modify the commit message and patch description, using the given text.

-  ``-l``: Modify the commit message and patch description, using text from the given file.

``qrename``\ —rename a patch
---------------------------------

The ``qrename`` command renames a patch, and changes the entry for the patch in the ``series`` file.

With a single argument, ``qrename`` renames the topmost applied patch. With two arguments, it renames its first argument to its second.

``qseries``\ —print the entire patch series
------------------------------------------------

The ``qseries`` command prints the entire patch series from the ``series`` file. It prints only patch names, not empty lines or comments. It prints in
order from first to be applied to last.

``qtop``\ —print the name of the current patch
---------------------------------------------------

The ``qtop`` prints the name of the topmost currently applied patch.

``qunapplied``\ —print patches not yet applied
---------------------------------------------------

The ``qunapplied`` command prints the names of patches from the ``series`` file that are not yet applied. It prints them in order from the next patch
that will be pushed to the last.

``hg strip``\ —remove a revision and descendants
-----------------------------------------------------

The ``hg strip`` command removes a revision, and all of its descendants, from the repository. It undoes the effects of the removed revisions from the
repository, and updates the working directory to the first parent of the removed revision.

The ``hg strip`` command saves a backup of the removed changesets in a bundle, so that they can be reapplied if removed in error.

Options:

-  ``-b``: Save unrelated changesets that are intermixed with the stripped changesets in the backup bundle.

-  ``-f``: If a branch has multiple heads, remove all heads.

-  ``-n``: Do not save a backup bundle.

MQ file reference
~~~~~~~~~~~~~~~~~

The ``series`` file
-------------------

The ``series`` file contains a list of the names of all patches that MQ can apply. It is represented as a list of names, with one name saved per line.
Leading and trailing white space in each line are ignored.

Lines may contain comments. A comment begins with the “``#``” character, and extends to the end of the line. Empty lines, and lines that contain only
comments, are ignored.

You will often need to edit the ``series`` file by hand, hence the support for comments and empty lines noted above. For example, you can comment out
a patch temporarily, and ``qpush`` will skip over that patch when applying patches. You can also change the order in which patches are applied by
reordering their entries in the ``series`` file.

Placing the ``series`` file under revision control is also supported; it is a good idea to place all of the patches that it refers to under revision
control, as well. If you create a patch directory using the ``-c`` option to ``qinit``, this will be done for you automatically.

The ``status`` file
-------------------

The ``status`` file contains the names and changeset hashes of all patches that MQ currently has applied. Unlike the ``series`` file, this file is not
intended for editing. You should not place this file under revision control, or modify it in any way. It is used by MQ strictly for internal
book-keeping.