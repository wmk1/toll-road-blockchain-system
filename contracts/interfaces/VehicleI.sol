pragma solidity ^0.4.13;

contract VehicleI {
    function enterRoad(
            address entryBooth,
            bytes32 exitSecretHashed)
        public
        payable
        returns(bool success);

    function exitRoad(bytes32 exitSecretClear)
        public
        returns (uint status);

    function withdraw() public returns(bool success);
}