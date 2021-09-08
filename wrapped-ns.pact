(define-keyset 'wrapped-ns-user)
(define-keyset 'wrapped-ns-admin)
(ns.write-registry (read-msg 'ns )
  (keyset-ref-guard 'wrapped-ns-admin ) true)
(define-namespace
  (read-msg 'ns)
  (keyset-ref-guard 'wrapped-ns-user)
  (keyset-ref-guard 'wrapped-ns-admin)
)
