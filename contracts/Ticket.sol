pragma solidity ^0.5.0;

contract Ticket {

    /**
     * enum containing 'seating' categories
     * floor:       general standing zone(s)
     * standard:    standard seating zone(s)
     * vip:         premium seating zone(s)
     */
    enum category {floor, standard, vip}

    /**
     * @param owner     address of the owner of the ticket
     * @param evnt      address of the event the ticket belongs to
     * @param price     Price of ticket in tokens
     * @param cat       category of ticket 
     * @param seatid    assigned seat/zone 
     */
    struct ticket {
        address owner;
        address evnt; // event is a keyword
        uint256 price;
        category cat;
        uint256 seatid;
    }

    uint256 public numTickets = 0;  // Total number of tickets
    mapping(uint256 => ticket) public tickets;  // Stores ticket

    // modifier to ensure a function is callable only by its owner    
    modifier ownerOnly(uint256 ticketId) {
        require(tickets[ticketId].owner == msg.sender);
        _;
    }

    // modifier to ensure ticketId is valid
    modifier validTicketId(uint256 ticketId) {
        require(ticketId < numTickets);
        _;
    }

    /**
     * creates a ticket and adds it to the ticket list
     *
     * @param evnt      address of the event the ticket belongs to
     * @param price     Price of ticket in tokens
     * @param cat       category of ticket 
     * @param seatid    assigned seat/zone
     * @return uint256  id of ticket that was created
     */
    function add(address evnt, uint256 price, uint256 cat, uint256 seatid) public returns (uint256) {
        require(evnt != address(0), "Event does not exist"); // TODO: Check event exists
        require(price > 0, "Ticket price cannot be less then 0");
        // TODO: require user has enough tokens to purchase ticket (if ticket handles purchase)

        ticket memory newTicket = ticket(msg.sender,
                                         evnt,
                                         price,
                                         cat,
                                         seatid);

        uint256 newTicketId = numTickets++;
        tickets[newTicketId] = newTicket;

        return newTicketId;
    }

    /**
     * gets the address of the event that the ticket is for
     *
     * @param ticketID ID of ticket to query
     * @return address address of ticket event
     */
    function getTicketEvent(uint256 ticketId) public view validTicketId(ticketId) returns (address) {
        return tickets[ticketId].evnt;
    }

    /**
     * gets the price of the ticket
     *
     * @param ticketID ID of ticket to query
     * @return uint256 price of ticket
     */
    function getTicketPrice(uint256 ticketId) public view validTicketId(ticketId) returns (uint256) {
        return tickets[ticketId].price;
    }

    /**
     * gets the category of the ticket
     *
     * @param ticketID ID of ticket to query
     * @return category category of the ticket
     */
    function getTicketPrice(uint256 ticketId) public view validTicketId(ticketId) returns (category) {
        return tickets[ticketId].cat;
    }

    /**
     * gets the seatid of the ticket
     *
     * @param ticketID ID of ticket to query
     * @return uint256 seatid of ticket
     */
    function getTicketPrice(uint256 ticketId) public view validTicketId(ticketId) returns (uint256) {
        return tickets[ticketId].seatid;
    }
    
}