# Architecture & Design document

## Link to github code
[https://github.com/AY2223-IS4302-G18/is4302-project](https://github.com/AY2223-IS4302-G18/is4302-project)

## Group members:

| Member Name | Admin Number |
| ---|---|
| Han Jun Ding | A0221230E |
| Sean Phang | |
| Tan Teck Hwee | |
| Teo Chin Kai Remus| A0217148E |
| Teo Phing Huei, Aeron | A0225860E |

## Contents

* [Introduction](#introduction)
* [Glossary](#glossary)
* [Business Model](#business-model)
    * [Stakeholder benefits](#stakeholder-benefits)
* [Architecture](#architecture)
* [Implementation](#implementation) 

## Introduction

The purpose of this project is to leverage on cutting-edge capabilities of blockchain technology to effectively tackle the problem of scalping in the context of popular events. We aim to utilise the blockchain technology to create a secure, transparent, and decentralized system that helps event organisers, ticketing agencies and consumers to effectively manage the sale and distribution of tickets without unfair competition.

## Glossary

| Name | Explanation |
| -- | -- |
| Buyer | User that purchases event tickets on the platform |
| Seller | User that lists events on the platform |
| Tokens | Currency for the platform that is created using ERC20 |

<div style="page-break-after: always;"></div>

## Business Model

The current challenges with the ticket sale systems are the existence of scalpers that benefits from the traditional ticketing sale system and the lack of authenticity and accountability of tickets. Even though these challenges are not completely preventable using blockchain, the team still sees the potential benefits of deploying such application of blockchain. For instance, mechanisms were introduced to reduce the opportunities for scalpers from benefitting such as a bidding system, placing a bulk purchase limit and prevention of buyer-to-buyer ticket transfer. This also provide more transparency of information from the verification of organisations to the transaction of each ticket. Moreover, this platform serves as a central platform that removes the involvement of a intermediary ticket retailers when setting up an event. Ethereum (ETH) is used for purchasing tickets upon a successful bid. The platform has also implemented a digital currency called **EventTokens** for buyers to bid for tickets. A token market platform has also been implemented for buyers to sell or buy tokens among themselves. 

### Stakeholder benefits

As a **Buyer**:
* Reduced unfair competition with scalpers using the implemented [ticket bidding system](#ticket-bidding) using tokens and by limiting the number of tickets that can be purchased for each account.
* Transparency in the entire process from viewing an event to transaction of tickets. 
* Guaranteed refund of ETH in the event of fraduluent event listings after purchasing tickets.
* Increased accessibility to all events with a centralised event listing platform. 

As a **Seller**:
* Potential increase in sales revenue with event listed on a centralised platform.
* Lower interest fees of 5% as compared to traditional ticket retailers that collect 15-20% depending on the scale of the event.

As the **Platform** owner:
Revenue source from:
* gaining 5% commission fees for each successful event.
* absorbing the deposit submitted by seller at the start of the event for unsuccessful events.
* gaining commission fees by providing the `EventTokenMarket.sol` for transaction of tokens used for biddings.

### Assumptions

The following points mentioned below are the assumptions made for our application

* The oracle is the `Account.sol` contract and other accounts that `Account.sol` certifies. These parties are assumed to be trusted. The detailed explanation on the implementation is mentioned under [Account Validation](#account-validation) section.
* We assume that the gas fees incurred during transactions are negligible.

## Architecture

![ArchitectureDiagram](diagrams/diagram_images/ArchitectureDiagram.png)

An overview of the main components and how different stakeholders and contracts interact is explained in detail below.

`Platform.sol` is the main contract that Sellers or Buyers will interact with.

The main capabilities of `Platform.sol` is to:
* Allow Sellers to list events on the platform.
* Allow Buyers to bid after an event is listed and buy tickets upon successful bidding.

`Platform.sol` interacts with other contracts such as:

* `Account.sol` : conducts verification on whether an Seller is a verified on the Platform to list events. It also certifies a set of trusted accounts to provide rights for them to verify Sellers.
* `Event.sol` : creation and storing of the event information & creation of tickets through `Ticket.sol`.

`EventTokenMarket.sol` along with `EventTokenMarketAlgorithm.sol` are the contracts where buyers can trade tokens that will be used during the bidding ticket process.

The team exercises data segregation and separation with these implementation of different contracts that serves their individual purposes.

## Implementation

### Accounts

#### Account Management

`Account.Sol` stores three main information for accounts.
1) **state** : whether an account is verified or not
2) **verifier** : the certifier that verified the account
3) **certified** : whether an account is certified to verify other address

These information are stored in a mapping where the key is the address and the value would be the account object.

The relevant getter and setter functions for these information are also included.

This structure ensures ease of obtaining any account information. Moreover, any new account is defaulted with an unverified state, verifier address of 0 and certified set to false. This prevents unverified account to list events or verify other accounts.

#### Account Validation

The team assumes that `Account.sol` is trusted and the accounts certified by `Account.sol` are also trusted.

`Account.sol` has the authoritity to determine whether an account is certified to conduct verification for an account. Only when an account is certified by `Account.sol`, the account can verify the authenticity of other accounts.

```
AccountContract.certifyAccount(address addr)
```
Example (Certifying account[1]):
```
AccountContract.certifyAccount(address(account[1]))
```

After `Account.sol` certifies a set of accounts to provide them with the responsibility to verify authenticity of accounts, they can verify accounts that allows the requested accounts to be able to list an event. When a certified account conducts checks and is sure that an account is authentic, the certified account's address is stored in the requester's account information because the status of an account is changed. However, the authentication process will be done off-chain.  

```
AccountContract.verifyAccount(address addr)
```
Example (Verifying account[2]):
```
AccountContract.verifyAccount(address(account[2]))
```

An example scenario of the validation process will be as follows:
1. `Account.sol` certifies *account[1]* that can verify other accounts. The trusted accounts will be the oracle.
2. *account[2]* wants to list an event on the platform and has requested to be verified. *account[1]* can now conduct background checks on the authenticity of *acccount[2]*. This process will be done off-chain
3. Upon successful verification, *account[1]* verifies *account[2]* and now *account[2]* can list on the platform.

The team understand that this solution is not a full-proof solution to the oracle problem. This is due to `Account.sol` being a single point of failure and an account is also certified by only one certifier without any cross-checking.

Improvements to this implementation would be implementing ASTRAEA with voting and certifying process. This involves multiple stakeholders in the validation process and ensures that the entire voting process is fair. Stakeholders will also be incentivised or penalised depending on their validation result and whether they are a voter or certifer. However, this idea would be pushed for future developments due to time constraints.

### Ticket Sale System
 Our application adopts a state machine model to represent different behavioural contract stages and use state transitions to control the execution flow of the program. There are 5 main phases in our ticketing sales system that every event listed on the platform will undergo.This ticket sale system implementation is integrated in `Platform.sol`.

1. Initial Phase
    * When an authorised seller lists an event on the platform, the event will be initialized to an initial state which implies that ticket sale is not available yet.
2. Bidding Phase
    * An authorised seller can commence the start of the bidding phase for a listed event which will allow buyers to bid for tickets.
    * During this phase, buyers can place & update bids for event tickets. ETH is used to pay for the price of tickets which is fixed while EventTokens are used for bidding of tickets.
    * The authorised seller can decide when to close the bidding phase. When executed, the smart contract will perform an algorithm to distribute tickets in a way such that priority is given to bidders that bidded with more EventTokens and automatically transfer tickets to successful bidders as well as return ETH back to unsuccessful bidders.
3. Buying & Refund Phase 
    * In this phase, buyers can perform normal purchasing of leftover available tickets and refunding of tickets is also possible through the platform. 
4. Seller End Phase
    * In this phase, the seller of event will declare the end of the event and buyers can no longer buy or refund tickets.
5. Platform End Phase
    * Once the seller has declared the end of an event, the platform owner will verify whether the event ended successfully or unsuccessfully. 
    * Upon successful end of event, ticket sales and deposits will be released to the seller and buyers will earn EventTokens.
    * Upon unsuccessful end of event, ticket sales will be returned to buyers and deposit will not be released to the seller.

#### Listing events
To list an event, the organiser has to specify the venue year, month, day, hour, minute, second, capacity, its address and ticket price details of the event to be held. 
```
PlatformContract.listEvent(string memory title,
        string memory venue,
        uint256 year, uint256 month, uint256 day, uint256 hour, uint256 minute, uint256 second,
        uint256 capacity,
        uint256 priceOfTicket,
        address seller)
```
Only a verified accounts can act as an organiser and list events on the platform. Organiser has to also make a deposit of half the total ticket sales (capacity * priceOfTicket / 2) to list an event. This is to prevent the organiser from irresponsibly creating and cancelling an event. 

The event details will then be passed to the event contract for the creation of the actual event object. Event tickets will also be generated and mapped to the newly created eventId.

#### Commence Bidding
Commence bidding function changes the event state to “bidding”, allowing buyers to start bidding for the ticket. Only the original organiser is allowed to commence bidding and event state must be “initial” when this function is called, after which event state will be changed to “bidding”.
```
eventContract.setEventState(eventId, Event.eventState.bidding);
```

#### Ticket bidding
Tickets will be available for bidding when the seller commences the start of the bidding phase. In this bidding phase, buyers will be able to place bids for an event by specifying the eventId, quantity, tokenBid parameters.  

```
PlatformContract.placeBid(uint256 eventId, uint256 quantity, uint256 tokenBid)
```

The following conditions must be met for a buyer to successfully bid for tickets to an event:  
1. Event must be valid and ongoing, with bid state set as “bidding".
2. Buyers can place a bid for a minimum of 1 ticket, and up to a maximum of 4 tickets. This is to prevent scalpers from bulk bidding event tickets.
3. Buyer can place a bid using a minimum of 0 EventTokens to use for bidding. If a buyers to bid using EventTokens, the buyer must have sufficient EventTokens specified in tokenBid parameter to place the bid as EventTokens are collected upon placing of bid.
4. Buyers must have sufficient ETH specified in msg.value to place the bid for desired amount of tickets as ETH is collected upon placing of bid.


Example (Placing a bid of 4 tickets using 5 tokenBids each for eventId 0):
```
PlatformContract.placeBid(0, 4, 5)
```

Although one account can only place a bid for a specific event once, there is an updateBid function available for buyers to update their biddings.  

#### Close Bidding
Buyers can continue to place and update bids up until the seller decides to close the bidding. On closure, our algorithm will automatically distribute tickets to successful bidders as well as return ETH back to unsuccesful bidders.

The algorithm logic for ticket distribution is as follows:
1. Starting from the highest token bid, the algorithm transfer tickets to bidders, breaking tie by first come first serve if bidders have the same token bid amount.
2. The algorithm will continue transfering tickets until all tickets left for event have been given out and will return ETH to unsucessful bidders or continue transfering tickets until all bidders have received tickets such that there are leftover tickets.
3. Update tickets left for event
4. Change event state to allow buying and refunding of tickets.

In this close bidding phase, only the seller who listed the event will be able to close bidding for an event by specifying the eventId. 
```
PlatformContract.closeBidding(uint256 eventId)
```
Example (Close bidding phase for eventId 0):
```
PlatformContract.closeBidding(0)
```  

#### Buying tickets
The buyTickets function is to allow buyers to buy the remaining, available (unsold or refunded) tickets after the bidding session has closed. 

```
PlatformContract.buyTickets(uint256 eventId, uint8 quantity)
```

The following conditions must be met for a buyer to successfully buy tickets to an event:
1. Event must be a valid and ongoing, with event state set as “buyAndRefund”
2. Buyers can buy a minimum of 1 ticket, and up to a maximum of 4 tickets. This is to prevent scalpers from bulk buying event tickets and reselling at a higher price.
3. Buyers can only buy tickets if there are still tickets available for sale.
4. Buyer has sufficient ETH to buy the desired amount of tickets

#### Ticket refund

### Event end
For simplicity of this project, the team only considered 2 possible ending outcomes for an event:
1. Successful event 

    For an event outcome to be considered 'successful', the actual event must have occured/ carried out successfully. After which, the seller is able to call *sellerEndEvent(uint256 eventId)* function. This function changes the event state to "sellerEventEnd" and informs the contract owner that event has ended successfully. Contract owner can then call *endSuccessfulEvent(uint256 eventId)* function to release the ticket sales and deposits to the seller. 

2. Unsuccessful event

    For an event outcome to be considered 'unsuccessful', the actual event did not take place. This can be due to organiser disappearing or running away before the actual event. In such scenario, contract owner can then call the *endUnsuccessfulEvent(uint256 eventId)*. This function refunds ETH to the buyers, who participated in the bidding and buying of tickets, accordingly. The deposits from the organiser will be kept by the platform as a form of penalty.

The purpose of the above methods is to prevent organisers from being irresponsible and scamming buyers through the "fake" event. Ticket sales and deposits will be managed by the platform and only released to the organiser after event ended successfully. 

Note: It is assumed here that the contract owner will be honest in verifying the actual event outcome and calling the appropriate ending function.

### Tokenomics