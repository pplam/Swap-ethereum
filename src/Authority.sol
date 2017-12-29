pragma solidity ^0.4.19;

import "ds-auth/auth.sol";

contract Authority is DSAuth, DSAuthority {
  mapping (address => mapping (address => mapping (bytes4 => bool))) public whiteList;

  function permit(address src, address dst, bytes4 sig)
    public
    auth
    returns (bool)
  {
    whiteList[src][dst][sig] = true;
    return true;
  }

  function forbid(address src, address dst, bytes4 sig)
    public
    auth
    returns (bool)
  {
    whiteList[src][dst][sig] = false;
    return true;
  }


  function canCall(address src, address dst, bytes4 sig)
    public
    view
    returns (bool)
  {
    return whiteList[src][dst][sig];
  }
}
