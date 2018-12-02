pragma solidity ^0.4.24;

import "./Owned.sol";
import "./Pausable.sol";
import "./Regulated.sol";
import "./MultiplierHolder.sol";
import "./DepositHolder.sol";
import "./RoutePriceHolder.sol";
import "./interfaces/TollBoothOperatorI.sol";
import "./Regulator.sol";
import "./TollBoothHolder.sol";

contract TollBoothOperator is Owned, Pausable, DepositHolder, TollBoothHolder, 
MultiplierHolder, RoutePriceHolder, Regulated, TollBoothOperatorI {

    struct Entry {
        address vehicle;
        uint multiplier;
        address entryBooth;
        uint depositedWeis;
    }

    struct Payment {
        address entryBooth;
        address exitBooth;
        bytes32 secretHashed;
    }

      /*
     A RouteMetadata is a store of data about a route
     - pendingPaymentCount: number of current pending payments
     - clearedPaymentCount: number of payments that were once pending, but are now settled
     - pendingPayments: mapping of index -> exit secret hash, where indices represent an ordered history of pending payments
     A RouteMetadata is accessible in the mapping routesMetadata, keyed on the hash of (entryBooth, exitBooth) for a given route
    */
    struct RouteMetadata {
        uint pendingPaymentCount;
        uint clearedPaymentCount;
        mapping(uint => bytes32) pendingPayments;
    }

    mapping(bytes32 => uint) routePrices;

    mapping(bytes32 => Entry) entries;

    mapping(bytes32 => Payment[]) collectedPayments;

    mapping(bytes32 => RouteMetadata) routesMetadata;

    uint collectedFees;

    event LogRoadEntered(address indexed vehicle, address indexed entryBooth, bytes32 indexed exitSecretHashed, uint depositedWeis);
    event LogRoadExited(address indexed exitBooth, bytes32 indexed exitSecretHashed, uint finalFee, uint refundWeis);
    event LogPendingPayment(bytes32 indexed exitSecretHashed, address indexed entryBooth, address indexed exitBooth);
    event LogFeesCollected(address indexed owner,  uint amount);

    constructor(bool _state, uint _deposit, address _regulator) 
    Pausable(_state) 
    DepositHolder(_deposit)
    Regulated(_regulator) public {
        paused = _state;
        deposit = _deposit;
        regulator = _regulator;
    }

    function setRegulator(address _regulator) public returns(bool success) {
        regulator = _regulator;
        return true;
    }

    function getRegulator() public view returns(RegulatorI _regulator) {
        return RegulatorI(_regulator);
    }

    function enterRoad(address _entryBooth, bytes32 exitSecretHashed) public payable returns(bool success) {
        require(!isPaused(), "State cannot be paused");
        require(isTollBooth(_entryBooth), "Entry booth must be toll booth");
        Regulator roadRegulator = Regulator(getRegulator());
        uint vehicleMultiplier = multiplier[roadRegulator.vehicles(msg.sender)];
        require(vehicleMultiplier > 0, "Vehicle multiplier must be bigger than 0");
        require(msg.value >= deposit * vehicleMultiplier, "Deposit must be bigger or equal!");
        entries[exitSecretHashed] = Entry(msg.sender, vehicleMultiplier, _entryBooth, msg.value);
        emit LogRoadEntered(msg.sender, _entryBooth, exitSecretHashed, msg.value);
        return true;
    }

    function getVehicleEntry(bytes32 exitSecretHashed) public view returns(address vehicle, address entryBooth, uint depositedWeis) {
        Entry storage entry = entries[exitSecretHashed];
        return (entry.vehicle, entry.entryBooth, entry.depositedWeis);
    }

    function reportExitRoad(bytes32 exitSecretClear) public returns(uint status) {
        require(isTollBooth(msg.sender), "It has to not be toll booth");
        return routePrices[exitSecretClear];
    }

    function getPendingPaymentCount(address entryBooth, address exitBooth) public view returns (uint count) {
        return collectedPayments[keccak256(abi.encodePacked(entryBooth, exitBooth))].length;
    }

    function clearSomePendingPayments(address entryBooth, address exitBooth, uint count) public returns (bool success) {
        require(paused, "Must be paused");
        require(count > 0, "Count must be bigger than 0");
        bytes32 _hash = keccak256(abi.encodePacked(entryBooth, exitBooth));
        uint price = routePrices[_hash];
        if (price > 0) {
            Payment[] storage payments = collectedPayments[_hash];
            require(payments.length >= count, "Payments length must be bigger than payments count");
            collectedFees += price * count;
            for(uint i = 0; i < count; i++) {
                Payment storage payment = payments[i];
                Entry storage _entry = entries[payment.secretHashed];
                uint refund = _entry.depositedWeis - price;
                address _vehicle = _entry.vehicle;
                require(refund < _entry.depositedWeis, "Refund cannot be bigger than deposited weis of vehicle entry");
                delete payments[i];
                entries[payment.secretHashed] = Entry(0, 0, 0, 0);
                emit LogRoadExited(msg.sender, payment.secretHashed, price, refund);
                _vehicle.transfer(refund);
            }
        }
        return true;
    }

    function getCollectedFeesAmount() public view returns(uint amount) {
        return amount;
    }

    function setRoutePrice(address _entryBooth, address _exitBooth, uint _priceWeis) public fromOwner returns(bool succes) {
        super.setRoutePrice(_entryBooth, _exitBooth, _priceWeis);
        bytes32 hashed = keccak256(abi.encodePacked(_entryBooth, _exitBooth));
        uint pendingPaymentCount = routesMetadata[hashed].pendingPaymentCount;
        if (pendingPaymentCount > 0) {
            clearSomePendingPayments(_entryBooth, _exitBooth, pendingPaymentCount);
        }
        return true;
    }

    function withdrawCollectedFees() public returns(bool success) {
        uint collected = collectedFees;
        collectedFees = 0;
        getOwner().transfer(collected);
        emit LogFeesCollected(getOwner(), collected);
        return true;
    }

    function hashSecret(bytes32 secret) public view returns(bytes32 _hash) {
        return keccak256(abi.encodePacked(secret));
    }

    function () public {
        
    }
}