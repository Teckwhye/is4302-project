pragma solidity ^0.5.0;

contract Account {
    // Struct creation for the account member
    address platformAddr;

    enum status {
        unverified,
        verified
    }

    struct account {
        status state; // whether an account can sell tickets
        address verifier; // who verified this account
        bool certified; // whether account can certify other addresses
    }

    mapping (address => account) accounts;
    // for future extension where multiple certifiers can cross-check
    mapping(uint256 => address) public certifiers;
    uint256 public numCertifiers = 0;

    modifier isCertified() {
        require(accounts[msg.sender].certified, "Account not certified");
        _;
    }

    /* Platform address initialisation that can only be set once */
    function setPlatformAddress(address addr) public {
        require(platformAddr == address(0), "Platform address initialisation can only be set once");
        platformAddr = addr;
    }

    /* Certify an account */
    function certifyAccount(address addr) public {
        accounts[addr].certified = true;
        uint256 newCertifyId = numCertifiers++;
        certifiers[newCertifyId] = addr;
    }

    /* Ensures an account is verified */
    function verifyAccount(address addr, address verifier) public isCertified() {
        accounts[addr].state = status.verified;
        accounts[addr].verifier = verifier;
    }

    /* View account verification state*/
    function viewAccountState(address addr) public view returns (status state) {
        return accounts[addr].state;
    }

    /* View if account have the power to certify other addresses*/
    function viewCertifiedStatus(address addr) public view returns (bool) {
        return accounts[addr].certified;
    }

    /* View the address whom verified the account */
    function viewAccountVerifier(address addr) public view returns (address) {
        return accounts[addr].verifier;
    }
    
    function getUnverifiedStatus() public pure returns (status state) {
        return status.unverified;
    }

    function getVerifiedStatus() public pure returns (status state) {
        return status.verified;
    }

}