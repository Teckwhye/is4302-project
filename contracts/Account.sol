pragma solidity ^0.5.0;

contract Account {
    address owner;

    // Struct creation for the account member
    enum status {
        unverified,
        verified
    }

    constructor() public {
        owner = msg.sender;
    }

    struct account {
        status state; // whether an account can sell tickets
        address verifier; // who verified this account
        bool certified; // whether account can certify other addresses
    }

    mapping (address => account) accounts;

    modifier onlyOwner() {
        require(msg.sender == owner, "You do not have permission to do this");
        _;
    }

    modifier isCertified() {
        require(accounts[msg.sender].certified, "Account not certified");
        _;
    }

    /**
     * certify an account to be given the permission to verify other accounts
     *
     * param addr       address of the account to be certified
     */
    function certifyAccount(address addr) public onlyOwner() {
        require(accounts[addr].certified == false, "Account is already certified");
        accounts[addr].certified = true;
    }

    /**
     * uncertify an account to revoke permission to verify other accounts
     * param addr       address of the account to be uncertified
     */
    function uncertifyAccount(address addr) public onlyOwner() {
        require(accounts[addr].certified == true, "Account is not certified");
        accounts[addr].certified = false;
    }

    /**
     * Verify an account to be able to list events
     *
     * param addr       address of the account to be verified
     */
    function verifyAccount(address addr) public isCertified() {
        accounts[addr].state = status.verified;
        accounts[addr].verifier = msg.sender;
    }

    /**
     * Unverify an account to restrict listing events
     *
     * param addr       address of the account to be unverified
     */
    function unverifyAccount(address addr) public isCertified() {
        accounts[addr].state = status.unverified;
        accounts[addr].verifier = msg.sender;
    }

    /**
     * View the state of an account
     *
     * param addr       address of the account
     */
    function viewAccountState(address addr) public view returns (status state) {
        return accounts[addr].state;
    }

    /**
     * View the certified status of an account
     *
     * param addr       address of the account
     * returns bool     true if certified, else false
     */
    function viewCertifiedStatus(address addr) public view returns (bool) {
        return accounts[addr].certified;
    }

    /**
     * View the verifier of an account
     *
     * param addr       address of the account
     * returns address  address of the verifier
     */
    function viewAccountVerifier(address addr) public view returns (address) {
        return accounts[addr].verifier;
    }
    
    /**
     * Obtain enum value of an unverified state
     *
     * returns status state of the unverified status
     */
    function getUnverifiedStatus() public pure returns (status state) {
        return status.unverified;
    }

    /**
     * Obtain enum value of a verified state
     *
     * returns status state of the verified status
     */
    function getVerifiedStatus() public pure returns (status state) {
        return status.verified;
    }

     /**
     * Return ether balance of specific Account/ Contract Address
     *
     * param addr       address of the account/ contract
     * returns uint256  ether balance of the account/ contract
     */
    function getBalance(address addr) public view returns (uint256) {
        return addr.balance;
    }

}