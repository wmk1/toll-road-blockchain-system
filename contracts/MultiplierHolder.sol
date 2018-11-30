pragma solidity ^0.4.24;

import "./interfaces/MultiplierHolderI.sol";
import "./Owned.sol";

contract MultiplierHolder is Owned, MultiplierHolderI {

    mapping(uint => uint) multiplier;

    event LogMultiplierSet(address indexed sender, uint indexed vehicleType, uint multiplier);

    constructor() public {

    }

    function setMultiplier(uint _vehicleType, uint _multiplier) public returns(bool success) {
        require(owner == msg.sender, "Caller is not the owner of the contract");
        require(_vehicleType != 0, "Vehicle type cannot be 0");
        if (_multiplier == 0) {
            delete multiplier[_multiplier];
        }
        multiplier[_vehicleType] = _multiplier;
        emit LogMultiplierSet(msg.sender, _vehicleType, _multiplier);
        return true;
    }

    function getMultiplier(uint _vehicleType) view public returns(uint) {
        return multiplier[_vehicleType]; 
    }
}