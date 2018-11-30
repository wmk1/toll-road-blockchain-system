pragma solidity ^0.4.24;

import "./Owned.sol";
import "./interfaces/TollBoothHolderI.sol";

contract TollBoothHolder is Owned, TollBoothHolderI {

    address[] private tollBoothHolders;

    event LogTollBoothAdded(address indexed sender, address indexed tollBooth);
    event LogTollBoothRemoved(address indexed sender, address indexed tollBooth);

    modifier onlyIfNotZeroAddress(address _address) {
        require(_address != 0x0, "An address cannot be 0");
        _;
    }

    constructor() public {
        
    }

    function addTollBooth(address tollBooth) public onlyIfNotZeroAddress(tollBooth) returns (bool success) {
        require(!isTollBooth(tollBooth), "Address is already a toll booth.");
        for (uint i = 0; i < tollBoothHolders.length; i++) {
            isTollBooth(tollBooth);
            return false;
        }
        tollBoothHolders.push(tollBooth);
        emit LogTollBoothAdded(msg.sender, tollBooth);
        return true;
    }

    function isTollBooth(address _tollBooth) view public returns(bool indeed) {
        for (uint i = 0; i < tollBoothHolders.length; i++) {
            if (isTollBooth(_tollBooth)) {
                return true;
            }
        }
        return false;
    }

    function removeTollBooth(address _tollBooth) public onlyIfNotZeroAddress(_tollBooth) returns (bool success) {
        for (uint i = 0; i < tollBoothHolders.length; i++) {
            if (isTollBooth(tollBoothHolders[i])) {
                delete tollBoothHolders[i];
                emit LogTollBoothRemoved(msg.sender, _tollBooth);
                return true;
            }
        }
        return false;
    }
}