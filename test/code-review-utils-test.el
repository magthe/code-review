;;; code-review-utils-test.el --- Test our utility functions
;;; Commentary:
;;; Code:

(require 'a)
(require 'buttercup)
(require 'code-review-utils)

(defconst sample-grouped-comments
  (a-alist
   "github.el:42" (list '((position . 42) (path . "github.el") (author . "test-1"))
                        '((position . 42) (path . "github.el") (author . "test-2")))))

(defconst sample-comment-written-lines
  (a-alist
   "github.el" 0))

(defconst sample-comment-lines
  (list "This need to be changed"
        "Improve this code please"))

(describe "COMMENTS"

  (it "are grouped by path and position"
    (expect (code-review-utils--comment-key "github.el" 42)
            :to-equal "github.el:42"))

  (it "have helper access function"
    (let ((comments (code-review-utils--comment-get sample-grouped-comments "github.el:42")))
      (expect (length comments) :to-equal 2)
      (expect comments :to-contain '((position . 42)
                                     (path . "github.el")
                                     (author . "test-2")))))

  (it "the input comment buffers have placeholder text that needs to be removed on write"
    (let ((placeholder-msg ";;; This is a placeholder in a buffer")
          (full-msg ";;; This is a placeholder in a buffer\nThis is my real comment"))
      (expect (code-review-utils--comment-clean-msg full-msg placeholder-msg)
              :to-equal "This is my real comment"))

    (let ((placeholder-msg ";;; This is a placeholder in a buffer")
          (full-msg ";;; This is a placeholder in a bufferThis is my real comment"))
      (expect (code-review-utils--comment-clean-msg full-msg placeholder-msg)
              :to-equal "This is my real comment")))

  (it "we need to keep track of how many lines was written for each buffer + 1 new line."
    (expect (code-review-utils--comment-update-written-count sample-comment-written-lines "github.el" sample-comment-lines)
            :to-equal (a-alist "github.el" 3))
    (expect (code-review-utils--comment-update-written-count (a-alist "github.el" 5) "github.el" sample-comment-lines)
            :to-equal (a-alist "github.el" 8))))

(describe "GIT")

(describe "URL PARSE"

  (it "given a valid URL of a PR returns an PR-ALIST"
    (expect (code-review-utils-pr-from-url "https://github.com/eval-all-software/tempo/pull/98")
            :to-equal (a-alist
                       'num "98"
                       'repo "tempo"
                       'owner "eval-all-software"))))

(describe "COLORS")

(describe "SECTION"

  (it "compute true diff position discounting written comment lines in the buffer."
    (let* ((path "github.el")
           (hunks (a-alist path 2))
           (count-comments (a-alist path 3))
           (curr-pos 10))
      (expect (code-review-utils--section-diff-at-pos hunks count-comments path curr-pos)
              :to-equal 5))))

(provide 'code-review-utils-test)
;;; code-review-utils-test.el ends here
