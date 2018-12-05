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

    struct RouteMetadata {
        uint pendingPaymentCount;
        uint clearedPaymentCount;
        mapping(uint => bytes32) pendingPayments;
    }

    mapping(bytes32 => uint) routePrices;

    mapping(bytes32 => Entry) internal entries;

    mapping(bytes32 => Payment[]) collectedPayments;

    mapping(bytes32 => RouteMetadata)  routesMetadata;

    uint internal collectedFees;

    event LogRoadEntered(address indexed vehicle, address indexed entryBooth, bytes32 indexed exitSecretHashed, uint depositedWeis);
    event LogRoadExited(address indexed exitBooth, bytes32 indexed exitSecretHashed, uint finalFee, uint refundWeis);
    event LogPendingPayment(bytes32 indexed exitSecretHashed, address indexed entryBooth, address indexed exitBooth);
    event LogFeesCollected(address indexed owner,  uint amount);


    
    constructor(bool _state, uint _deposit, address _regulator) 
    Pausable(_state) 
    DepositHolder(_deposit)
    Regulated(_regulator) public {  
        require(_deposit > 0, "Deposit cannot be 0");
        paused = _state;
        deposit = _deposit;
        regulator = _regulator;
    }

    function enterRoad(address _entryBooth, bytes32 _exitSecretHashed) public payable whenNotPaused returns (bool success) {
        require(isTollBooth(_entryBooth), "Entry booth must be toll booth");
        require(entries[_exitSecretHashed].vehicle == 0, "Vehicle cannot be 0.");
        Regulator roadRegulator = Regulator(getRegulator());
        uint vehicleMultiplier = multipliers[roadRegulator.vehicles(msg.sender)];
        require(vehicleMultiplier > 0, "Vehicle multiplier must be bigger than 0");
        require(msg.value >= deposit * vehicleMultiplier, "Deposit must be bigger or equal!");
        entries[_exitSecretHashed] = Entry(msg.sender, vehicleMultiplier, _entryBooth, msg.value);
        emit LogRoadEntered(msg.sender, _entryBooth, _exitSecretHashed, msg.value);
        return true;
    }


    //GIT
    function getVehicleEntry(bytes32 _exitSecretHashed) public view returns(address vehicle, address entryBooth, uint depositedWeis) {
        Entry storage entry = entries[_exitSecretHashed];
        return (entry.vehicle, entry.entryBooth, entry.depositedWeis);
    }

    //Fixed
    function reportExitRoad(bytes32 _exitSecretClear) public whenNotPaused returns(uint status) {
        require(isTollBooth(msg.sender), "Sender has to be toll booth");
        bytes32 exitSecretHashed = hashSecret(_exitSecretClear);
        require(entries[exitSecretHashed].vehicle != 0 && entries[exitSecretHashed].depositedWeis != 0, "Vehicle type cannot be 0.");
        Entry storage _entry = entries[exitSecretHashed];
        require(Regulator(getRegulator()).vehicles(_entry.vehicle) > 0, "Vehicle type cannot be 0.");
        require(_entry.entryBooth != msg.sender, "Entry booth cannot be a sender of contract");
        uint price = routePrices[keccak256(abi.encodePacked(_entry.entryBooth, msg.sender))];
        if (price > 0) {
            uint refund;
            uint finalFee;
            (refund, finalFee) = processPayment(exitSecretHashed, price);
            emit LogRoadExited(msg.sender, exitSecretHashed, finalFee, refund);
            return 1;
        } else {
            RouteMetadata storage metadata = routesMetadata[keccak256(abi.encodePacked(_entry.entryBooth, msg.sender))];
            uint index = metadata.pendingPaymentCount + metadata.clearedPaymentCount;
            metadata.pendingPayments[index] = exitSecretHashed;
            metadata.pendingPaymentCount++;
            emit LogPendingPayment(exitSecretHashed, _entry.entryBooth, msg.sender);
            return 2;
        }
    }

    function getPendingPaymentCount(address entryBooth, address exitBooth) public view returns (uint count) {
        return collectedPayments[keccak256(abi.encodePacked(entryBooth, exitBooth))].length;
    }

    function clearSomePendingPayments(address entryBooth, address exitBooth, uint count) public whenNotPaused returns (bool success) {
        require(!paused, "Must be paused");
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
            clearSomePendingPayments(_entryBooth, _exitBooth, 1);
        }
        return true;
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

    function () public {
        revert();
    }

    function processPayment(bytes32 exitSecretHashed, uint routePrice) private returns(uint refund, uint finalFee) {
        Entry storage _entry = entries[exitSecretHashed];
        uint vehiclePrice = routePrice * _entry.multiplier;
        uint depositedWeis = _entry.depositedWeis;
        if(vehiclePrice > depositedWeis) {
            refund = 0;
        } else {
            refund = depositedWeis - vehiclePrice;
        }
        finalFee = depositedWeis - refund;
        collectedFees += finalFee;
        _entry.depositedWeis = 0;
        _entry.vehicle.transfer(refund);
        return(refund, finalFee);
    }
}