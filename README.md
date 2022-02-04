<p align="center">
  <a href="https://wrapped.com/">
    <img src="wrapped.png" alt="Wrapped.com" width="600" style="border:none;"/>
  </a>
</p>

# Wrapped Token Standard on Kadena

This repository contains the source code (written in [Pact](https://pactlang.org/)) for assets on [Kadena](https://kadena.io/).

<!-- row 1 - status -->

[![GitHub contributors](https://img.shields.io/github/contributors/wrappedfi/wrapped_token_pact)](https://github.com/wrappedfi/wrapped_token_pact/graphs/contributors)
[![GitHub commit activity](https://img.shields.io/github/commit-activity/w/wrappedfi/wrapped_token_pact)](https://github.com/wrappedfi/wrapped_token_pact/graphs/contributors)
[![GitHub Stars](https://img.shields.io/github/stars/wrappedfi/wrapped_token_pact.svg)](https://github.com/wrappedfi/wrapped_token_pact/stargazers)
![GitHub repo size](https://img.shields.io/github/repo-size/wrappedfi/wrapped_token_pact)
[![GitHub](https://img.shields.io/github/license/wrappedfi/wrapped_token_pact?color=blue)](https://github.com/wrappedfi/wrapped_token_pact/blob/master/LICENSE)

<!-- row 2 - links & profiles -->

[![Website wrapped.com](https://img.shields.io/website-up-down-green-red/https/wrapped.com.svg)](https://wrapped.com)
[![Blog](https://img.shields.io/badge/blog-up-green)](http://medium.com/wrapped)
[![Docs](https://img.shields.io/badge/docs-up-green)](https://docs.wrapped.com/)
[![Twitter WrappedFi](https://img.shields.io/twitter/follow/wrappedfi?style=social)](https://twitter.com/wrappedfi)

<!-- row 3 - detailed status -->

[![GitHub pull requests by-label](https://img.shields.io/github/issues-pr-raw/wrappedfi/wrapped_token_pact)](https://github.com/wrappedfi/wrapped_token_pact/pulls)
[![GitHub Issues](https://img.shields.io/github/issues-raw/wrappedfi/wrapped_token_pact.svg)](https://github.com/wrappedfi/wrapped_token_pact/issues)

## Role Based Access Control

The token has certain roles built into it to allow administrative actions. One or more keys can be granted each of the roles and a keyset can be granted multiple roles.  The following roles are available:

* Owner
* Minter
* Burner
* Revoker
* Blacklister

## Administrative Capabilities

### Minting
A principal with the `Minter` role can mint new tokens to any principal.  The total supply of the token will be increased when new tokens are minted.

### Burning
A principal with the `Burner` role can burn new tokens from any principal.  The total supply of the token will be decreased when existing tokens are burned.

### Revoking
A principal with the `Revoker` role can move tokens from any principal to another principal.

### Blacklisting
A principal with the `Blacklister` role can add or remove any principal to a blacklist.  Any transaction sending tokens `to` OR `from` a blacklisted account will be denied and the transaction will fail.

