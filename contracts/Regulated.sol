pragma solidity ^0.4.24;

import "./interfaces/RegulatedI.sol";

contract Regulated is RegulatedI {
    
    address internal regulator;
    
    constructor(address _regulator) public {
        require(_regulator != 0);
        regulator = _regulator;
    }
    
    event LogRegulatorSet(address indexed previousRegulator, address indexed newRegulator);
    function setRegulator(address newRegulator) public onlyRegulator returns(bool success) {
        require(newRegulator > 0);
        require(newRegulator != regulator);
        emit LogRegulatorSet(regulator, newRegulator);
        regulator = newRegulator;
        return true;
    }

    function getRegulator() public view returns(RegulatorI _regulator) {
        return RegulatorI(regulator);
    }
    
    modifier onlyRegulator() {
        require(msg.sender == regulator, "Sender must be a regulator of contract");
        _;
    }
}