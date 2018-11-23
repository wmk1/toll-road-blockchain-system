pragma solidity ^0.4.24;

import "./interfaces/OwnedI.sol";
import "./interfaces/PausableI.sol";
import "./interfaces/DepositHolderI.sol";
import "./interfaces/TollBoothHolderI.sol";
import "./interfaces/MultiplierHolderI.sol";
import "./interfaces/TollBoothOperatorI.sol";
import "./interfaces/RoutePriceHolderI.sol";
import "./interfaces/RegulatedI.sol";

contract TollBoothOperator is OwnedI, TollBoothOperatorI, PausableI, DepositHolderI, 
MultiplierHolderI, RoutePriceHolderI, TollBoothHolderI, RegulatedI {

    bool statePaused;
    uint depositWeis;
    address regulator;
    mapping(bytes32 => Vehi )

    event LogRoadEntered(address indexed vehicle, address indexed entryBooth, bytes32 indexed exitSecretHashed, uint depositedWeis);
    event LogRoadExited(address indexed exitBooth, bytes32 indexed exitSecretHashed, uint finalFee, uint refundWeis);
    event LogPendingPayment(bytes32 indexed exitSecretHashed, address indexed entryBooth, address indexed exitBooth);
    event LogFeesCollected(address indexed owner,  uint amount);

    constructor(bool _state, uint _depositWeis, address _regulator) public {
        require(_depositWeis > 0, "Deposit weis cannot be 0!");
        require(_regulator != 0, "Initial regulator cannot be 0!");
        regulator = _regulator;
    }

    function setRegulator(address _regulator) public returns(bool success) {
        regulatorVar = newRegulator;
        return true;
    }

    function getRegulator() constant public returns(RegulatorI regulator) {
        return RegulatorI(regulatorVar);
        
    }

    function enterRoad(address entryBooth, bytes32 exitSecretHashed) public payable returns(bool success) {
        require(!statePaused, "State cannot be paused");
        require(regulator != 0x0, "Vehicle must be registered");
        require(entryBooth != this, "Entry booth must be toll booth");
        require(msg.value >= depositWeis * multiplier, "Deposit must be bigger or equal!");

        emit LogRoadEntered(vehicle, entryBooth, exitSecretHashed, depositWeis);
        return true;
    }

    function getVehicleEntry(bytes32 exitSecretHashed) view public returns(address vehicle, address entryBooth, uint depositedWeis) {

    }

    function reportExitRoad(bytes32 exitSecretClear) public returns(uint status) {

    }

    function getPendingPaymentCount(address entryBooth, address exitBooth) view public returns (uint count) {
        return 1;
    }

    function clearSomePendingPayments(address entryBooth, address exitBooth, uint count) public returns(bool success) {
        
    }

    function getCollectedFeesAmount() view public returns(uint amount) {
        emit LogFeesCollected(msg.sender, amount);
        return amount;
    }

    function withdrawCollectedFees() public returns(bool success) {
        return true;
    }

    function hash() public returns(bytes32 _hash) {
        return abi.encodePacked(keccak256());
    }

    function () public {
        
    }
}