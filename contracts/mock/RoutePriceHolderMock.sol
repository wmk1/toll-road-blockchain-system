pragma solidity ^0.4.24;

import { Owned } from "../Owned.sol";
import { TollBoothHolder } from "../TollBoothHolder.sol";
import { RoutePriceHolder } from "../RoutePriceHolder.sol";

contract RoutePriceHolderMock is TollBoothHolder, RoutePriceHolder {

    constructor() public {
    }
}