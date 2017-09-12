pragma solidity ^0.4.13;

contract FleetI {
    event LogVehicleCreated(address indexed sender, address indexed newVehicle);
    event LogVehicleRetired(address indexed sender, address indexed retiredVehicle);
    event LogVehicleAdded(address indexed sender, address indexed addedVehicle);

    function createVehicle(uint vehicleClass) returns(address vehicle);

    function retireVehicle(address vehicle) returns(bool success);

    function addVehicle(address vehicle) returns(bool success);
}