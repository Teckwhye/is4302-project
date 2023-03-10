pragma solidity ^0.5.0;

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
        uint256 dateAndTime,
        uint256 capacity,
        uint256 ticketsLeft,
        address seller
    ) public returns (uint256) {
        // require creation fee in terms of tokens?
        // require(msg.sender == platformOwner/seller?)

        eventObj memory newEvent = eventObj(
            title,
            venue,
            dateAndTime,
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
}

