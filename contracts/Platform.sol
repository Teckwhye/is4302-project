pragma solidity ^0.5.0;

import "./Account.sol";
import "./Event.sol";
import "./Ticket.sol";
import "./EventToken.sol";

contract Platform {
    Account accountContract;
    EventToken eventTokenContract;
    Event eventContract;

    event TransferToBuyerSuccessful(address to, uint256 amount);

    mapping(address => uint256) sellerDepositedValue;

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

    /*Ensure caller is a verified seller*/
    modifier isOrganiser() {
        require(accountContract.viewAccountState(msg.sender) == accountContract.getVerifiedStatus(),"You are not a verified seller");
        _;
    }

    // list Event on Platform
    function listEvent(string memory title,
        string memory venue,
        uint256 year, uint256 month, uint256 day, uint256 hour, uint256 minute, uint256 second,
        uint256 capacity,
        uint256 ticketsLeft,
        uint256 priceOfTicket,
        address seller) public payable isOrganiser() returns (uint256) {

        // however msg.value here will not be sent to event contract. msg.value at event contract is 0.
        require(msg.value >= calMinimumDeposit(capacity,priceOfTicket) * 1 wei, "Insufficient deposits. Need deposit minimum (capacity * priceOfTicket)/2 * 50000 wei to list event.");

        uint256 newEventId = eventContract.createEvent(title, venue, year, month, day,hour,minute, second, 
        capacity, ticketsLeft,priceOfTicket,seller);

        return newEventId;
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

    function endEvent(uint256 eventId) public isOrganiser() {
        address seller = eventContract.getEventSeller(eventId);
        require(seller == msg.sender, "Only original seller can end event");
        eventContract.endEvent(eventId);
        msg.sender.transfer(sellerDepositedValue[seller]);
    }

    function calMinimumDeposit(uint256 capacity, uint256 priceOfTicket) public pure returns(uint256){
        // 1USD = 50,000 wei
        return (capacity * priceOfTicket)/2 * 50000;
    }



}