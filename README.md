# Wrapped Token on Kadena Blockchain.

The token attempts to implement the  KIP 5 standard.

# Role Based Access Control

The token has certain roles built into it to allow administrative actions. One or more keys can be granted each of the roles and a keyset can be granted multiple roles.  The following roles are available:

* Owner
* Minter
* Burner
* Revoker
* Blacklister

# Administrative Capabilities

### Minting
A principal with the `Minter` role can mint new tokens to any principal.  The total supply of the token will be increased when new tokens are minted.

### Burning
A principal with the `Burner` role can burn new tokens from any principal.  The total supply of the token will be decreased when existing tokens are burned.

### Revoking
A principal with the `Revoker` role can move tokens from any principal to another principal.

### Blacklisting
A principal with the `Blacklister` role can add or remove any principal to a blacklist.  Any transaction sending tokens `to` OR `from` a blacklisted account will be denied and the transaction will fail.

