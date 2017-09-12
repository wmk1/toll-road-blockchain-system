pragma solidity ^0.4.13;

contract TollBoothI {
    event LogFareSet(address indexed sender, uint indexed vehicleClass, uint weis);
    event LogFarePaid(address indexed payer, uint indexed vehicleClass, uint weis);
    event LogFaresCollected(address indexed sender, uint weis);

    function getFare(uint vehicleClass) constant returns(uint weis);

    function setFare(uint vehicleClass, uint weis) returns(bool success);

    function payFare() payable returns(bool success);

    function collectFares() returns(bool success);
}