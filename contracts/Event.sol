pragma solidity ^0.5.0;

import "./DateTime.sol";
import "./Ticket.sol";

contract Event {

    Ticket ticketContract;

    constructor(Ticket ticketAddress) public {
        ticketContract = ticketAddress;
    }

    struct eventObj {
        string title;
        string venue;
        uint256 dateAndTime;
        uint256 capacity;
        uint256 ticketsLeft;
        uint256 priceOfTicket;
        address seller;
    }

    uint256 public numEvents = 0;
    mapping(uint256 => eventObj) public events;

    function createEvent(
        string memory title,
        string memory venue,
        uint256 year, uint256 month, uint256 day, uint256 hour, uint256 minute, uint256 second,
        uint256 capacity,
        uint256 ticketsLeft,
        uint256 priceOfTicket,
        address seller
    ) public returns (uint256) {
        // require creation fee in terms of tokens?
        // require(msg.sender == platformOwner/seller?)

        // require input validation for parameters Eg. datetime

        eventObj memory newEvent = eventObj(
            title,
            venue,
            DateTime.timestampFromDateTime(year, month, day, hour, minute, second),
            capacity,
            ticketsLeft,
            priceOfTicket,
            seller
        );

        uint256 newEventId = numEvents++;
        events[newEventId] = newEvent;
        // transfer creation fee?

        // Generate Tickets
        generateEventTickets(newEventId, priceOfTicket, Ticket.category.standard, ticketsLeft);

        return newEventId;
    }

    modifier validEventId(uint256 eventId) {
        require(eventId < numEvents);
        _;
    }

    function generateEventTickets(uint256 eventId, uint256 price, Ticket.category cat, uint256 numOfTickets) public validEventId(eventId) {
        for (uint256 i = 0; i < numOfTickets; i++) {
            ticketContract.add(eventId, price, cat, i);
        }
    } 

    function getEventTitle(uint256 eventId) public view validEventId(eventId) returns (string memory) {
        return events[eventId].title;
    }

    function getEventVenue(uint256 eventId) public view validEventId(eventId) returns (string memory) {
        return events[eventId].venue;
    }

    function getEventDateAndTime(uint256 eventId) public view validEventId(eventId) returns (uint256, uint256, uint256, uint256, uint256, uint256) {
        return DateTime.timestampToDateTime(events[eventId].dateAndTime);
    }

    function getEventCapacity(uint256 eventId) public view validEventId(eventId) returns (uint256) {
        return events[eventId].capacity;
    }

    function getEventTicketsLeft(uint256 eventId) public view validEventId(eventId) returns (uint256) {
        return events[eventId].ticketsLeft;
    }
    
    function getEventSeller(uint256 eventId) public view validEventId(eventId) returns (address) {
        return events[eventId].seller;
    }

    function endEvent(uint256 eventId) public validEventId(eventId) {
        // return of deposit value done at Platform
        // only call this function at Platform
        delete events[eventId];
    }
}

