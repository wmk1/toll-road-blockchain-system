pragma solidity ^0.4.24;


import "./interfaces/DepositHolderI.sol";
import "./interfaces/OwnedI.sol";


contract DepositHolder is DepositHolderI, OwnedI {

    uint public deposit;

    event LogDepositSet(address indexed sender, uint amount);

    constructor(uint _deposit) public {
        require(_deposit > 0, "The initial deposit cannot be 0.");
        deposit = _deposit;
    }

    function setDeposit(uint _depositWeis) public returns (bool success) {
        deposit = _depositWeis;
        emit LogDepositSet(msg.sender, _depositWeis);
        return true;
    }
}