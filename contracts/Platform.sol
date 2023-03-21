pragma solidity ^0.5.0;

import "./Account.sol";
import "./Seller.sol"; 
import "./Event.sol";
import "./Ticket.sol";
import "./EventToken.sol";

contract Platform {
    Account accountContract;
    Seller sellerContract;
    EventToken eventTokenContract;
    Event eventContract;

    event TransferToBuyerSuccessful(address to, uint256 amount);

    // Platform can only exist if other contracts are created first
    constructor(Account accountAddr, EventToken eventTokenAddr, Event eventAddr) public {
        accountContract = accountAddr;
        eventTokenContract = eventTokenAddr;
        eventContract = eventAddr;
    }

    struct bidInfo {
        uint256 totalPrice;
        uint256 totalTokenBid;
        uint256 firstIndexForEventBiddings; // For ease of updating bid
    }

    mapping(uint256 => uint256) public eventTopBid; // eventId => topBid
    mapping(uint256 => mapping(uint256 => address[])) public eventBiddings; // eventId => (tokenBid => addressArray) 
    mapping(address => mapping(uint256 => bidInfo)) public addressBiddings; // address => (eventId => bidInfo)

    /* Ensure caller is a buyer */
    modifier isBuyer() {
        require(accountContract.viewAccountState(msg.sender) == accountContract.getUnverifiedStatus());
        _;
    }

    // Commence bidding for event
    function commenceBidding(uint256 eventId) public {
        require(msg.sender == eventContract.getEventSeller(eventId), "Only seller can commence bidding");
        require(eventContract.getEventBidState(eventId) == Event.bidState.close, "Event already open for bidding");

        eventContract.setEventBidState(eventId, Event.bidState.open);
    }

    // Bid for ticket
    function placeBid(uint256 eventId, uint8 quantity, uint256 tokenBid) public payable isBuyer() {
        require(eventContract.getEventBidState(eventId) == Event.bidState.open, "Event not open for bidding");
        require(quantity <= 4, "You have passed the maximum bulk purchase limit");
        require(msg.value >= eventContract.getEventTicketPrice(eventId) * quantity, "Buyer has insufficient ETH");
        require(eventTokenContract.checkEventTokenOf(msg.sender) >= tokenBid * quantity, "Buyer has insufficient EventTokens");

        //TODO: Transfer tokenBid & ETH to contract
        //eventTokenContract.transferFrom(msg.sender, address(this), tokenBid * quantity);

    
        // Record eventBiddings
        uint256 firstIdx;
        for (uint8 i = 0; i < quantity; i++) {
            eventBiddings[eventId][tokenBid].push(msg.sender);
            if (i == 0) {
                firstIdx = eventBiddings[eventId][tokenBid].length - 1;
            }
        }

        // Record bidInfo for ease of future refund / update 
        uint256 totalPrice = quantity * eventContract.getEventTicketPrice(eventId);
        uint256 totalTokenBid = quantity * tokenBid;
        bidInfo memory newBidInfo = bidInfo(totalPrice, totalTokenBid, firstIdx);
        addressBiddings[msg.sender][eventId] = newBidInfo;
        
        // Update top bid
        if (tokenBid > eventTopBid[eventId]) {
            eventTopBid[eventId] = tokenBid;
        }
    }

    // Close bidding and transfer tickets to top bidders
    function closeBidding(uint256 eventId) public {
        require(msg.sender == eventContract.getEventSeller(eventId), "Only seller can close bidding");
        require(eventContract.getEventBidState(eventId) == Event.bidState.open, "Event not open for bidding");

        uint256 bidAmount = eventTopBid[eventId];
        uint256 ticketsLeft = eventContract.getEventTicketsLeft(eventId);

        // Tickets given out starting from top bidders
        while (ticketsLeft != 0) {
            address[] memory bidderList = eventBiddings[eventId][bidAmount];
            for (uint256 i = 0; i < bidderList.length; i++) {
                if (bidderList[i] == address(0)) continue; 

                // TODO: transfer ticket to address @ bidderList[i]
                ticketsLeft--;

                if (ticketsLeft == 0) break;
            }
            if (bidAmount == 0) break;
            bidAmount--;
        }

        // Return unsuccessful bidders
        // returnBiddings()
        eventContract.setEventBidState(eventId, Event.bidState.close);
    }   

    // Return unsuccessful bidders their corresponding ETH and tokens
    function returnBiddings() public {

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



}