pragma solidity ^0.5.0;

contract Ticket {

    address platformAddress;

    /**
     * enum containing 'seating' categories
     * floor:       general standing zone(s)
     * standard:    standard seating zone(s)
     * vip:         premium seating zone(s)
     */
    enum category {floor, standard, vip}

    /**
     * param owner     address of the owner of the ticket
     * param prevOwner address of the previous owner of the ticket
     * param eventId   id of the event the ticket belongs to
     * param price     price of ticket in tokens
     * param cat       category of ticket 
     * param seatId    assigned seat/zone 
     */
    struct ticket {
        address owner;
        address prevOwner;
        uint256 eventId; // event is a keyword
        uint256 price;
        category cat;
        uint256 seatId;
    }

    uint256 public numTickets = 0;  // Total number of tickets
    mapping(uint256 => ticket) public tickets;  // Stores ticket

    // modifier to ensure a function is callable only by its owner    
    modifier ownerOnly(uint256 ticketId) {
        require(tickets[ticketId].owner == msg.sender, "Not owner of ticket");
        _;
    }

    // modifier to ensure ticketId is valid
    modifier validTicketId(uint256 ticketId) {
        require(ticketId < numTickets, "Invalid ticketId");
        _;
    }

    /**
     * creates a ticket and adds it to the ticket list
     *
     * param eventId   id of the event the ticket belongs to
     * param price     Price of ticket in tokens
     * param cat       category of ticket 
     * param seatid    assigned seat/zone
     * return uint256  id of ticket that was created
     */
    function add(address owner, uint256 eventId, uint256 price, category cat, uint256 seatid) public returns (uint256) {
        require(price > 0, "Ticket price cannot be less then 0");

        ticket memory newTicket = ticket(owner,
                                         address(0),
                                         eventId,
                                         price,
                                         cat,
                                         seatid);

        uint256 newTicketId = numTickets++;
        tickets[newTicketId] = newTicket;

        return newTicketId;
    }

    /**
     * sets the address of the platform contract
     *
     * param address address of platform contract
     */
    function setPlatformAddress(address _platform) external {
        require(platformAddress == address(0), "Changing platform address is not allowed");
        platformAddress = _platform;
    }

    /**
     * transfers ticket to the specified address
     *
     * param ticketID ID of ticket to transfer
     * param transferTo address to transfer ticket to
     */
    function transferTicket(uint256 ticketId, address transferTo) public validTicketId(ticketId) ownerOnly(ticketId) {
        require(msg.sender == platformAddress || transferTo == platformAddress, "User to user transfers are diasllowed");
        tickets[ticketId].prevOwner = tickets[ticketId].owner;
        tickets[ticketId].owner = transferTo;
    }

    function getTicketOwner(uint256 ticketId) public view validTicketId(ticketId) returns (address) {
        return tickets[ticketId].owner;
    }

    function getTicketPrevOwner(uint256 ticketId) public view validTicketId(ticketId) returns (address) {
        return tickets[ticketId].prevOwner;
    }

    /**
     * gets the eventId of the event that the ticket is for
     *
     * param ticketID ID of ticket to query
     * return eventId of ticket
     */
    function getTicketEvent(uint256 ticketId) public view validTicketId(ticketId) returns (uint256) {
        return tickets[ticketId].eventId;
    }

    /**
     * gets the price of the ticket
     *
     * param ticketID ID of ticket to query
     * return uint256 price of ticket
     */
    function getTicketPrice(uint256 ticketId) public view validTicketId(ticketId) returns (uint256) {
        return tickets[ticketId].price;
    }

    /**
     * gets the category of the ticket
     *
     * param ticketID ID of ticket to query
     * return category category of the ticket
     */
    function getTicketCat(uint256 ticketId) public view validTicketId(ticketId) returns (category) {
        return tickets[ticketId].cat;
    }

    /**
     * gets the ticket seat
     *
     * param ticketID ID of ticket to query
     * return uint256 seatid of ticket
     */
    function getTicketSeat(uint256 ticketId) public view validTicketId(ticketId) returns (uint256) {
        return tickets[ticketId].seatId;
    }
    
}
