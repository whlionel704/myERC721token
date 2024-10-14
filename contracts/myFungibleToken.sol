// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/token/ERC20/extensions/ERC20Permit.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyFungibleToken is ERC20, Ownable {
    uint256 public tokenPrice;  
    uint256 public icoStartTime;
    uint256 public maxTokensForSale;

    bool public icoActive;

    event ICOStarted(uint256 startTime);
    event ICOEnded(uint256 endTime);
    event TokensPurchased(address indexed buyer, uint256 amount);

    constructor(address initialOwner, string memory name, string memory symbol, uint8 decimals) 
        ERC20(name, symbol) Ownable(initialOwner) {}
    
    function startICO() public onlyOwner {
        require(!icoActive, "ICO already active");
        icoStartTime = block.timestamp;
        icoActive = true;
        emit ICOStarted(icoStartTime);
    }

    function endICO() public onlyOwner {
        require(icoActive, "ICO is not active");
        icoActive = false;
        emit ICOEnded(block.timestamp);
    }

    // Set token price (only by owner)
    function setTokenPrice(uint256 _newPrice) public onlyOwner {
        require(_newPrice > 0, "Invalid token price");
        tokenPrice = _newPrice;
    }

        // Buy tokens during the ICO
    function buyTokens() external payable {
        require(icoActive, "ICO period has ended");
        require(msg.value > 0, "Send ETH to buy tokens");
        
        uint256 tokensToBuy = msg.value / tokenPrice;  // Calculate number of tokens
        require(tokensToBuy <= balanceOf(address(this)), "Not enough tokens available");

        _transfer(address(this), msg.sender, tokensToBuy);  // Transfer tokens to buyer
        emit TokensPurchased(msg.sender, tokensToBuy);
    }

    function mint(uint256 numTokens) public {
        _mint(msg.sender, numTokens*10**18);
    }
}