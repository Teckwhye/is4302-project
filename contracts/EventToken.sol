pragma solidity ^0.5.0;

import "./ERC20.sol";

contract EventToken {
    ERC20 erc20Contract;
    uint256 supplyLimit;
    uint256 currentSupply;
    address owner;

    event GetEventToken(address to, uint256 amount);
    event RefundEventToken(address to, uint256 amount);

    constructor() public {
        ERC20 e = new ERC20();
        erc20Contract = e;
        owner = msg.sender;
        currentSupply = 0;
    }

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    // For purchasing of Tokens
    function getEventToken() public payable {
        uint256 amt = msg.value / 50000;
        // require(erc20Contract.totalSupply() + amt < supplyLimit, "CT supply is not enough");
        erc20Contract.mint(msg.sender, amt);
        currentSupply = currentSupply + amt;
        emit GetEventToken(msg.sender, amt);
    }

    // Refund for the amount of tokens given
    function refundEventToken(uint256 amt) public {
        require(erc20Contract.balanceOf(msg.sender) >= amt, "Your balance is less than the amount of tokens asked for refund.");
        erc20Contract.burn(msg.sender, amt);
        msg.sender.transfer(amt * 50000);
        currentSupply = currentSupply - amt;
        emit RefundEventToken(msg.sender, amt);
    }

    // For checking of token credits
    function checkEventToken() public view returns(uint256) {
        return erc20Contract.balanceOf(msg.sender);
    }

    // For checking of token credits of address
    function checkEventTokenOf(address addr) public view returns(uint256) {
        return erc20Contract.balanceOf(addr);
    }

    // Check current amount of supply of tokens in the market
    function getCurrentSupply() public view returns (uint256) {
        return currentSupply;
    }

}