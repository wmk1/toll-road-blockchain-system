pragma solidity ^0.4.24;

import "./interfaces/RegulatorI.sol";
import "./interfaces/OwnedI.sol";
import "./interfaces/TollBoothOperatorI.sol";

contract Regulator is OwnedI, RegulatorI, TollBoothOperatorI {

    uint vehicleType;
    address vehicle;
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
        require(sender == msg.sender, "Caller must be owner");
        require(_vehicle != 0x0, "Vehicle address cannot be 0");
        vehicleType = vehicles[vehicle];
        emit LogVehicleTypeSet(msg.sender, _vehicle, _vehicleType);
        return true;
    }

    function getVehicleType(address vehicle) view public returns(uint vehicleType) {
        return vehicles[vehicle];
    }

    function createNewOperator(address owner, uint _deposit) public returns(TollBoothOperatorI newOperator){
        TollBoothOperator operator = new TollBoothOperator(true, this, deposit);
        operator.setOwner(owner);
        operators[owner] = owner;
        emit LogTollBoothOperatorCreated(msg.sender, operator, owner, deposit);
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
    function isOperator(address _operator) view public returns(bool indeed) {
        return (_operator == 0x0);
    }
}