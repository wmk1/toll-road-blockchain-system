pragma solidity ^0.4.24;

import "./interfaces/RegulatorI.sol";
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
        require(_vehicle != 0x0, "Vehicle address cannot be 0");
        require(vehicles[_vehicle] != _vehicleType, "Choosen vehicle type cannot be the same");
        vehicles[_vehicle] = _vehicleType;
        emit LogVehicleTypeSet(msg.sender, _vehicle, _vehicleType);
        return true;
    }

    function getVehicleType(address _vehicle) public view returns(uint _vehicleType) {
        return vehicles[_vehicle];
    }

    function createNewOperator(address _owner, uint _deposit) public fromOwner returns(TollBoothOperatorI) {
        require(msg.sender != _owner, "New operator cannot be a sender of a contract");
        TollBoothOperator newOperator = new TollBoothOperator(true, _deposit, this);
        newOperator.setOwner(_owner);
        emit LogTollBoothOperatorCreated(msg.sender, newOperator, _owner, _deposit);
        operators[newOperator] = true;
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