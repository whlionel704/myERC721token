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

    //Variable to track total token balance in the contract
    uint256 public tokenBalance;

    event ICOStarted(uint256 startTime);
    event ICOEnded(uint256 endTime);
    event TokensPurchased(address indexed buyer, uint256 amount);

    constructor(
        address initialOwner, 
        string memory name,
        string memory symbol,
        uint256 _initalSupply,
        uint256 _targetAmount,
        address _fundsWallet
    ) ERC20(name, symbol) Ownable(initialOwner) {
        _mint(address(this), _initalSupply);
        tokenBalance = _initalSupply;
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

    function setTargetAmount(uint256 _targetAmount) public onlyOwner {
        require(_targetAmount > 0, "target amount should be greater than 0");
        targetAmount = _targetAmount;
    }

    // Buy tokens during the ICO
    function buyTokens(uint256 tokensToBuy) external payable {
        require(icoActive, "ICO period has ended");
        require(tokensToBuy <= tokenBalance, "Not enough tokens available");
        uint256 ethersRequired = (tokensToBuy * 0.1 ether) / 100;
        require(msg.value >= ethersRequired, "Not enough ether sent");

        //token balance should be updated before transfer to avoid re-entrancy
        tokenBalance -= tokensToBuy;
        _transfer(address(this), msg.sender, tokensToBuy);  // Transfer tokens to buyer
        emit TokensPurchased(msg.sender, tokensToBuy);
    }

    function mint(uint256 numTokens) public {
        _mint(msg.sender, numTokens);
    }


    function withdrawEthers() external payable {
        require(msg.sender == address(fundsWallet), "Only fundsWallet account can withdraw");
        require(address(this).balance > targetAmount, "No ether to withdraw");

        // Transfer all ethers to fundsWallet
        (bool success, ) = fundsWallet.call{value: address(this).balance}("");
        require(success, "Ether transfer failed");
    }
}