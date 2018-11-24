pragma solidity ^0.4.24;

import "./interfaces/RegulatorI.sol";
import "./interfaces/TollBoothOperatorI.sol";
import "./TollBoothOperator.sol";
import "./Owned.sol";

contract Regulator is OwnedI, RegulatorI, TollBoothOperatorI, Owned {

    uint vehicleType;
    address regulator;
    mapping(address => uint) vehicles;
    mapping(address => TollBoothOperator) operators;

    /**
     * uint VehicleType:
     * 0: not a vehicle, absence of a vehicle
     * 1 and above: is a vehicle.
     * For instance:
     *   1: motorbike
     *   2: car
     *   3: lorry
     */
    event LogVehicleTypeSet( address indexed sender, address indexed vehicle, uint indexed vehicleType);
    event LogTollBoothOperatorRemoved(address indexed sender, address indexed operator);
    event LogTollBoothOperatorCreated(address indexed sender, address indexed newOperator, address indexed owner, uint depositWeis);

    function setVehicleType(address _vehicle, uint _vehicleType) public returns(bool success) {
        require(_vehicle != 0, "Vehicle address cannot be 0");
        vehicleType = vehicles[_vehicle];
        emit LogVehicleTypeSet(msg.sender, _vehicle, _vehicleType);
        return true;
    }

    function getVehicleType(address vehicle) public view returns(uint _vehicleType) {
        return vehicles[vehicle];
    }

    function createNewOperator(address _owner, uint _deposit) public returns(TollBoothOperatorI newOperator){
        require(msg.sender != owner, "New operator cannot be an owner of contract");
        TollBoothOperator operator = new TollBoothOperator(true, _deposit, msg.sender);
        emit LogTollBoothOperatorCreated(msg.sender, newOperator, _owner, _deposit);
        return operator;
    }  

    function removeOperator(address _operator) public returns(bool success) {
        delete operators[_operator];
        emit LogTollBoothOperatorRemoved(msg.sender, _operator);
        return true;
    }

    /**
     * @param operator The address of the TollBoothOperator to test. It should accept a 0 address.
     * @return Whether the TollBoothOperator is indeed approved.
     */
    function isOperator(address _operator) public view returns(bool indeed) {
        return (_operator == 0x0);
    }
}