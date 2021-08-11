(load "fungible-reference.pact")
(USE fungible-v2-reference)

(define-keyset 'admin-keyset (read-keyset "admin-keyset"))
(define-keyset 'minter-keyset (read-keyset "minter-keyset"))
(define-keyset 'burner-keyset (read-keyset "burner-keyset"))
(define-keyset 'revoker-keyset (read-keyset "revoker-keyset"))
(define-keyset 'blacklist-keyset (read-keyset "blacklist-keyset"))



(module wrappedToken GOV 

    @doc "Extends fungible-token-v2 with Wrapped.com capabilities"
  
    (implements fungible-v2)
  
    (defschema account-schema
      name:string
      symbol:string  
      balance:decimal
      guard:guard)
  
    (deftable ledger:{account-schema})
  
    (defcap GOV
        ()
    
        @doc " Give the admin full access to call and upgrade the module. "
    
        (enforce-guard (at 'guard (coin.details "admin-keyset")))
      )
      (defcap REVOKE
        ()

        @doc "Can revoke tokens and move them to any account"
    
        (enforce-guard (at 'guard (coin.details "revoker-keyset")))
      )
      (defcap BLACKLIST
        ()
    
        @doc "Can add principals to a blacklist that can prevent transfers"
    
        (enforce-guard (at 'guard (coin.details "blacklist-keyset")))
      )
    
    (defcap DEBIT (sender:string)
      "Capability for managing debiting operations"
      (enforce-guard (at 'guard (read ledger sender)))
      (enforce (!= sender "") "valid sender"))
  
    (defcap CREDIT (receiver:string)
      "Capability for managing crediting operations"
      (enforce (!= receiver "") "valid receiver"))
  
    (defcap TRANSFER:bool
      ( sender:string
        receiver:string
        amount:decimal
        memo:string
      )
      @managed amount TRANSFER-mgr
      (enforce (!= sender receiver) "same sender and receiver")
      (enforce-unit amount)
      (enforce (> amount 0.0) "Positive amount")
      (compose-capability (DEBIT sender))
      (compose-capability (CREDIT receiver))
    )
  
    (defun TRANSFER-mgr:decimal
      ( managed:decimal
        requested:decimal
      )
  
      (let ((newbal (- managed requested)))
        (enforce (>= newbal 0.0)
          (format "TRANSFER exceeded for balance {}" [managed]))
        newbal)
    )
  
    (defun enforce-unit:bool (amount:decimal)
      @doc "Enforce minimum precision allowed for coin transactions"
  
      (enforce
        (= (floor amount (precision))
           amount)
        (format "Amount violates minimum precision: {}" [amount]))
      )
  
  
    (defun create-account:string (account:string guard:guard)
      (enforce-guard guard)
      (insert ledger account
        { "balance" : 0.0
        , "guard"   : guard
        })
      "Account created"
      )
  
    (defun get-balance:decimal (account:string)
      (with-read ledger account
        { "balance" := balance }
        balance
        )
      )
  
    (defun details:object{fungible-v2.account-details}
      ( account:string )
      (with-read ledger account
        { "balance" := bal
        , "guard" := g }
        { "account" : account
        , "balance" : bal
        , "guard": g })
      )
  
    (defun rotate:string (account:string new-guard:guard)
      (with-read ledger account
        { "guard" := old-guard }
  
        (enforce-guard old-guard)
  
        (update ledger account
          { "guard" : new-guard }
          ))
      )
  
  
    (defun precision:integer ()
      8)
  
    (defun debit:string (account:string amount:decimal)
      @doc "Debit AMOUNT from ACCOUNT balance"
  
      @model [ (property (> amount 0.0)) ]
  
      (enforce (> amount 0.0)
        "debit amount must be positive")
  
      (enforce-unit amount)
  
      (require-capability (DEBIT account))
      (with-read ledger account
        { "balance" := balance }
  
        (enforce (<= amount balance) "Insufficient funds")
  
        (update ledger account
          { "balance" : (- balance amount) }
          ))
      )
  
  
    (defun credit:string (account:string guard:guard amount:decimal)
      @doc "Credit AMOUNT to ACCOUNT balance"
  
      @model [ (property (> amount 0.0)) ]
  
      (enforce (> amount 0.0) "credit amount must be positive")
      (enforce-unit amount)
  
      (require-capability (CREDIT account))
      (with-default-read ledger account
        { "balance" : 0.0, "guard" : guard }
        { "balance" := balance, "guard" := retg }
        ; we don't want to overwrite an existing guard with the user-supplied one
        (enforce (= retg guard)
          "account guards do not match")
  
        (write ledger account
          { "balance" : (+ balance amount)
          , "guard"   : retg
          })
        ))
  
    (defun transfer:string (sender:string receiver:string amount:decimal)
      @model [ (property (> amount 0.0))
               (property (!= sender receiver)) ]
  
      (enforce (!= sender receiver)
        "sender cannot be the receiver of a transfer")
  
      (enforce (> amount 0.0)
        "transfer amount must be positive")
  
      (enforce-unit amount)
  
      (with-capability (TRANSFER sender receiver amount)
        (debit sender amount)
        (with-read ledger receiver
          { "guard" := g }
  
          (credit receiver g amount))
        )
      )
  
    (defun transfer-create:string
      ( sender:string
        receiver:string
        receiver-guard:guard
        amount:decimal )
  
      (enforce (!= sender receiver)
        "sender cannot be the receiver of a transfer")
  
      (enforce (> amount 0.0)
        "transfer amount must be positive")
  
      (enforce-unit amount)
  
      (with-capability (TRANSFER sender receiver amount)
        (debit sender amount)
        (credit receiver receiver-guard amount))
      )

    (defschema blacklist-schema
      account:string
      restricted:bool  
    )
    (deftable blacklist:{blacklist-schema})

    (defun blacklist-account:string (account:string guard:guard) BLACKLIST
    ;;(enforce-guard guard)
    (insert blacklist account
      { "account":account 
      , "restricted":true
      })
    "Account blacklisted"
    )
      
    (defun is-blacklisted:bool (account:string)
      (with-read ledger account
        { "restricted" := true }
        account
        )
      )  
    (defun update-blacklist:bool (restricted:bool) BLACKLIST
      (update blacklist account
        { "restricted" :restricted }
        )
    )


    ;;TODO: finish restrictions
    (defun transferRestriction:string
      ( sender:string
        receiver:string
        amount:decimal
      )
      @doc "Test Transfer AMOUNT between accounts SENDER and RECEIVER. \
           \ Fails if either SENDER or RECEIVER is in blacklist."
      @model [ (property (> amount 0.0))
               (property (!= is-blacklisted sender))
               (property (!= is-blacklisted receiver))
             ]
      )


      (defun revoke:string REVOKE
        ( revoke-address:string
          amount:decimal
        )
        @doc "Revoke a balance from an address back to the caller's address"
        @model [ (property (> amount 0.0))
                 (property (!= revoke-address ""))
               ]
      )
  
    (defschema crosschain-schema
      @doc "Schema for yielded value in cross-chain transfers"
      receiver:string
      receiver-guard:guard
      amount:decimal)
  
    (defpact transfer-crosschain:string
      ( sender:string
        receiver:string
        receiver-guard:guard
        target-chain:string
        amount:decimal
      )
     (step
       (with-capability (TRANSFER sender receiver amount)
  
         (enforce (!= "" target-chain) "empty target-chain")
         (enforce (!= (at 'chain-id (chain-data)) target-chain)
           "cannot run cross-chain transfers to the same chain")
  
         (enforce-unit amount)
  
         ;; step 1 - debit sender on current chain
         (debit sender amount)
  
         (yield
           (let ((v:object{crosschain-schema}
                  { "receiver" : receiver
                  , "receiver-guard" : receiver-guard
                  , "amount" : amount
                  }))
              v)
           target-chain)))
  
     (step
       (resume
         { "receiver" := receiver
         , "receiver-guard" := receiver-guard
         , "amount" := amount
         }
         (with-capability (CREDIT receiver)
           (credit receiver receiver-guard amount))
         ))
     )
  )