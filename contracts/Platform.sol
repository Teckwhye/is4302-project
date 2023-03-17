pragma solidity ^0.5.0;

import "./Buyer.sol";
import "./Seller.sol"; 
import "./Event.sol";
import "./Ticket.sol";
import "./EventToken.sol";

contract Platform {
    Buyer buyerContract;
    Seller sellerContract;
    EventToken eventTokenContract;
    Event eventContract;

    // Platform can only exist if other contracts are created first
    constructor(Buyer buyerAddr, Seller sellerAddr, EventToken eventTokenAddr, Event eventAddr) public {
        buyerContract = buyerAddr;
        sellerContract = sellerAddr;
        eventTokenContract = eventTokenAddr;
        eventContract = eventAddr;
    }

    /* Viewing the number of tickets left for an event */
    function viewTicketsLeft(uint256 eventId) public view returns (uint256) {
        return eventContract.getEventTicketsLeft(eventId);
    }

    /* Buyers buying tickets for an event */
    function buyTickets(uint256 eventId, uint8 quantity) public payable {
        // buyerContract.buyTickets(eventId, quantity, concertTokenContract);
    }

}