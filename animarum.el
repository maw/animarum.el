(require 'subr-x)

(defvar animarum-table (make-hash-table :test #'equal))
(defvar animarum-current-layout nil)
(defvar animarum-do-sit-for nil)

(defun animarum-maybe-sit-for (nsec)
  (if animarum-do-sit-for
      (sit-for ncsc)))

(defun animarum-maybe-replace (name)
  (let ((prompt (format "A layout named %s already exists.  Replace it?" name)))
    (y-or-n-p prompt)))

(defun animarum-get-layouts ()
  (sort (hash-table-keys animarum-table) 'string<))

;; soon
(defun animarum-save ())

(defun animarum-put-and-save (name layout)
  (progn (message "setting %s -> %s to %s" name layout animarum-table)
         (animarum-maybe-sit-for 1)
         (progn (puthash name layout animarum-table)
                (animarum-save))))

(defun animarum-delete ()
  (interactive)
  (let* ((names (animarum-get-layouts))
         (name (completing-read
                "What layout do you want to get rid of? "
                names
                nil t "")))
    (progn (remhash name animarum-table)
           (animarum-save))))

(defun animarum-save-layout ()
  (interactive)
  (let* ((names (animarum-get-layouts))
         (name (completing-read
                "name for layout"
                names
                nil nil "")))
    (if (if (not (eq nil (gethash name animarum-table)))
            (animarum-maybe-replace name)
          t)
        (let ((layout (current-window-configuration)))
          (animarum-put-and-save name layout)))))

(defun animarum-save-current-layout ()
  (interactive)
  (let* ((current animarum-current-layout))
    (if (not (eq nil current))
        (if (y-or-n-p (format "Are you sure you want to overwrite layout `%s'? " current))
            (animarum-put-and-save current (current-window-configuration))))))

(defun animarum-set-layout ()
  (interactive)
  (let* ((names (animarum-get-layouts))
         (name (completing-read
                "What layout do you want? "
                names
                nil t ""))
         (config (gethash name animarum-table)))
    (progn (message "setting config: %s -> %s" name config)
           (animarum-maybe-sit-for 1)
           (set-window-configuration config)
           (setq animarum-current-layout name))))

(defun animarum-show-layout ()
  (interactive)
  (message (format "%s" animarum-current-layout)))

(defun animarum-list-layouts ()
  (interactive)
  (let ((layouts (animarum-get-layouts)))
    (message (format
              "These are your layouts: \n%s"
              (string-join (mapcar (lambda (n) (concat "* " n)) (animarum-get-layouts)) "\n")))))

(provide 'animarum)
