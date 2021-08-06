(load "fungible-reference.pact")
(USE fungible-v2-reference)

(define-keyset 'admin-keyset (read-keyset "admin-keyset"))
(define-keyset 'minter-keyset (read-keyset "minter-keyset"))
(define-keyset 'burner-keyset (read-keyset "burner-keyset"))
(define-keyset 'revoker-keyset (read-keyset "revoker-keyset"))
(define-keyset 'blacklister-keyset (read-keyset "blacklister-keyset"))

(module tokensoftToken 'admin-keyset
  
  (defun initialize (name)

    (defschema tokenSpec
        name:string
        symbol:string
        decimals:decimal
        )
    
      (deftable users:{user})

)
