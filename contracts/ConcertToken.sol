pragma solidity ^0.5.0;

import "./ERC20.sol";

contract ConcertToken {
    ERC20 erc20Contract;
    uint256 supplyLimit;
    uint256 currentSupply;
    address owner;

    event GetConcertToken(address to, uint256 amount);
    event RefundConcertToken(address to, uint256 amount);

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
    function getConcertToken() public payable {
        uint256 amt = msg.value / 50000;
        // require(erc20Contract.totalSupply() + amt < supplyLimit, "CT supply is not enough");
        erc20Contract.mint(msg.sender, amt);
        currentSupply = currentSupply + amt;
        emit GetConcertToken(msg.sender, amt);
    }

    // Refund for the amount of tokens given
    function refundConcertToken(uint256 amt) public {
        require(erc20Contract.balanceOf(msg.sender) >= amt, "Your balance is less than the amount of tokens asked for refund.");
        erc20Contract.burn(msg.sender, amt);
        msg.sender.transfer(amt * 50000);
        currentSupply = currentSupply - amt;
        emit RefundConcertToken(msg.sender, amt);
    }

    // For checking of token credits
    function checkConcertToken() public view returns(uint256) {
        return erc20Contract.balanceOf(msg.sender);
    }

    // Check current amount of supply of tokens in the market
    function getCurrentSupply() public view returns (uint256) {
        return currentSupply;
    }

}