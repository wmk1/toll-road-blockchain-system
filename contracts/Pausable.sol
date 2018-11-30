pragma solidity ^0.4.24;

import "./Owned.sol";
import "./interfaces/PausableI.sol";


contract Pausable is Owned, PausableI {
    
    bool paused;
    
    event LogPausedSet(address indexed _sender, bool indexed _newPausedState);

    modifier whenNotPaused {
        require(paused, "Must be paused.");
        _;
    }

    modifier whenPaused {
        require(!paused, "Must not be paused.");
        _;
    }

    constructor (bool newState) public {
        paused = newState;
    }

    function setPaused(bool _state) public returns(bool success){
        require(_state != paused, "New state must be different than current one.");
        require(msg.sender != owner, "Caller is not the current owner.");
        paused = _state;
        emit LogPausedSet(msg.sender, _state);
        return true;
    }

    function isPaused() public view returns(bool isIndeed){
        return paused;
    }
}