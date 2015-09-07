(defun skip-to-next-blank-line ()
  (interactive)
  (let ((inhibit-changing-match-data t))
    (skip-syntax-forward " >")
    (unless (search-forward-regexp "^\\s *$" nil t)
      (goto-char (point-max)))))

(defun skip-to-previous-blank-line ()
  (interactive)
  (let ((inhibit-changing-match-data t))
    (skip-syntax-backward " >")
    (unless (search-backward-regexp "^\\s *$" nil t)
      (goto-char (point-min)))))

(defun html-wrap-in-tag (beg end)
  (interactive "r")
  (let ((oneline? (= (line-number-at-pos beg) (line-number-at-pos end))))
    (deactivate-mark)
    (goto-char end)
    (unless oneline? (newline-and-indent))
    (insert "</div>")
    (goto-char beg)
    (insert "<div>")
    (unless oneline? (newline-and-indent))
    (indent-region beg (+ end 11))
    (goto-char (+ beg 4))))

(defun --setup-simplezen ()
  (require 'simplezen)
  (set (make-local-variable 'yas-fallback-behavior)
       '(apply simplezen-expand-or-indent-for-tab)))

(add-hook 'sgml-mode-hook '--setup-simplezen)
(add-hook 'html-mode-hook '--setup-simplezen)

(eval-after-load "sgml-mode"
  '(progn
     ;; don't include equal sign in symbols
     (modify-syntax-entry ?= "." html-mode-syntax-table)

     (define-key html-mode-map [remap forward-paragraph] 'skip-to-next-blank-line)
     (define-key html-mode-map [remap backward-paragraph] 'skip-to-previous-blank-line)
     (define-key html-mode-map (kbd "C-c C-w") 'html-wrap-in-tag)
     (define-key html-mode-map (kbd "/") nil) ;; no buggy matching of slashes

     (define-key html-mode-map (kbd "C-c C-d") 'ng-snip-show-docs-at-point)

     (require 'tagedit)

     ;; paredit lookalikes
     (define-key html-mode-map (kbd "s-<right>") 'tagedit-forward-slurp-tag)
     (define-key html-mode-map (kbd "C-)") 'tagedit-forward-slurp-tag)
     (define-key html-mode-map (kbd "s-<left>") 'tagedit-forward-barf-tag)
     (define-key html-mode-map (kbd "C-}") 'tagedit-forward-barf-tag)
     (define-key html-mode-map (kbd "M-r") 'tagedit-raise-tag)
     (define-key html-mode-map (kbd "s-s") 'tagedit-splice-tag)
     (define-key html-mode-map (kbd "M-S") 'tagedit-split-tag)
     (define-key html-mode-map (kbd "M-J") 'tagedit-join-tags)
     (define-key html-mode-map (kbd "M-?") 'tagedit-convolute-tags)

     (tagedit-add-experimental-features)
     (add-hook 'html-mode-hook (lambda () (tagedit-mode 1)))
     ;;(add-hook 'web-mode-hook (lambda () (tagedit-mode 1))) ;;有故障

     ;; no paredit equivalents
     (define-key html-mode-map (kbd "M-k") 'tagedit-kill-attribute)
     (define-key html-mode-map (kbd "s-<return>") 'tagedit-toggle-multiline-tag)))

;; after deleting a tag, indent properly
(defadvice sgml-delete-tag (after reindent activate)
  (indent-region (point-min) (point-max)))



;;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
;; (require 'sgml-mode)
;; (require 'js)

;; (defvar cjsp-el-expr-face 'cjsp-el-expr-face
;;   "Face name to use for jstl el-expressions.")
;; (defface cjsp-el-expr-face
;;   '((((class color)) (:foreground "#FFFF00"))
;;     (t (:foreground "FFFF00")))
;;   "Face for jstl el-expressions.")

;; (defvar cjsp-font-lock-keywords
;;   (append
;;    sgml-font-lock-keywords-2
;;    (list
;;     (cons "\${[^}]+}" '(0 cjsp-el-expr-face t t))
;;     (cons "{{[^}}]+}}" '(0 cjsp-el-expr-face t t))
;;     )))

;; (defvar cjsp--script-tag-re
;;   "<script\\( type=\"text/javascript\"\\)?>")

;; (defun cjsp--in-script-tag (lcon)
;;   (and (eq (car lcon) 'text)
;;        (cdr lcon)
;;        (save-excursion
;;          (goto-char (cdr lcon))
;;          (looking-back cjsp--script-tag-re))))

;; (defun cjsp--in-pre-tag (lcon)
;;   (and (eq (car lcon) 'text)
;;        (cdr lcon)
;;        (save-excursion
;;          (goto-char (cdr lcon))
;;          (looking-back "<pre\\( [^>]*\\)?>\\(<code\\( [^>]*\\)?>\\)?"))))

;; (defun cjsp--script-indentation ()
;;   (if (or (looking-back (concat cjsp--script-tag-re "[\n\t ]+"))
;;           (looking-at "</script>"))
;;       (sgml-calculate-indent)
;;     (max (js--proper-indentation (save-excursion
;;                                    (syntax-ppss (point-at-bol))))
;;          (sgml-calculate-indent))))

;; (defun cjsp--in-jsp-comment (lcon)
;;   (and (eq (car lcon) 'tag)
;;        (looking-at "--%")
;;        (save-excursion (goto-char (cdr lcon)) (looking-at "<%--"))))

;; (defun cjsp--jsp-comment-indentation ()
;;   (forward-char 4)
;;   (max 0 (- (sgml-calculate-indent) 4)))

;; (defun jsp-calculate-indent (&optional lcon)
;;   (unless lcon (setq lcon (sgml-lexical-context)))
;;   (cond
;;    ((cjsp--in-pre-tag lcon)     nil) ; don't change indent in pre
;;    ((cjsp--in-script-tag lcon)  (cjsp--script-indentation))
;;    ((cjsp--in-jsp-comment lcon) (cjsp--jsp-comment-indentation))
;;    (t                           (sgml-calculate-indent lcon))))

;; (defun jsp-indent-line ()
;;   "Indent the current line as jsp."
;;   (interactive)
;;   (let* ((savep (point))
;;          (indent-col
;;           (save-excursion
;;             (back-to-indentation)
;;             (if (>= (point) savep) (setq savep nil))
;;             (jsp-calculate-indent))))
;;     (if (null indent-col)
;;         'noindent
;;       (if savep
;;           (save-excursion (indent-line-to indent-col))
;;         (indent-line-to indent-col)))))

;; (eval-after-load 'expand-region
;;   '(add-to-list 'expand-region-exclude-text-mode-expansions 'crappy-jsp-mode))

;; (define-derived-mode crappy-jsp-mode
;;   html-mode "Crappy JSP"
;;   "Major mode for jsp.
;;           \\{jsp-mode-map}"
;;   (setq indent-line-function 'jsp-indent-line)
;;   (setq font-lock-defaults '((cjsp-font-lock-keywords) nil t)))

;;+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
(tagedit-add-experimental-features)

(provide 'html-extra)

