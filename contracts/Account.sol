pragma solidity ^0.5.0;

contract Account {
    // Struct creation for the account member
    enum status {
        unverified,
        verified
    }

    struct account {
        status state; // whether an account can sell tickets
        bool registered;
    }

    mapping (address => account) accounts;

    modifier validAccount(address addr) {
        require(accounts[addr].registered == true); //Check if registered 
        _;
    }

    modifier invalidAccount(address addr) {
        require(accounts[addr].registered == false); //Check if not registered
        _;
    }

    /* Ensures an account is registered on the platform */
    function createAccount(address addr) public invalidAccount(addr) {
        accounts[addr].state = status.verified;
        accounts[addr].registered = true; // updatees the field to make an account valid
    }  


}