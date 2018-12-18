pragma solidity ^0.4.24;

import "./Owned.sol";
import "./interfaces/TollBoothHolderI.sol";


contract TollBoothHolder is Owned, TollBoothHolderI {

    mapping(address => bool) internal tollBoothHolders;

    event LogTollBoothAdded(address indexed sender, address indexed tollBooth);
    event LogTollBoothRemoved(address indexed sender, address indexed tollBooth);

    modifier onlyIfNotZeroAddress(address _address) {
        require(_address != 0, "An address cannot be 0");
        _;
    }

    constructor() public {
    }

    function addTollBooth(address _tollBooth) public fromOwner returns (bool success) {
        require(_tollBooth != 0x0, "New toll booth address cannot be 0");
        require(!isTollBooth(_tollBooth), "Address is already a toll booth.");
        tollBoothHolders[_tollBooth] = true;
        emit LogTollBoothAdded(msg.sender, _tollBooth);
        return true;
    }

    function isTollBooth(address _tollBooth) public view returns(bool indeed) {
        return tollBoothHolders[_tollBooth];
    }

    function removeTollBooth(address _tollBooth) public fromOwner returns (bool success) {
        require(isTollBooth(_tollBooth), "Given address is not a toll booth");            
        delete tollBoothHolders[_tollBooth];
        emit LogTollBoothRemoved(msg.sender, _tollBooth);
        return true;
    }
}