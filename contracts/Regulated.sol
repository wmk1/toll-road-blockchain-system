pragma solidity ^0.4.24;

import "./interfaces/RegulatedI.sol";


contract Regulated is RegulatedI {
    
    address internal regulator;

    event LogRegulatorSet(address indexed previousRegulator, address indexed newRegulator);

    constructor(address _regulator) public {
        require(_regulator != 0x0, "New address cannot be 0.");
        regulator = _regulator;
    }
    
    function setRegulator(address _newRegulator) public returns(bool) {
        require(_newRegulator != 0x0, "New address cannot be 0.");
        require(_newRegulator != regulator, "New regulator cannot be the same regulator.");
        require(msg.sender == regulator, "Sender must be a regulator of contract");
        emit LogRegulatorSet(regulator, _newRegulator);
        regulator = _newRegulator;
        return true;
    }

    function getRegulator() public view returns(RegulatorI) {
        return RegulatorI(regulator);
    }
}