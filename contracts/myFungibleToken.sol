// SPDX-License-Identifier: MIT
// Compatible with OpenZeppelin Contracts ^5.0.0
pragma solidity ^0.8.24;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract MyFungibleToken is ERC20, Ownable {
    uint256 public tokenPrice;  
    uint256 public icoStartTime;
    uint256 public maxTokensForSale;
    uint256 public targetAmount;
    bool public icoActive;

    // Address where funds are collected
    address public fundsWallet;

    event ICOStarted(uint256 startTime);
    event ICOEnded(uint256 endTime);
    event TokensPurchased(address indexed buyer, uint256 amount);

    constructor(
        address initialOwner, 
        string memory name,
        string memory symbol,
        uint256 _initalSupply,
        uint256 _tokenPrice,
        uint256 _maxTokensForSale,
        uint256 _targetAmount,
        address _fundsWallet
    ) ERC20(name, symbol) Ownable(initialOwner) {
        _mint(address(this), _initalSupply);
        tokenPrice = _tokenPrice;
        maxTokensForSale = _maxTokensForSale;
        targetAmount = _targetAmount;
        fundsWallet = _fundsWallet;
    }
    
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

    function setTargetAmount(uint _targetAmount) public onlyOwner {
        targetAmount = _targetAmount;
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
        _mint(msg.sender, numTokens);
    }

    function withdraw(uint256 tokensToWithdraw) external payable onlyOwner{
        require(tokensToWithdraw <= balanceOf(address(this)), "Not enough tokens available");
        require(targetAmount <= tokensToWithdraw);
        _transfer(address(this), fundsWallet, tokensToWithdraw);
    }
}