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
import "./SafeMath.sol";

contract TollBoothOperator is Owned, Pausable, DepositHolder, TollBoothHolder, 
MultiplierHolder, RoutePriceHolder, Regulated, TollBoothOperatorI {

    using SafeMath for uint;

    struct Entry {
        address vehicle;
        uint multiplier;
        address entryBooth;
        uint depositedWeis;
    }

    struct RouteMetadata {
        uint pendingPaymentCount;
        uint clearedPaymentCount;
        mapping(uint => bytes32) pendingPayments;
    }

    mapping(bytes32 => Entry) internal entries;

    mapping(bytes32 => RouteMetadata) internal routesMetadata;

    uint internal collectedFees;

    event LogRoadEntered(address indexed vehicle, address indexed entryBooth, bytes32 indexed exitSecretHashed, uint depositedWeis);
    event LogRoadExited(address indexed exitBooth, bytes32 indexed exitSecretHashed, uint finalFee, uint refundWeis);
    event LogPendingPayment(bytes32 indexed exitSecretHashed, address indexed entryBooth, address indexed exitBooth);
    event LogFeesCollected(address indexed owner, uint amount);
    
    constructor(bool _state, uint _deposit, address _regulator)
    public 
    Pausable(_state) 
    DepositHolder(_deposit)
    Regulated(_regulator) { 
        paused = _state;
        deposit = _deposit;
        regulator = _regulator;
    }

    function () public payable {
        revert();
    }

    function enterRoad(address _entryBooth, bytes32 _exitSecretHashed) public payable whenNotPaused returns (bool success) {
        require(isTollBooth(_entryBooth), "Entry booth must be toll booth");
        require(entries[_exitSecretHashed].vehicle == 0x0, "Vehicle cannot be 0.");
        Regulator roadRegulator = Regulator(getRegulator());
        uint vehicleMultiplier = multipliers[roadRegulator.vehicles(msg.sender)];
        require(vehicleMultiplier > 0, "Vehicle multiplier must be bigger than 0");
        require(msg.value >= deposit.mul(vehicleMultiplier), "Deposit must be bigger or equal!");
        entries[_exitSecretHashed] = Entry(msg.sender, vehicleMultiplier, _entryBooth, msg.value);
        emit LogRoadEntered(msg.sender, _entryBooth, _exitSecretHashed, msg.value);
        return true;
    }

    function getVehicleEntry(bytes32 _exitSecretHashed) public view returns(address vehicle, address entryBooth, uint depositedWeis) {
        Entry storage entry = entries[_exitSecretHashed];
        return (entry.vehicle, entry.entryBooth, entry.depositedWeis);
    }

    function reportExitRoad(bytes32 _exitSecretClear) public whenNotPaused returns(uint status) {
        require(isTollBooth(msg.sender), "Sender has to be toll booth");
        bytes32 exitSecretHashed = hashSecret(_exitSecretClear);
        require(entries[exitSecretHashed].vehicle != 0x0 && entries[exitSecretHashed].depositedWeis != 0, "Neither vehicle cannot be 0 and deposited weis cannot be 0");
        Entry storage entry = entries[exitSecretHashed];
        require(Regulator(getRegulator()).vehicles(entry.vehicle) > 0, "Vehicle type cannot be 0.");
        require(entry.entryBooth != msg.sender, "Entry booth cannot be a sender of contract");
        uint price = priceHolders[keccak256(abi.encodePacked(entry.entryBooth, msg.sender))];
        if (price > 0) {
            uint refund;
            uint finalFee;
            (refund, finalFee) = executePayment(exitSecretHashed, price);
            emit LogRoadExited(msg.sender, exitSecretHashed, finalFee, refund);
            return 1;
        } else {
            RouteMetadata storage metadata = routesMetadata[keccak256(abi.encodePacked(entry.entryBooth, msg.sender))];
            uint index = metadata.pendingPaymentCount + metadata.clearedPaymentCount;
            metadata.pendingPayments[index] = exitSecretHashed;
            metadata.pendingPaymentCount++;
            emit LogPendingPayment(exitSecretHashed, entry.entryBooth, msg.sender);
            return 2;
        }
    }
    
    function getPendingPaymentCount(address entryBooth, address exitBooth) public view returns (uint count) {
        return routesMetadata[keccak256(abi.encodePacked(entryBooth, exitBooth))].pendingPaymentCount;
    }

    function clearSomePendingPayments(address _entryBooth, address _exitBooth, uint _count) public whenNotPaused returns (bool success) {
        require(_count > 0, "Count must be bigger than 0!");
        bytes32 _hash = keccak256(abi.encodePacked(_entryBooth, _exitBooth));
        uint routePrice = priceHolders[_hash];
        if (routePrice > 0) {
            RouteMetadata storage routeMetadata = routesMetadata[_hash];
            require(routeMetadata.pendingPaymentCount >= _count, "Pending payment must be bigger than given count");
            for (uint i = 0; i < _count; i++) {
                uint paymentIndex = routeMetadata.clearedPaymentCount;
                bytes32 exitSecretHashed = routeMetadata.pendingPayments[paymentIndex];
                uint refund;
                uint finalFee;
                (refund, finalFee) = executePayment(exitSecretHashed, routePrice);
                routeMetadata.pendingPayments[paymentIndex] = bytes32(0);
                routeMetadata.pendingPaymentCount--;
                routeMetadata.clearedPaymentCount++;
                emit LogRoadExited(_exitBooth, exitSecretHashed, finalFee, refund);
            }
        }
        return true;
    }

    function setRoutePrice(address _entryBooth, address _exitBooth, uint _priceWeis) public fromOwner returns(bool success) {
        super.setRoutePrice(_entryBooth, _exitBooth, _priceWeis);
        bytes32 bootsHashed = keccak256(abi.encodePacked(_entryBooth, _exitBooth));
        uint pendingPaymentCount = routesMetadata[bootsHashed].pendingPaymentCount;
        if (pendingPaymentCount > 0) {
            clearSomePendingPayments(_entryBooth, _exitBooth, 1);
        }
        return true;
    }

    function getCollectedFeesAmount() public view returns(uint amount) {
        return collectedFees;
    }

    function withdrawCollectedFees() public returns(bool success) {
        uint collected = collectedFees;
        collectedFees = 0;
        owner.transfer(collected);
        emit LogFeesCollected(owner, collected);
        return true;
    }

    function hashSecret(bytes32 _secret) public view returns(bytes32 _hash) {
        return keccak256(abi.encodePacked(_secret));
    }

    function executePayment(bytes32 _exitSecretHashed, uint _routePrice) private returns(uint refund, uint finalFee) {
        Entry storage entry = entries[_exitSecretHashed];
        uint vehiclePrice = _routePrice.mul(entry.multiplier);
        uint depositedWeis = entry.depositedWeis;
        if (vehiclePrice > depositedWeis) {
            refund = 0;
        } else {
            refund = depositedWeis - vehiclePrice;
        }
        finalFee = depositedWeis - refund;
        collectedFees += finalFee;
        entry.depositedWeis = 0;
        entry.vehicle.transfer(refund);
        return(refund, finalFee);
    }
}