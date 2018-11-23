pragma solidity ^0.4.24;

import "./interfaces/OwnedI.sol";
import "./interfaces/TollBoothHolderI.sol";
import "./interfaces/RoutePriceHolderI.sol";

contract RoutePriceHolder is OwnedI, TollBoothHolderI, RoutePriceHolderI {

    address entryBooth;
    address exitBooth;
    

    event LogRoutePriceSet(address indexed sender, address indexed entryBooth, address indexed exitBooth, uint priceWeis);

    constructor() public {
        
    }

    function setRoutePrice(address entryBooth, address exitBooth, uint priceWeis) public returns(bool success) {
        emit LogRoutePriceSet(msg.sender, entryBooth, exitBooth, priceWeis);
        return true;
    }

    function getRoutePrice(address entryBooth, address exitBooth) view public returns(uint priceWeis) {

    }
}
