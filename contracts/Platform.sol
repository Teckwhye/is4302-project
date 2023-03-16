pragma solidity ^0.5.0;

import "./Buyer.sol";
import "./Seller.sol"; 
import "./Event.sol";
import "./Ticket.sol";
import "./ConcertToken.sol";

contract Platform {
    Buyer buyerContract;
    Seller sellerContract;
    ConcertToken concertTokenContract;
    Event eventContract;

    // Platform can only exist if other contracts are created first
    constructor(Buyer buyerAddr, Seller sellerAddr, ConcerToken concertTokenAddr, Event eventAddr) public {
        buyerContract = buyerAddr;
        sellerContract = sellerAddr;
        concertTokenContract = concertTokenAddr;
        eventContract = eventAddr;
    }

    /* Viewing the number of tickets left for an event */
    function viewTicketsLeft(eventId) public view returns (uint256) {
        return eventContract.getEventTicketsLeft(eventId);
    }

    /* Buyers buying tickets for an event */
    function buyTickets(eventId, quantity) public payable {
        // buyerContract.buyTickets(eventId, quantity, concertTokenContract);
    }

}