# Architecture & Design document

## Group members:

| Member Name | Admin Number |
| ---|---|
| Han Jun Ding | A0221230E |
| Sean Phang | |
| Tan Teck Hwee | A0217207M |
| Teo Chin Kai Remus| A0217148E |
| Teo Phing Huei, Aeron | A0225860E |

## Introduction

The purpose of this project is to leverage on cutting-edge capabilities of blockchain technology to effectively tackle the problem of scalping in the context of popular events. We aim to utilise the blockchain technology to create a secure, transparent, and decentralized system that helps event organizers, ticketing agencies and consumers to effectively manage the sale and distribution of tickets without unfair competition.

## Motivation

The current challenges with the ticket sale systems are the existence of scalpers that benefits from the traditional ticketing sale system and the lack of authenticity and accountability of tickets. Even though these challenges are not completely preventable using blockchain, the team still sees the potential benefits of deploying such application of blockchain. For instance, the implementation of priority system to reduce the opportunities for scalpers from benefitting and provide more transparency of information from the verification of organisations to the transaction of tickets. 

## Glossary

| Name | Explanation |
| -- | -- |
| Buyer | User that purchases event tickets on the platform |
| Organiser | User that lists events on the platform |

## Contents

* [Architecture](#architecture)
* [Implementation](#implementation) 

## Architecture

![ArchitectureDiagram](diagrams/diagram_images/ArchitectureDiagram.png)

An overview of the main components and how different stakeholders and contracts intereact is explained in detail below.

`Platform.sol` is the main contract that Organisers or Buyers will interact with.

The main capabilities of `Platform.sol` is to:
* Allow Organisers to list events on the platform.
* Allow Buyers to bid after an event is listed and buy tickets upon successful bidding.

`Platform.sol` interacts with other contracts such as:

* `Account.sol` : conducts verification on whether an Organiser is a verified on the Platform to list events. It also certifies a set of trusted accounts to provide rights for them to verify Organisers.
* `Event.sol` : creation and storing of the event information & creation of tickets through `Ticket.sol`.

`EventTokenMarket.sol` along with `EventTokenMarketAlgorithm` are the contracts where buyers can trade tokens that will be used during the bidding ticket process.

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
#### Token Supply and Distribution
The total supply of EventToken is not capped as we believed the high usage of it (Which the token will be burned when used) will ensure the value of the token. EventToken will be distributed when Buyers attended a successful event as defined above and cannot be minted directly. EventToken are only minted when there is a successful event and it will be awarded to those that attend the event. The amount distributed is determined by 5 percent of event ticket price divided by 50,000 wei. For example, an event ticket that cost 1,000,000 wei will allow a buyer to attain 1 EventToken as 5 percent of 1,000,000 is 50,000 which divded by 50,000 will be 1.

#### Token Utility
EventToken can only be utilised in bidding to gain priority in purchasing ticket. EventToken cannot be transfer from Buyer to Buyer and can only be traded on EventTokenMarket. The main idea of trading the EventToken will be to either gain more tokens for bidding by purchasing them or to earn Ethereum by selling them.

#### Token Value and Delation
EventToken value is based on popularity of events and the demand for event tickets. If there is a demand for event tickets, more EventToken will be required for buyers to ensure that they have a priority in purchasing tickets. When a Buyer requires more EventToken, it can be purchased on EventTokenMarket if only another person have listed a EventToken to sell. The price of the EventToken is then decided by the algorithm of the market to ensure no foulplay which will be explained in the section EventTokenMarket below. To ensure that the amount of circulating tokens are not infinite, EventTokens will be burned when used in bidding which also means that no refund will be given for biddings.

### EventTokenMarket
Buyers can choose to either list their EventTokens or to purchase more EventTokens with `EventTokenMarket.sol`. The contract will take a 10 percent cut for every purchase.
#### List
Buyers can only list EventTokens that they have and these tokens will be transferred to `EventTokenMarket.sol` contract. When a Buyer list EventTokens, it will emit SellOrderListed event which they can see their sellOrderId which can be used to delist their order to get back their tokens.

Example (Listing 5 EventTokens):
```
EventTokenMarketContract.list(5)
```
#### Delist
Buyers can only delist EventTokens by using the sellOrderId emitted when they list their tokens in `EventTokenMarket.sol` contract. Checks will be made to ensure that Buyer can only delist their own sell order.

Example (Delisting sellOrderId 1):
```
EventTokenMarketContract.unlist(1)
```
#### Purchase Token
Buyers can purchase EventTokens by first checking the current price of tokens that they want to purchase then providing enough ethereum when they purchase tokens. How the price and purchase work will be explained in the Algorithm of Market below.

Example (Checking the price of 5 EventTokens):
```
EventTokenMarketContract.checkCurrentPrice(5)
```
Example (Purchasing 5 EventTokens):
```
EventTokenMarketContract.purchaseTokens(5)
```
#### Algorithm of Market
The selling of EventTokens are based on First Come First Serve basis. Whoever listed their EventTokens first, will have their tokens sold first. The price of EventTokens are based on 2 factor, the total supply of selling tokens in the market and the amount of tokens a Buyer purchase. Every additional 1 percent of total selling tokens a Buyer is purchasing, the price of each token will be increased by 10,000 wei starting from the base price of 50,000 wei. This will ensure that when demand of EventToken is high, price of EventToken will be high. For example, if there is only 1 EventToken to sell and a Buyer wants to purchase that EventToken, the price will be 50,000 + 99 * 10,000 (1% below will be charged by the base price only thus 99 percent is the additional charge). With this logic, when selling quantity of market is low, the price will be high thus Buyers will want to sell when quantity is low and purchase when selling quantity is high. When we factor in to the demand for a popular concert, Buyers might want to use their tokens thus selling quantity will be low and demand for the tokens will be high which result in high price. Similarly if the demand is low, price of EventToken will be subjected mainly to the base price if there is a huge amount of EventTokens being sold.

Although a Buyer can possibly keep the purchase price of EventTokens to be low by continuously purchasing 1% and below of the total sell quantity, other Buyers who will urgently get EventsTokens can purchase with the higher price, resulting in Buyers not attaining enough tokens for bid and potentially buying tokens for nothing.

EventTokenMarket tries to prevent foulplay by not allowing Buyers to choose who they sell their EventTokens to or who they purchase their EventTokens from. As Buyers are also unable to set their own price for their EventTokens, it is unlikely they are able to manupilate the market too.