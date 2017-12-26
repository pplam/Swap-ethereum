pragma solidity ^0.4.19;

import "atn-contracts/ATN.sol";

contract Swap {
  function Swap(string _chain_id, address _atn, uint _required_proof_number) public {
    chainID = stringToBytes32(_chain_id);
    atn = ATN(_atn);
    requiredProofNumber = _required_proof_number;
    owner = msg.sender;
  }

  bytes32 public chainID;
  ATN public atn;

  event Log(string message);

  address public owner;
  mapping (address => bool) public whiteList;

  OutTx[] public outTxs;
  struct OutTx {
    address fromAddr;
    bytes32 toChain;
    address toAddr;
    uint amount;
  }

  uint public requiredProofNumber;
  mapping (bytes32 => mapping (uint => InTx)) public inTxs;
  struct InTx {
    mapping (address => mapping (uint => uint)) proofs;
    mapping (address => bool) provers;
    bool commited;
  }

  // need? Or just inTxs[_chain][_tx_id] == 0 is fine?
  /*
  function hasInTx(bytes32 _chain, uint _tx_idx)
    internal
    returns (bool)
  {
    return inTxs[_chain] != mapping (uint => InTx)(0)
      && inTxs[_chain][_tx_idx] != InTx(0);
  }
  */

  function setRequiredProofNumber(uint _number)
    public
    onlyOwner
    returns (bool)
  {
      requiredProofNumber = _number;
      return true;
  }

  function addProof(bytes32 _chain, uint _tx_idx, address _to, uint _amount)
    internal
    returns (uint)
  {
    InTx storage inTx = inTxs[_chain][_tx_idx];
    require(!inTx.provers[msg.sender]);
    require(!inTx.commited);

    inTx.proofs[_to][_amount]++;
    inTx.provers[msg.sender] = true;

    return inTx.proofs[_to][_amount];
  }

  function prove(string _from_chain, uint _tx_idx, address _to, uint _amount)
    public
    authorized
    returns (bool)
  {
    bytes32 fromChain = stringToBytes32(_from_chain);
    uint num = addProof(fromChain, _tx_idx, _to, _amount);
    if (num == requiredProofNumber) {
        inTxs[fromChain][_tx_idx].commited = true;
        atn.mint(_to, _amount);
    }
    return true;
  }

  function setOwner(address _owner)
    public
    onlyOwner
  {
    owner = _owner;
  }

  function permit(address _addr)
    public
    onlyOwner
  {
    whiteList[_addr] = true;
  }

  function forbid(address _addr)
    public
    onlyOwner
  {
    whiteList[_addr] = false;
  }

  modifier onlyOwner {
    require(msg.sender == owner);
    _;
  }

  modifier authorized {
    require(msg.sender == owner || whiteList[msg.sender]);
    _;
  }

  function stringToBytes32(string memory source)
    internal
    returns (bytes32 result)
  {
    bytes memory tempEmptyStringTest = bytes(source);
    if (tempEmptyStringTest.length == 0) {
      return 0x0;
    }

    assembly {
      result := mload(add(source, 32))
    }
  }
}
