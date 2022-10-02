(namespace "wrapped")
(define-keyset "wrapped.wrapped-ns-user")
(define-keyset "wrapped.wrapped-ns-admin")
(ns.write-registry (read-msg 'ns )
  (keyset-ref-guard "wrapped.wrapped-ns-admin" ) true)
(define-namespace
  (read-msg 'ns)
  (keyset-ref-guard "wrapped.wrapped-ns-user")
  (keyset-ref-guard "wrapped.wrapped-ns-admin")
)
