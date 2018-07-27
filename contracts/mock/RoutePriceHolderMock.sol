pragma solidity ^0.4.24;

import "../Owned.sol";
import "../TollBoothHolder.sol";
import "../RoutePriceHolder.sol";

contract RoutePriceHolderMock is TollBoothHolder, RoutePriceHolder {

    constructor() public {
    }
}