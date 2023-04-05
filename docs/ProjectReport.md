# Architecture & Design document

## Group members:

| Member Name | Admin Number |
| ---|---|
| Han Jun Ding | |
| Sean Phang | |
| Tan Teck Hwee | |
| Teo Chin Kai Remus| A0217148E |
| Teo Phing Huei, Aeron | A0225860E |

## Introduction
The purpose of this project is to leverage on cutting-edge capabilities of blockchain technology to effectively tackle the problem of scalping in the context of popular events. We aim to utilise the blockchain technology to create a secure, transparent, and decentralized system that helps event organizers, ticketing agencies and consumers to effectively manage the sale and distribution of tickets without unfair competition.

## Current challenges

## Contents
* [Architecture](#architecture)
* [Implementation](#implementation) 

## Architecture

Overview of the architecture.

![ArchitectureDiagram](diagrams/diagram_images/ArchitectureDiagram.png)

## Implementation

### Ticket Sale System
 Our application adopts a state machine model to represent different behavioural contract stages and their transitions to control the execution flow of the program. There are 4 main phases in our ticketing sales system that every event listed on the platform will undergo.

1. Initial Phase
    * By default, when an event is listed on the platform, it will be initialized to this closed state which means that it is still not available to buyers.
2. Bidding Phase
    * Seller will be authorised to commence the start of the bidding phase for a listed event which will allow buyers to bid for tickets.
    * Buyers place bids such that ETH is used to pay for the price of tickets but the bidding for each ticket is using EventTokens. 
    * The seller can decide when to close the bidding phase such that when executed, the smart contract will perform an algorithm that will give priority to bidders with more EventTokens and automatically transfer tickets to successful bidders and return ETH back to unsuccessful bidders.
3. Buying & Refund Phase 
    * In this phase, buyers can perform normal purchasing of leftover available tickets and refunding of tickets is also possible through the platform. 
4. End Phase
    * This phase marks the end of a successful event where ETH will be released to seller.

#### Selling tickets

#### Ticket bidding
Tickets will be available for bidding when the seller commences the start of the bidding phase. In this bidding phase, buyers will be able to place bids for an event by specifying the eventId, quantity, tokenBid parameters.  

```
PlatformContract.placeBid(uint256 eventId, uint256 quantity, uint256 tokenBid)
```
Example (Placing a bid of 4 tickets using 5 tokenBids each for eventId 0):
```
PlatformContract.placeBid(0, 4, 5)
```

Although one account can only place a bid for a specific event once, there is an updateBid function available for buyers to update their biddings.  

#### Close Bidding
Buyers can continue to place and update bids up until the seller decides to close the bidding. On closure, our algorithm will automatically distribute tickets to successful bidders as well as return ETH back to unsuccesful bidders.

The algorithm logic for ticket distribution is as follows:
1. Starting from the highest token bid, transfer tickets to bidders break tie by first come first serve if bidders have the same token bid amount.
2. Continue transfering tickets until all tickets left for event have been given out and return ETH to unsucessful bidders or continue transfering tickets until all bidders have received tickets such that there are leftover tickets.
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

#### Ticket refund

### Accounts Management

#### Seller Validation

### Tokenomics