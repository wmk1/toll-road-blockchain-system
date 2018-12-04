pragma solidity ^0.4.24;

import "./interfaces/MultiplierHolderI.sol";
import "./Owned.sol";

contract MultiplierHolder is Owned, MultiplierHolderI {

    mapping(uint => uint) internal multipliers;

    event LogMultiplierSet(address indexed sender, uint indexed vehicleType, uint multiplier);

    constructor() public {}

    function setMultiplier(uint _vehicleType, uint _newMultiplier) public fromOwner returns(bool success) {
        require(_vehicleType > 0, "Vehicle type cannot be 0");
        require(multipliers[_vehicleType] != _newMultiplier, "New multiplier must be different than current one.");
        multipliers[_vehicleType] = _newMultiplier;
        emit LogMultiplierSet(msg.sender, _vehicleType, _newMultiplier);
        return true;
    }

    function getMultiplier(uint _vehicleType) public view returns(uint multiplier) {
        return multipliers[_vehicleType]; 
    }
}