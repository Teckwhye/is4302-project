pragma solidity ^0.5.0;

import "./Account.sol";

contract Buyer {
    Account accountContract;

    constructor(Account accountAddress) public {
        accountContract = accountAddress;
    }

    modifier isBuyer(address addr) {
        require((accountContract.viewAccountRegistered == true) && (accountContract.viewAccountState == Account.status.unverified));
        _;
    }

    /* Depending on the implementation, these functions may be in a different contract */

    /* Buy tickets for an event by specifying the eventId and amount*/
    function buyTickets(eventId, quantity) public isBuyer(msg.sender) {
        require(quantity <= 4, "You have passed the maximum bulk purchase limit");
        //require a cooldown of 24hours before another purchase can be bought
        //include refund mechanism
    }

    /* Refunds part of the token back to the buyer */
    function refundTickets(ticketId) public isBuyer(msg.sender) {
        //include refund mechanism using tokenism
    }

    /* View available tickets for an event that are listed on the platform*/
    function viewListedEvents(eventId) public view isBuyer(msg.sender) {
        //retrieve eventid from platform & display information
    }

    /* View tickets bought */
    function viewTicketsBought(ticketId) public view isBuyer(msg.sender) {
        //requirement: ticketid's owner is the sender
        //retrieve info of a bought ticket
    }
 
}