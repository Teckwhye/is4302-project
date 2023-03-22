pragma solidity ^0.5.0;

import "./Account.sol";
import "./Seller.sol"; 
import "./Event.sol";
import "./Ticket.sol";
import "./EventToken.sol";

contract Platform {
    Account accountContract;
    Seller sellerContract;
    EventToken eventTokenContract;
    Event eventContract;

    event TransferToBuyerSuccessful(address to, uint256 amount);

    // Platform can only exist if other contracts are created first
    constructor(Account accountAddr, EventToken eventTokenAddr, Event eventAddr) public {
        accountContract = accountAddr;
        eventTokenContract = eventTokenAddr;
        eventContract = eventAddr;
    }

    /* Ensure caller is a buyer */
    modifier isBuyer() {
        require(accountContract.viewAccountState(msg.sender) == accountContract.getUnverifiedStatus());
        _;
    }

    /* Viewing the number of tickets left for an event */
    function viewTicketsLeft(uint256 eventId) public view returns (uint256) {
        return eventContract.getEventTicketsLeft(eventId);
    }

    /* Buyers buying tickets for an event */
    function buyTickets(uint256 eventId, uint8 quantity, uint256 price) public payable isBuyer() {
        require(quantity <= 4, "You have passed the maximum bulk purchase limit");

        /* Require eventid is a listed event */

        uint256 totalPrice = price * quantity;
        require(msg.value >= totalPrice, "Buyer has insufficient ETH to buy tickets");

        /* Map ticket id to an account */
        msg.sender.transfer(msg.value - totalPrice); // transfer remaining back to buyer
        emit TransferToBuyerSuccessful(msg.sender, msg.value - totalPrice);
    }



}