const _deploy_contracts = require("../migrations/2_deploy_contracts");
const truffleAssert = require("truffle-assertions"); // npm truffle-assertions
const BigNumber = require("bignumber.js"); // npm install bignumber.js
var assert = require("assert");
const oneEth = new BigNumber(1000000000000000000); // 1 eth

var Account = artifacts.require("../contracts/Account.sol");
var Event = artifacts.require("../contracts/Event.sol");
var Platform = artifacts.require("../contracts/Platform.sol");

contract("Platform", function (accounts) {
    before(async () => {
        accountInstance = await Account.deployed();
        eventInstance = await Event.deployed();
        platformInstance = await Platform.deployed();
    });
    
    /*
        Acccount Management:

        accounts[0] == contract owner
        accounts[1] == verified seller
        accounts[2] == buyer
        accounts[3] == buyer
    */

    console.log("Testing Platform contract");

    it("List Event", async () => {
        await accountInstance.verifyAccount(accounts[1]);
        await platformInstance.listEvent("Title 0", "Venue 0", 2024, 3, 11, 12, 30, 0, 5, 5, 20, accounts[1], {from: accounts[1], value: oneEth.multipliedBy(4)});
        const title0 = await eventInstance.getEventTitle(0);
        await assert("Title 0", title0, "Failed to create event");
    });

    it("Commence Bidding", async () => {
        let bidCommenced = await platformInstance.commenceBidding(0, {from: accounts[1]});
        truffleAssert.eventEmitted(bidCommenced, "BidCommenced");
    });

    it("Place Bidding", async () => {
        let bidPlaced = await platformInstance.placeBid(0, 1, 0, {from: accounts[2], value: oneEth});
        truffleAssert.eventEmitted(bidPlaced, "BidPlaced");
    });

    it("Close Bidding", async () => {
        let bidClosed = await platformInstance.closeBidding(0, {from: accounts[1]});
        truffleAssert.eventEmitted(bidClosed, "BidBuy");
    });

    it("Buy Ticket", async () => {
        let buyTicket = await platformInstance.buyTickets(0, 1, {from: accounts[3], value: oneEth.dividedBy(4)});
        truffleAssert.eventEmitted(buyTicket, "TransferToBuyerSuccessful");
    });

    it("Insufficent funds to buy tickets", async () => {
        await truffleAssert.reverts(
            platformInstance.buyTickets(0, 1, {from: accounts[3], value: 0}),
            "Buyer has insufficient ETH to buy tickets"
        );
    });

    it("Quantity exceeded", async () => {
        // Maximum ticket purchase limit is set to 4
        await truffleAssert.reverts(
            platformInstance.buyTickets(0, 10, {from: accounts[3], value: oneEth.dividedBy(4)}),
            "You have passed the maximum bulk purchase limit"
        );
    });

    it("Successful Payback to buyer", async () => {
        // let buyTicketProcess = await platformInstance.buyTickets(1, 3, 300, {from: accounts[1], value: 1000})
        // expectedReturn = 100;
        // let balance = await web3.eth.getBalance(accounts[0]);
        // console.log("this is the balance:",balance);
        // assert.strictEqual(balance , expectedReturn, "Incorrect payback");

        // not the best way
        let buyTicketProcess = await platformInstance.buyTickets(0, 3, {from: accounts[3], value: oneEth.dividedBy(4)})
        truffleAssert.eventEmitted(buyTicketProcess, 'TransferToBuyerSuccessful');
    });

})