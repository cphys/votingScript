# Voting Script
## Included files
* votingScript.wl -- a mathematica script used to automate entering of votes in 
online voting forums.

## Dependencies
* [mullvad vpn](https://mullvad.net/)

* Currently only tested using Linux and [Firefox](https://www.mozilla.org/en-US/firefox/new/)

## About
* Script works with [mullvad vpn](https://mullvad.net/) via linux command line 
to cycle through all available VPN servers and cast votes on desired website.
 
* A new instance of firefox is opened for each voting instance and closed upon 
completion of voting.

* Script was designed to cast votes in very low stakes online polls. It will 
change ip-address and open and close new session of Firefox allowing deletion of 
cookies with each vote.

* Currently set up to run in parallel across number of kernels defined by 
Mathematica license.
