pragma solidity ^0.4.24;

import "./interfaces/RegulatedI.sol";


contract Regulated is RegulatedI {
    
    address internal regulator;

    modifier onlyRegulator() {
        require(msg.sender == regulator, "Sender must be a regulator of contract");
        _;
    }

    event LogRegulatorSet(address indexed previousRegulator, address indexed newRegulator);

    constructor(address _regulator) public {
        require(_regulator != 0, "New address cannot be 0.");
        regulator = _regulator;
    }
    
    function setRegulator(address _newRegulator) public onlyRegulator returns(bool success) {
        require(_newRegulator > 0, "New address cannot be 0.");
        require(_newRegulator != regulator, "New regulator cannot be the same regulator.");
        emit LogRegulatorSet(regulator, _newRegulator);
        regulator = _newRegulator;
        return true;
    }

    function getRegulator() public view returns(RegulatorI _regulator) {
        return RegulatorI(regulator);
    }
}