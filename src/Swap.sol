pragma solidity ^0.4.19;

import "erc20/erc20.sol";

contract Swap {
  ERC20 public ATN;

  address public owner;
  mapping (address => bool) public whiteList;

  uint public requiredProofNumber;
  mapping (string => uint) public proofList;

  function Swap(address _atn) {
    owner = msg.sender;
    ATN = ERC20(_atn);
  }

  function setOwner(address owner_)
    public
    onlyOwner
  {
    owner = owner_;
  }

  function permit(address addr)
    public
    onlyOwner
  {
    whiteList[addr] = true;
  }

  function forbid(address addr)
    public
    onlyOwner
  {
    whiteList[addr] = false;
  }

  modifier onlyOwner {
    require(msg.sender == owner);
    _;
  }

  modifier authorized {
    require(msg.sender == owner || whiteList[msg.sender]);
    _;
  }
}
