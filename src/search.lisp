
(in-package #:procon)

;;;; search

(defun piece->flatten-primirative-piece-synth (piece)
  (flatten-tree-func-test 
   #'(lambda (piec) (and (null (piece-synth-to piec))
                         (null (piece-synth-from piec))))
   #'(lambda (piec) (list (synth-piece (piece-synth-to piec))
                          (synth-piece (piece-synth-from piec))))
   piece))


(defun piece->ability-synth-list (piece)
  (mapcar
   #'(lambda (consed)
       (synth piece (car consed) (cdr consed)))
   (zip-list (list *plus* *minus*)
             (upto 0 (1- (length (piece-spots piece)))))))

(defun synth+synth-list->synthesizeable-list (synth synth-list)
  (list-of-maybe->maybe-list
   (remove *nothing* 
           (mapcar #'(lambda (synth2)
                       (synthesize-able?--also--maybe-consed-easy-piece 
                        synth synth2))
               synth-list))))

(defun synth+piece->synthesizeable-list (synth piece)
  (synth+synth-list->synthesizeable-list
   synth (piece->ability-synth-list piece)))

(defun synth+piece->synthesizeable-list-test ()
  ;; test
  (let* ((test-synth *test-synth-n1*)
         (test-piece *test-piece-n2*))
    (let-maybe
        ((synthesizeable-list 
          (synth+piece->synthesizeable-list test-synth test-piece)))
      (let* ((synthable-list
              (cons (synth->easy-piece test-synth)
                    (mapcar #'cdr synthesizeable-list)))
             (synthed-list
              (mapcar #'(lambda (sy-able-cons)
                          (synthesize-syntesizeable-easy-piece 
                           (car sy-able-cons) (cdr sy-able-cons)))
                      synthesizeable-list)))
        (show-easy-piece-list 
         (append synthable-list synthed-list)))
      )))
      

(defun synthesize-piece-list-all (piece1 piece2)
  ;; (show-piece-list (synthesize-piece-list-all *test-piece1* *test-piece-n1*))
  ;; (synthesize-piece-list-all *test-piece1* *test-piece1*)
  (let* ((ziped-list (zip-list (piece->ability-synth-list piece1)
                               (piece->ability-synth-list piece2)))
         (list-maybe
          (mapcar #'(lambda (consed)
                      (format t "# " )
                      (maybe-synthesize-piece (car consed) (cdr consed)))
                  ziped-list)))
    (print (length ziped-list))
    (remove *nothing* list-maybe)))




(defun equivalent-piece (piece1 piece2)
  )

(defun piece-shape= (piece1 piece2)
  "if same shape piece"
  (let* ((piece2-is-frame-adjust-ed
          (if (equal (piece-is-frame piece1) (piece-is-frame piece2))
              (piece->piece-s-not-frame-piece piece2) piece2))
         (piece-list (synthesize-piece-list-all piece1 piece2-is-frame-adjust-ed)))
    (find-if #'is-nil-piece piece-list)))


;;;; tree
(defun when-cons-car (test-var)
  (if (consp test-var) (car test-var) test-var))

(defun when-cons-cdr (test-var)
  (if (consp test-var) (cdr test-var) nil))

(defun show-param (indent name var)
  (format t "~&~V@{  ~}~A :: ~A~%" indent name var)
  var)

(defun flatten-tree-func (test-end next-tree-list tree)
  "<ex> (flatten-tree-func-test #'numberp #'cdr '(1 2 (3 (4 (6 7 8 9) 5 ()))))  
 (2 7 8 9 5) "
  (cond ((null tree) nil)
        ((funcall test-end tree) tree)
        (t (flatten (mapcar
                     #'(lambda (next-tree)
                                (flatten-tree-func test-end next-tree-list next-tree))
                     (funcall next-tree-list tree))))))

(defun flatten-tree-func-test (test-end next-tree-list tree &optional (stage 0))
  "<ex> (flatten-tree-func-test #'numberp #'cdr '(1 2 (3 (4 (6 7 8 9) 5 ()))))  
 (2 7 8 9 5) "
  (show-param stage "=======================" "")
  (show-param stage "lecel" stage)
  (show-param stage "tree" tree)
  (unless (show-param stage "test" (funcall test-end tree))
    (show-param stage "next" (funcall next-tree-list tree)))
  (let ((retu
         (cond ((null tree) nil) ;; should fix
               ((funcall test-end tree)  tree)
               (t (flatten (mapcar
                            #'(lambda (next-tree)
                                (flatten-tree-func-test test-end next-tree-list next-tree
                                                        (+ stage 1)))
                            (funcall next-tree-list tree)))))))
    (show-param stage "retu" retu)))

(defun flatten-tree-list (tree)
  (cond ((null tree) nil)
        ((listp tree) (append (flatten-tree-list (car tree))
                              (flatten-tree-list (cdr tree))))
        (t (list tree))))


