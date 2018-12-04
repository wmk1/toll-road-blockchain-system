pragma solidity ^0.4.24;

import "./interfaces/RegulatorI.sol";
import "./interfaces/TollBoothOperatorI.sol";
import "./Owned.sol";
import "./TollBoothOperator.sol";

contract Regulator is Owned, RegulatorI {

    mapping(address => uint) public vehicles;
    mapping(address => bool) public operators;

    event LogVehicleTypeSet( address indexed sender, address indexed vehicle, uint indexed vehicleType);
    event LogTollBoothOperatorRemoved(address indexed sender, address indexed operator);
    event LogTollBoothOperatorCreated(address indexed sender, address indexed newOperator, address indexed owner, uint depositWeis);

    constructor() public {}

    function setVehicleType(address _vehicle, uint _vehicleType) public fromOwner returns(bool success) {
        require(_vehicle > 0, "Vehicle address cannot be 0");
        require(vehicles[_vehicle] != _vehicleType, "Choosen vehicle type cannot be the same");
        vehicles[_vehicle] = _vehicleType;
        emit LogVehicleTypeSet(msg.sender, _vehicle, _vehicleType);
        return true;
    }

    function getVehicleType(address vehicle) public view returns(uint _vehicleType) {
        return vehicles[vehicle];
    }

    function createNewOperator(address _owner, uint _deposit) public fromOwner returns(TollBoothOperatorI _newOperator) {
        require(owner != _owner, "New operator cannot be an owner of contract");
        TollBoothOperator newOperator = new TollBoothOperator(true, _deposit, this);
        newOperator.setOwner(_owner);
        operators[_owner] = true;
        emit LogTollBoothOperatorCreated(msg.sender, newOperator, _owner, _deposit);
        return newOperator;
    }  

    function removeOperator(address _operator) public fromOwner returns(bool success) {
        operators[_operator] = false;
        emit LogTollBoothOperatorRemoved(msg.sender, _operator);
        return true;
    }

    function isOperator(address _operator) public view returns(bool indeed) {
        return operators[_operator];
    }
}