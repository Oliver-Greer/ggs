(uiop:define-package :ggs/eqsat
    (:use #:cl #:alexandria #:ggs/common)
  (:import-from #:serapeum #:lret #:lret* #:-> #:collecting)
  (:import-from #:bind #:bind)
  (:export #:make-enode #:enode-fsym #:enode-arg #:enode-n-args
           #:do-enode-args #:map-enode-args #:make-egraph #:list-enodes
           #:enode-representative-p #:enode-canonical-p #:enode-eclass-info
           #:*egraph* #:enode-find #:enode-merge #:egraph-rebuild #:check-egraph
           #:egraph-n-enodes #:egraph-n-eclasses
           #:do-matches #:defrw #:defrw* #:yield-rewrite #:precompile-rule-set #:make-term #:run-rewrites
           #:define-analysis #:get-analysis-data #:make-or-test #:or-eql #:or-equal #:min-maybe
           #:build-term #:graph-cost #:tree-cost
           #:greedy-select #:greedy-extract #:lp-select #:lp-extract))

(serapeum:eval-always
  (trivial-package-local-nicknames:add-package-local-nickname
   '#:lp '#:linear-programming '#:ggs/eqsat))
