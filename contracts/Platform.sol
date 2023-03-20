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

    mapping(uint256 => mapping(uint256 => address[])) public eventBiddings; // eventId => (tokenBid => addressArray)
    mapping(uint256 => uint256) public eventTopBid; // eventId => topBid (need to constantly update eventTopBid)
    
    // Commence bidding for event
    function commenceBidding(uint256 eventId) public {
        //require(eventBiddings[eventId] == 0);
    }

    // Bid
    function addBid(uint256 eventId, uint256 tokenBid) public {
        //require 
        eventBiddings[eventId][tokenBid].push(msg.sender);
    }

    // Close bidding and 
    function closeBidding(uint256 eventId) public {
        // compare top tickets

        uint256 bidAmount = eventTopBid[eventId];
        uint256 ticketsLeft = eventContract.getEventTicketsLeft(eventId);

        while (ticketsLeft != 0) {
            address[] memory bidderList = eventBiddings[eventId][bidAmount];
            for (uint256 i = 0; i < bidderList.length; i++) {
                // transfer ticket to address @ bidderList[i]
                ticketsLeft--;
            }
            bidAmount--;
        }
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