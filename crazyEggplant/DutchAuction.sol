// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "./CrazyEggplant.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract DutchAuction is CrazyEggplant, Ownable{
    
    // OWNER is the only one can call some function that needs power.
    address private OWNER = msg.sender; 

    uint256 private constant AUCTION_START_PRICE = 1 ether; 
    uint256 private constant AUCTION_END_PRICE = 0.1 ether; 
    uint256 private constant AUCTION_TIME = 10 minutes; 
    uint256 private constant AUCTION_DROP_INTERVAL = 1 minutes;
    uint256 private constant AUCTION_DROP_PER_STEP = 
        (AUCTION_START_PRICE - AUCTION_END_PRICE) / (AUCTION_TIME / AUCTION_DROP_INTERVAL);
    uint256 private auctionStartTime; // auction start timestamp
    
    uint256 private totalTokens;
    
    constructor() Ownable(OWNER) {
        auctionStartTime = block.timestamp;
    }

    receive() external payable {}

    function setStartTime(uint256 _startTime) external onlyOwner  {
        auctionStartTime = _startTime;
    }

    function getAuctionPrice() external view returns (uint256){
        if (block.timestamp < auctionStartTime){
            return AUCTION_START_PRICE;
        } else if (block.timestamp >= auctionStartTime + AUCTION_TIME) {
            return AUCTION_END_PRICE;
        } else {
            uint256 steps = (block.timestamp - auctionStartTime) /
            AUCTION_DROP_INTERVAL;
            return AUCTION_START_PRICE - (steps * AUCTION_DROP_PER_STEP);
        }
    }

    function auctionMint(uint256 quantity) external payable {
        uint256 _saleStartTime = uint256(auctionStartTime); // local variable, less gas

        require( _saleStartTime != 0 &&
            block.timestamp >= _saleStartTime, "auction do not start!");

        require(quantity + totalTokens <= MAXNUMBERS, "out of max token number!");

        uint256 totalCost = quantity * this.getAuctionPrice();
        require(msg.value >= totalCost, "not enough ETH!");

        uint256 limit = totalTokens + quantity;
        for (uint256 i = totalTokens; i < limit; i++) {
            this.mint(msg.sender, i);
            totalTokens += 1;
        } 

        // 多余的ETH退款
        if (msg.value > totalCost) {
            (bool res2,) = msg.sender.call{value: msg.value - totalCost}("");
            require(res2, "get ETH failed!");
        }  
    }
    
    function withDraw() external onlyOwner payable {
        (bool res,) = OWNER.call{value: address(this).balance}("");
        require(res, "withDraw Failed!");
    }
  
}