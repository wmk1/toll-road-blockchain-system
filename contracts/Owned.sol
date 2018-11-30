pragma solidity ^0.4.24;

import "./interfaces/OwnedI.sol";

contract Owned is OwnedI {
  
    address internal owner;

    modifier fromOwner {
        require(msg.sender == owner, "Sender cannot be the same as owner");
        _;
    }

    event LogOwnerSet(address indexed previousOwner, address indexed newOwner);

    constructor() public {

    }

    function setOwner(address newOwner) public fromOwner returns(bool success) {
        require(msg.sender == owner, "Caller is not the current owner.");
        require(newOwner != owner, "New owner cannot be current owner");
        require(newOwner != 0x0, "New owner cannot be 0 address");
        if (newOwner == owner && newOwner == 0) revert("New owner cannot be 0");
        emit LogOwnerSet(newOwner, owner);
        owner = newOwner;
        return true;
    }

    function getOwner() public view returns(address){
        return owner;
    }
}