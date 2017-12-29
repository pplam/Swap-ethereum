pragma solidity ^0.4.19;

import "ds-auth/auth.sol";
import "atn-contracts/ATN.sol";

contract Swap is DSAuth, ERC223ReceivingContract  {
  bytes32 public chainID;
  ATN public atn;
  mapping (bytes32 => bool) public dstChains;
  uint public requiredProofNumber;

  function Swap(
    bytes32 _chain_id,
    address _atn,
    uint _required_proof_number
  ) public {
    chainID = _chain_id;
    atn = ATN(_atn);
    requiredProofNumber = _required_proof_number;
  }

  function registerChain(bytes32 _chain_id)
    public
    auth
    returns (bool)
  {
    require(_chain_id != bytes32(0x0));
    dstChains[_chain_id] = true;
    return true;
  }

  function setRequiredProofNumber(uint _number)
    public
    auth
    returns (uint)
  {
    require(_number > 0);
    requiredProofNumber = _number;
    return requiredProofNumber;
  }


  /*******************************[Source chain]********************************/


  OutTx[] public outTxs;
  struct OutTx {
    address fromAddr;
    bytes32 toChain;
    address toAddr;
    uint amount;
  }

  event SwapTx(
    bytes32 to_chain,
    uint tx_idx,
    address to_address,
    uint amount
  );

  function tokenFallback(
    address _from,
    uint _amount,
    bytes _data
  ) public {
    var (toChain, toAddr) = parseFallbackData(_data);
    require(dstChains[toChain]);
    swap(_from, toChain, toAddr, _amount);
  }


  function parseFallbackData(bytes _data)
    internal
    returns (bytes32 _chain, address _addr)
  {
    require(_data.length != 0);
    assembly {
      _chain := mload(add(_data, 32))
      _addr := mload(add(_data, 52))
    }
  }

  function swap(
    address _from,
    bytes32 _to_chain,
    address _to,
    uint _amount
  )
    public
    returns (bool)
  {
    atn.burn(this, _amount);

    uint idx = outTxs.push(OutTx({
      fromAddr: _from,
      toChain: _to_chain,
      toAddr: _to,
      amount: _amount
    })) - 1;
    SwapTx(_to_chain, idx, _to, _amount);

    return true;
  }


  /*******************************[Target chain]********************************/


  mapping (bytes32 => mapping (uint => InTx)) public inTxs;
  struct InTx {
    mapping (address => mapping (uint => uint)) proofs;
    mapping (address => bool) provers;
    bool commited;
  }

  event Proof(
    address prover,
    bytes32 from_chain,
    uint tx_idx,
    address to_address,
    uint amount
  );
  event Commited(
    address prover,
    bytes32 from_chain,
    uint tx_idx
  );

  function prove(
    bytes32 _from_chain,
    uint _tx_idx,
    address _to,
    uint _amount
  )
    public
    auth
    returns (bool)
  {
    Proof(msg.sender, _from_chain, _tx_idx, _to, _amount);

    uint num = addProof(_from_chain, _tx_idx, _to, _amount);
    if (num == requiredProofNumber) {
        inTxs[_from_chain][_tx_idx].commited = true;
        Commited(msg.sender, _from_chain, _tx_idx);
        atn.mint(_to, _amount);
    }

    return true;
  }

  function addProof(
    bytes32 _chain,
    uint _tx_idx,
    address _to,
    uint _amount
  )
    internal
    auth
    returns (uint)
  {
    InTx storage inTx = inTxs[_chain][_tx_idx];
    require(!inTx.provers[msg.sender]);
    require(!inTx.commited);

    inTx.proofs[_to][_amount]++;
    inTx.provers[msg.sender] = true;

    return inTx.proofs[_to][_amount];
  }
}
