
(namespace (read-msg 'ns))

(module wrapped-util GOVERNANCE

  (use free.wrapped-token-v1
    [ ROLE_MODULE_ADMIN ROLE_BURNER ROLE_MINTER
      ROLE_REVOKER ROLE_RESTRICT ])

  (defcap GOVERNANCE ()
    (enforce-keyset "free.wrapped-util-admin"))

  (defun all-roles ()
    [ ROLE_MODULE_ADMIN
      ROLE_MINTER
      ROLE_BURNER
      ROLE_REVOKER
      ROLE_RESTRICT
    ])

  (defun validate-role (role:string)
    (enforce (contains role (all-roles)) "Invalid role"))


  (defun enforce-valid-amount
    ( precision:integer
      amount:decimal
    )
    (enforce (> amount 0.0) "Positive non-zero amount")
    (enforce-precision precision amount)
  )

  (defun enforce-valid-account (account:string)
    (enforce (> (length account) 2) "minimum account length")
    (enforce (< (length account) 256) "minimum account length")
    (enforce (is-charset CHARSET_LATIN1 account) "valid charset")
  )

  (defun enforce-precision
    ( precision:integer
      amount:decimal
    )
    (enforce
      (= (floor amount precision) amount)
      "precision violation")
  )

  (defun enforce-valid-transfer
    ( sender:string
      receiver:string
      precision:integer
      amount:decimal )
    (enforce-valid-amount precision amount)
    (enforce-valid-account sender)
    (enforce-valid-account receiver)
  )

  (defun enforce-valid-interparty-transfer
    ( sender:string
      receiver:string
      precision:integer
      amount:decimal )
    (enforce-valid-transfer sender receiver precision amount)
    (enforce (!= sender receiver) "Transfer to same account prohibited")
  )

  (defun enforce-valid-xchain-transfer
    ( target-chain:string
      sender:string
      receiver:string
      precision:integer
      amount:decimal )
    (enforce-valid-transfer sender receiver precision amount)
    (enforce (!= "" target-chain) "empty target-chain")
    (enforce (!= (current-chain-id) target-chain)
      "cannot run cross-chain transfers to the same chain")
  )

  (defun enforce-transfer-manager:decimal
    ( managed:decimal
      requested:decimal
    )
    (let ((newbal (- managed requested)))
      (enforce (>= newbal 0.0)
        (format "TRANSFER exceeded for amount {}" [managed]))
      newbal)
  )

  (defun compute-debit:decimal (balance:decimal amount:decimal)
    (enforce (<= amount balance) "Insufficient funds")
    (- balance amount))

  (defun current-chain-id:string ()
    (at 'chain-id (chain-data))
  )


  (defun check-reserved:string (account:string)
    " Checks ACCOUNT for reserved name and returns type if \
    \ found or empty string. Reserved names start with a \
    \ single char and colon, e.g. 'c:foo', which would return 'c' as type."
    (let ((pfx (take 2 account)))
      (if (= ":" (take -1 pfx)) (take 1 pfx) "")))

  (defun enforce-reserved:bool (account:string guard:guard)
    @doc "Enforce reserved account name protocols."
    (let ((r (check-reserved account)))
      (if (= "" r) true
        (if (= "k" r)
          (enforce
            (= (format "{}" [guard])
               (format "KeySet {keys: [{}],pred: keys-all}"
                       [(drop 2 account)]))
            "Single-key account protocol violation")
          (enforce false
            (format "Unrecognized reserved protocol: {}" [r]))))))



)

(if (read-msg 'upgrade)
  ["upgrade"]
  [ (define-keyset "free.wrapped-util-admin" ) ]
)
