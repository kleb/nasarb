From - Mon Nov 12 23:36:17 2001
Path: reznor.larc.nasa.gov!kant.larc.nasa.gov!logbridge.uoregon.edu!news-peer.gip.net!news.gsl.net!gip.net!newsfeed.mathworks.com!cyclone.swbell.net!easynews!sjc-peer.news.verio.net!news.verio.net!sea-read.news.verio.net.POSTED!not-for-mail
Sender: mikesl@thneed.na.wrq.com
Newsgroups: comp.emacs
Subject: Re: Re-centering buffer based on error line indicted in another buffer
References: <3BF03829.826F39CB@LaRC.NASA.Gov>
From: Michael Slass <mikesl@wrq.com>
Message-ID: <m3wv0vipqe.fsf@thneed.na.wrq.com>
Lines: 68
User-Agent: Gnus/5.09 (Gnus v5.9.0) Emacs/21.1
MIME-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Date: Mon, 12 Nov 2001 22:33:35 GMT
NNTP-Posting-Host: 150.215.90.102
X-Complaints-To: abuse@verio.net
X-Trace: sea-read.news.verio.net 1005604415 150.215.90.102 (Mon, 12 Nov 2001 22:33:35 GMT)
NNTP-Posting-Date: Mon, 12 Nov 2001 22:33:35 GMT
Organization: Verio
Xref: reznor.larc.nasa.gov comp.emacs:70829

Bil Kleb <W.L.Kleb@LaRC.NASA.Gov> writes:

>So, I have a mode that executes a command on the
>current buffer, and displays the resulting output
>in another buffer (with possibly some error messages
>which include line numbers in the original buffer).
>
>What I would like to have now is a function which
>scans the output buffer for errors (doing a regex
>pattern match?), and recenters the original buffer
>on the first error line indicated by the output buffer.
>(Auctex mode has a similar feature, but the code
>is much too involved for this newbie lisp brain to
>effectively decipher.)
>
>Any suggestions on references to search, keywords to
>use during a search, etc.?
>
>TIA,
>--
>bil <http://abweb.larc.nasa.gov/~kleb/>

Here's a quick kludge for this, if you don't want to try to adapt
compilation mode.  It's kludgey, but if you're lucky, some of the gurus
will give you (and me) pointers on how to make it less so.


(defvar bk-error-buffer
  "*error-buffer*"
  "Buffer name for error messages used by `bk-next-error'")

(defvar bk-error-message-regexp
  "error at line \\([0-9]+\\)"
  "Regular expression used by `bk-next-error' to find error messages.
The sub-expression between the first capturing parens must be the line
number where the error occured")


(defun bk-next-error ()
  "Goto line in current buffer indicated by next error message in `bk-error-buffer'

Assumes that the point is positioned before the first occurance of
`bk-error-message-regexp' in the `bk-error-buffer' before the first
call to this function.

See also `bk-error-message-regexp' `bk-error-buffer'"
  
  (interactive)
  (let ((error-line-number))
    (save-current-buffer
      (set-buffer (or (get-buffer bk-error-buffer)
                      (error
                       (concat
                        "Can't find the error buffer: "
                        bk-error-buffer))))
      (if (re-search-forward bk-error-message-regexp nil t)
          (progn
            (setq error-line-number
                  (string-to-number
                   (buffer-substring (match-beginning 1)
                                     (match-end 1))))
            (goto-char (1+ (match-end 1))))))
    (if error-line-number
        (goto-line error-line-number)
      (message "No more errors"))))

-- 
Mike
