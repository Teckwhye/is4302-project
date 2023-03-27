pragma solidity ^0.5.0;

import "./ERC20.sol";

contract EventToken {
    ERC20 erc20Contract;
    uint256 supplyLimit;
    uint256 currentSupply;
    uint256 basePriceOfToken;
    address owner;

    event MintToken(address to, uint256 amount);
    event BurnToken(address to, uint256 amount);

    constructor() public {
        ERC20 e = new ERC20();
        erc20Contract = e;
        owner = msg.sender;
        currentSupply = 0;
        basePriceOfToken = 50000;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "You do not have permission to do this");
        _;
    }

    /**
     * Mint event tokens for address based on amount of wei
     *
     * param amount of token
     * param address to get token
     * 
     */
    function mintToken(uint256 amtOfWei, address _to) public onlyOwner {
        uint256 amtOfToken = amtOfWei / basePriceOfToken;
        erc20Contract.mint(_to, amtOfToken);
        currentSupply = currentSupply + amtOfToken;
        emit MintToken(_to, amtOfToken);
    }

    /**
     * Burn event tokens from address
     *
     * param amount of token
     * param address to get token
     * 
     */
     function burnToken(uint256 amtOfToken, address _from) public onlyOwner {
        erc20Contract.burn(_from, amtOfToken);
        currentSupply = currentSupply - amtOfToken;
        emit BurnToken(_from, amtOfToken);
    }

    /**
     * Transfer token from one address to another
     *
     * param amount of tokens to bid
     * 
     */
     function transferFrom(address _from, address _to, uint256 _value) public onlyOwner {
        erc20Contract.transferFrom(_from, _to, _value);
    }

    // For checking of token credits of another address (only for owner)
    // function checkEventTokenOf(address _from) public view onlyOwner returns(uint256) {
    //     return erc20Contract.balanceOf(_from);
    // }

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