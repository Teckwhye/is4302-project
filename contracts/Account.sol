pragma solidity ^0.5.0;

contract Account {
    // Struct creation for the account member
    enum status {
        unverified,
        verified
    }

    struct account {
        status state; // whether an account can sell tickets
    }

    mapping (address => account) accounts;

    /* Ensures an account is registered on the platform */
    function verifyAccount(address addr) public {
        accounts[addr].state = status.verified;
    }

    /* View state of an account */
    function viewAccountState(address addr) public view returns (status state) {
        return accounts[addr].state;
    }
    
}