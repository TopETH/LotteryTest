// SPDX-License-Identifier: GPL-3.0

pragma solidity >=0.8.0;

contract Ownable {
    address private owner;
    event OwnerSet(address indexed oldOwner, address indexed newOwner);
    modifier isOwner() {
        require(msg.sender == owner, "Caller is not owner");
        _;
    }
    constructor() {
        owner = msg.sender; // 'msg.sender' is sender of current call, contract deployer for a constructor
        emit OwnerSet(address(0), owner);
    }
    function changeOwner(address newOwner) public isOwner {
        emit OwnerSet(owner, newOwner);
        owner = newOwner;
    }
    function getOwner() external view returns (address) {
        return owner;
    }
}

contract TestLottery is Ownable {
    uint private candidates;
    uint private winners;
    uint private lastDraw = 0;
    
    event NewLottery(uint candidates, uint winners);
    event NewDraw(uint draw, uint winner);

    constructor () {
        newLottery(1000, 5);
    }
    
    function newLottery(uint newCandidates, uint newWinners) public isOwner {
        require(newCandidates > 0, "Candidates must be greater than zero");
        require(newWinners > 0, "Winners must be greater than zero");
        require(newCandidates > newWinners, "Candidates must be greater than Winners");
        
        candidates = newCandidates;
        winners = newWinners;
        
        emit NewLottery(candidates, winners);
    }
    
    function getLottery() public view returns (uint, uint)  {
        return (candidates, winners);
    }
    
    function newRandom(uint prevRandom) private view returns (uint) {
        uint randomHash = uint(keccak256(abi.encodePacked(prevRandom, block.timestamp)));
        return (randomHash % candidates) + 1;
    }
    
    function newDraw() public isOwner {
        lastDraw = lastDraw + 1;
        
        uint newIndex = 0;
        for(uint i = 0; i < winners; i ++) {
            newIndex = newRandom(newIndex);
            emit NewDraw(lastDraw, newIndex);
        }
    }
    
    function getDraw() public view returns (uint) {
        require(lastDraw > 0, "No draw has been taken");
        return lastDraw;
    }
}