pragma solidity ^0.4.24;

import "./interfaces/RegulatorI.sol";
import "./interfaces/TollBoothOperatorI.sol";
import "./Owned.sol";
import "./TollBoothOperator.sol";

contract Regulator is Owned, RegulatorI {

    mapping(address => uint) public vehicles;
    mapping(address => TollBoothOperatorI) operators;

    event LogVehicleTypeSet( address indexed sender, address indexed vehicle, uint indexed vehicleType);
    event LogTollBoothOperatorRemoved(address indexed sender, address indexed operator);
    event LogTollBoothOperatorCreated(address indexed sender, address indexed newOperator, address indexed owner, uint depositWeis);

    constructor() public {
        
    }

    function setVehicleType(address _vehicle, uint _vehicleType) public returns(bool success) {
        require(_vehicle != 0, "Vehicle address cannot be 0");
        vehicles[_vehicle] = _vehicleType;
        emit LogVehicleTypeSet(msg.sender, _vehicle, _vehicleType);
        return true;
    }

    function getVehicleType(address vehicle) public view returns(uint _vehicleType) {
        return vehicles[vehicle];
    }

    function createNewOperator(address _owner, uint _deposit) public returns(TollBoothOperatorI newOperator){
        require(msg.sender != _owner, "New operator cannot be an owner of contract");
        newOperator = new TollBoothOperator(true, _deposit, this);
        operators[_owner] = newOperator;
        emit LogTollBoothOperatorCreated(msg.sender, newOperator, _owner, _deposit);
        return newOperator;
    }  

    function removeOperator(address _operator) public returns(bool success) {
        delete operators[_operator];
        emit LogTollBoothOperatorRemoved(msg.sender, _operator);
        return true;
    }

    function isOperator(address _operator) public view returns(bool indeed) {
        return (_operator == 0x0);
    }
}