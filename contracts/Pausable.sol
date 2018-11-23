pragma solidity ^0.4.24;

import "./interfaces/OwnedI.sol";
import "./interfaces/PausableI.sol";


contract Pausable is OwnedI, PausableI {
    
    bool paused;
    
    event LogPausedSet(address indexed _sender, bool indexed _newPausedState);

    modifier whenNotPaused {
        require(paused, "Must be paused");
        _;
    }

    modifier whenPaused {
        require(!paused, "Must not be paused");
        _;
    }

    constructor (bool newState) public whenNotPaused {
        paused = newState;
    }

    function setPaused(bool _newState) public returns(bool success){
        if (paused == _newState) revert();
        paused = _newState;
        emit LogPausedSet(msg.sender, _newState);
        return true;
    }

    function isPaused() public view returns(bool isIndeed){
        return paused;
    }
}