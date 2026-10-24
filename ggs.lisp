;;; Convenient aggregate packages

(uiop:define-package #:ggs
    (:use #:ggs/common #:ggs/eqsat #:ggs/stochastic)
  (:reexport #:ggs/common #:ggs/eqsat #:ggs/stochastic))

(uiop:define-package #:ggs-user
  (:use #:cl #:ggs))
