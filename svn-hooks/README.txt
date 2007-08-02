See http://rubyforge.org/docman/view.php/5/460/faq.html#syncmail for complete directions.

To install the post-commit hook,

 sftp devel@rubyforge.org:/var/svn/nasarb/hooks

Then from sftp, run the following command:

 put post-commit
 chmod 755 post-commit

To turn it off, log in again using sftp, and run:

 rm post-commit
