pragma solidity ^0.4.19;

import "ds-auth/auth.sol"

contract WhiteListAuth is DSAuthority {
  mapping (address => bool) whiteList;

  function canCall(
      address src, address dst, bytes4 sig
  ) public constant returns (bool) {
    return whiteList[src]
  }
}

contract Swap is DSAuth {
  function Swap() {}
}
