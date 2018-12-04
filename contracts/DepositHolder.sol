pragma solidity ^0.4.24;


import "./interfaces/DepositHolderI.sol";
import "./Owned.sol";


contract DepositHolder is DepositHolderI, Owned {

    uint internal deposit;

    event LogDepositSet(address indexed sender, uint amount);

    constructor(uint _deposit) public {
        require(_deposit > 0, "The initial deposit cannot be 0.");
        deposit = _deposit;
    }

    function setDeposit(uint _depositWeis) public fromOwner returns (bool success) {
        require(_depositWeis > 0, "Deposited weis must be bigger than 0");
        require(_depositWeis != deposit, "New deposit is no different than current one.");
        deposit = _depositWeis;
        emit LogDepositSet(msg.sender, _depositWeis);
        return true;
    }

    function getDeposit() public view returns(uint depositedWeis) {
        return deposit;
    }
}