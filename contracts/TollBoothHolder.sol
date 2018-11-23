pragma solidity ^0.4.24;

import "./interfaces/OwnedI.sol";
import "./interfaces/TollBoothHolderI.sol";

contract TollBoothHolder is OwnedI, TollBoothHolderI {

    address[] private tollBoothHolders;

    event LogTollBoothAdded(address indexed sender, address indexed tollBooth);
    event LogTollBoothRemoved(address indexed sender, address indexed tollBooth);

    modifier onlyIfNotZeroAddress(address _address) {
        require(_address != 0x0, "An address cannot be 0");
        _;
    }

    constructor() public {
        
    }

    function addTollBooth(address _tollBooth) public onlyIfNotZeroAddress(_tollBooth) returns (bool success) {
        require(!isTollBooth(_tollBooth), "Address is already a toll booth.");
        for (uint i = 0; i < tollBoothHolders.length; i++) {
            isTollBooth(_tollBooth);
        }
        tollBoothHolders.push(_tollBooth);
        emit LogTollBoothAdded(msg.sender, _tollBooth);
        return true;
    }

    function isTollBooth(address tollBooth) view public returns(bool indeed) {
        for (uint i = 0; i < tollBoothHolders.length; i++) {
            return isTollBooth(_tollBooth);
        }
        return false;
    }

    function removeTollBooth(address tollBooth) public onlyIfNotZeroAddress(_tollBooth) returns (bool success) {
        for (uint i = 0; i < tollBoothHolders.length; i++) {
            if (tollBoothHolders) {
                delete tollBoothHolders[tollBooth];
                emit LogTollBoothRemoved(msg.sender, tollBooth);
                return true;
            }
        }
        return false;
    }
}