pragma solidity ^0.4.13;

contract DepositHolderI {

    /**
     * Event emitted when the deposit value has been set.
     * @param sender The account that ran the action.
     * @param depositWeis The value of the deposit measured in weis.
     */
    event LogDepositSet(address indexed sender, uint depositWeis);

    /**
     * Called by the owner of the DepositHolder.
     *     It should not accept 0 as a value.
     *     It should not accept the value already set.
     * @param depositWeis The value of the deposit being set, measure in weis.
     * @return Whether the action was successful.
     * Emits LogDepositSet.
     */
    function setDeposit(uint depositWeis)
        public
        returns(bool success);

    /**
     * @return The base price, then to be multiplied by the multiplier, a given vehicle
     * needs to deposit to enter the road system.
     */
    function getDeposit()
        constant
        public
        returns(uint weis);

    /*
     * You need to create:
     *
     * - a contract named `DepositHolder` that:
     *     - is `OwnedI`, and `DepositHolderI`.
     *     - has a constructor that takes:
     *         - one `uint` parameter, the initial deposit wei value, which cannot be 0.
     */        
}