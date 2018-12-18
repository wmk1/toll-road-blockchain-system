pragma solidity ^0.4.24;

import "./interfaces/OwnedI.sol";


contract Owned is OwnedI {
  
    address internal owner;

    modifier fromOwner {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    event LogOwnerSet(address indexed previousOwner, address indexed newOwner);

    constructor() public {
        owner = msg.sender;
    }

    function setOwner(address _newOwner) public fromOwner returns(bool) {
        require(_newOwner != 0, "New owner cannot be 0 address");
        require(_newOwner != msg.sender, "New owner must be different than sender");
        owner = _newOwner;
        emit LogOwnerSet(msg.sender, owner);
        return true;
    }

    function getOwner() public view returns(address) {
        return owner;
    }
}