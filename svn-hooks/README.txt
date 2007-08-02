See http://rubyforge.org/docman/view.php/5/460/faq.html#syncmail for complete directions.

To install the post-commit hook,

 scp post-commit devel@rubyforge.org:/var/svn/nasarb/hooks

To turn it off, log in using sftp and run:

 sftp devel@rubyforge.org:/var/svn/nasarb/hooks
 sftp> rm post-commit
