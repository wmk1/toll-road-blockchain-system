pragma solidity ^0.4.24;

import "./interfaces/MultiplierHolderI.sol";
import "./interfaces/OwnedI.sol";

contract MultiplierHolder is OwnedI, MultiplierHolderI {

    mapping(uint => uint) multiplier;

    event LogMultiplierSet(address indexed sender, uint indexed vehicleType, uint multiplier);

    constructor() public {

    }

    function setMultiplier(uint _vehicleType, uint _multiplier) public returns(bool success) {
        multiplier[_vehicleType] = _multiplier;
        emit LogMultiplierSet(msg.sender, _vehicleType, _multiplier);
        return true;
    }

    function getMultiplier(uint _vehicleType) view public returns(uint) {
        return multiplier[_vehicleType]; 
    }
}