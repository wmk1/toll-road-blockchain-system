pragma solidity ^0.4.24;

import "./interfaces/OwnedI.sol";

contract Owned is OwnedI {
  
    address owner;

    modifier fromOwner {
        if (msg.sender != owner) revert();
        _;
    }

    event LogOwnerSet(address indexed previousOwner, address indexed newOwner);

    constructor() public {

    }

    function setOwner(address newOwner) public fromOwner returns(bool success){
        if (newOwner == owner && newOwner == 0) revert("New owner cannot be 0");
        emit LogOwnerSet(newOwner, owner);
        owner = newOwner;
        return true;
    }

    function getOwner() view public returns(address owner){
        return owner;
    }
}