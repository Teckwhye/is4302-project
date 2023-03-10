pragma solidity ^0.5.0;

import "./DateTime.sol";

contract Event {

    struct eventObj {
        string title;
        string venue;
        uint256 dateAndTime;
        uint256 capacity;
        uint256 ticketsLeft;
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
            seller
        );

        uint256 newEventId = numEvents++;
        events[newEventId] = newEvent;
        // transfer creation fee?

        // Generate Tickets

        return newEventId;
    }

    modifier validEventId(uint256 eventId) {
        require(eventId < numEvents);
        _;
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
}

