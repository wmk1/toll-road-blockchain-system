pragma solidity ^0.4.24;

import "./interfaces/RegulatedI.sol";

contract Regulated is RegulatedI {

    address regulator;

    event LogRegulatorSet(address indexed previousRegulator, address indexed newRegulator);

    modifier onlyIfNotZeroAddress {
        require(regulator != address(0), "New regulator address cannot be 0!");
        _;
    }

    modifier onlyIfNewRegulator (address _newRegulator) {
        require(_newRegulator != regulator, "New regulator cannot be the same");
        _;
    }

    constructor(address _regulator) {
        regulator = _regulator;
    }

    function setRegulator(address _newRegulator) onlyIfNotZeroAddress public returns(bool success) {
        require(_newRegulator != regulator, "New regulator cannot be the same");
        regulator = _newRegulator;
        emit LogRegulatorSet(msg.sender, _newRegulator);
        return true;
    }

    function getRegulator() view public returns(RegulatorI) {
        return regulator;
    }
}