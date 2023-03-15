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

    modifier validAccount() {
        require(accounts[msg.sender].registered == true); //Check if registered 
        _;
    }

    modifier invalidAccount() {
        require(accounts[msg.sender].registered == false); //Check if not registered
        _;
    }

    /* Ensures an account is registered on the platform */
    function createAccount() public invalidAccount() {
        accounts[msg.sender].state = status.verified;
        accounts[msg.sender].registered = true; // updatees the field to make an account valid
    }


}