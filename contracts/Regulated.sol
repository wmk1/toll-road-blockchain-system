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
    }

    constructor(address _regulator) {
        regulator = _regulator;
    }

    /**
     * Sets the new regulator for this contract.
     *     It should roll back if any address other than the current regulator of this contract
     *       calls this function.
     *     It should roll back if the new regulator address is 0.
     *     It should roll back if the new regulator is the same as the current regulator.
     * @param newRegulator The new desired regulator of the contract. It is assumed, that this is the
     *     address of a `RegulatorI` contract. It is not necessary to prove it is a `RegulatorI`.
     * @return Whether the action was successful.
     * Emits LogRegulatorSet with:
     *     The sender of the action.
     *     The new regulator.
     */
    function setRegulator(address _newRegulator) onlyIfNotZeroAddress public returns(bool success) {
        require(_newRegulator != regulator, "New regulator cannot be the same");
        regulator = _newRegulator;
        emit LogRegulatorSet(msg.sender, _newRegulator);
        return true;
    }

    /**
     * @return The current regulator.
     */
    function getRegulator() view public returns(RegulatorI regulator) {
        return regulator;
    }
}