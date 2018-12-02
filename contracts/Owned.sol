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
        owner = msg.sender;
    }

    function setOwner(address newOwner) public returns(bool success) {
        require(newOwner != msg.sender, "New owner cannot be current owner");
        require(newOwner != 0, "New owner cannot be 0 address");
        owner = newOwner;
        emit LogOwnerSet(newOwner, owner);
        return true;
    }

    function getOwner() public view returns(address){
        return owner;
    }
}