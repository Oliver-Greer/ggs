(in-package :ggs/eqsat)

(lp-hash-table:define-hash-table ordered-table sxhash eql :optimize ())

(defun compute-analysis-clause (fsym clauses merge)
  `(,fsym
    ,@(mapcar
       (lambda (clause)
         (destructuring-bind ((fsym-1 &rest args) &rest body) clause
           (assert (eql fsym-1 fsym))
           (labels ((process (args i)
                      (if args
                          (if (var-p (car args))
                              `(let ((,(car args) (enode-arg ,i top-enode)))
                                 ,(process (cdr args) (1+ i)))
                              `(let ((arg-enode (enode-arg ,i top-enode)))
                                 ,(expand-match
                                   (list 'arg-enode) (parse-pattern (car args) 'arg-enode)
                                   (process (cdr args) (1+ i)))))
                          `(setf result (funcall ,merge result (locally ,@body))))))
             `(when (= (enode-n-args top-enode) ,(length args))
                ,(process args 0)))))
       clauses)))

(defun compute-make-lambda (merge bottom clauses)
  (let ((clauses-by-fsym (make-ordered-table)))
    (dolist (clause clauses)
      (when (var-p (caar clause))
        (error "DEFINE-ANALYSIS does not yet support variable fsym: ~a" clause))
      (ordered-table-put (caar clause)
                         (cons clause (ordered-table-get (caar clause) clauses-by-fsym))
                         clauses-by-fsym))
    `(lambda (top-enode)
       (macrolet ((get-analysis-data (name enode)
                    `(enode-analysis-data ',name ,enode)))
         (let ((result ,bottom))
           (case (enode-fsym top-enode)
             ,@(collecting
                 (map-ordered-table
                  (lambda (fsym clauses)
                    (collect (compute-analysis-clause fsym clauses merge)))
                  clauses-by-fsym)))
           result)))))

(defvar *compiled-makes* (make-hash-table :test 'equal))

(defun compiled-analysis (name)
  (bind (((:plist merge bottom clauses) (get-analysis name)))
    (make-analysis-info
     :name name :merge merge :bottom bottom
     :make (ensure-gethash (list merge bottom clauses) *compiled-makes*
                           (compile nil (compute-make-lambda merge bottom clauses))))))

;;; Convenient merge functions

(declaim (inline make-or-test or-eql or-equal min-maybe))
(defun make-or-test (test)
  (lambda (x y)
    (if x (if y (if (funcall test x y) x (error "Conflicting values: ~a vs ~a" x y)) x) y)))

;; At least SBCL has no problem fully inline these...
(defun or-eql (x y)
  "Like OR, but check (EQL X Y) if they are both non-nil."
  (funcall (make-or-test #'eql) x y))

(defun or-equal (x y)
  "Like OR, but check (EQUAL X Y) if they are both non-nil."
  (funcall (make-or-test #'equal) x y))

(defun min-maybe (x y)
  "Like MIN, but NIL stands for positive infinity."
  (if x (if y (min x y) x) y))
