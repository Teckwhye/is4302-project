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

    /* Ensures an account is allowed to list on the platform */
    function verifyAccount(address addr) public {
        accounts[addr].state = status.verified;
    }

    /* View account verification state*/
    function viewAccountState(address addr) public view returns (status state) {
        return accounts[addr].state;
    }
    
}