const _deploy_contracts = require("../migrations/2_deploy_contracts");
const truffleAssert = require("truffle-assertions"); // npm truffle-assertions
const BigNumber = require("bignumber.js"); // npm install bignumber.js
var assert = require("assert");

const oneEth = new BigNumber(1000000000000000000); // 1 eth

var Platform = artifacts.require("../contracts/Platform.sol");
var Account = artifacts.require("../contracts/Account.sol");
var Event = artifacts.require("../contracts/Event.sol");

contract("Platform", function (accounts) {
    before(async () => {
        platformInstance = await Platform.deployed();
        accountInstance = await Account.deployed();
        eventInstance = await Event.deployed();
    });
    
    console.log("Testing Platform contract");

    it("Account(Seller) unable to list event if yet to be verified", async () => {
        await truffleAssert.reverts(
            platformInstance.listEvent(
                "Harry Styles concert", "Stadium", 2024, 03, 21, 18,00,00,600,600,65, accounts[1],{from: accounts[1], value: 0}),
            "You are not a verified seller"
        );
    });

    it("Account(Seller) not verified at the start", async () => {
        var state = await accountInstance.viewAccountState.call(accounts[1]);
        var unverifiedStatus = await accountInstance.getUnverifiedStatus.call();
        await assert.strictEqual(state.toString(),unverifiedStatus.toString(),"Account is already verified.");
    });

    it("Verify account(Seller)", async () => {
        await accountInstance.verifyAccount(accounts[1]);
        var state = await accountInstance.viewAccountState.call(accounts[1]);
        var verifiedStatus = await accountInstance.getVerifiedStatus.call();
        await assert.strictEqual(state.toString(),verifiedStatus.toString(),"Account is not verified.");
    });

    it("Insufficient deposits to list event", async () => {
        await truffleAssert.reverts(
            platformInstance.listEvent(
                "Harry Styles concert", "Stadium", 2024, 03, 21, 18,00,00,5,5,65,accounts[1], {from: accounts[1], value: 0}),
            "Insufficient deposits. Need deposit minimum (capacity * priceOfTicket)/2 * 50000 wei to list event."
        );
    });

    it("Event listed successfully", async () => {
        await platformInstance.listEvent(
            "Harry Styles concert", "Stadium", 2024, 03, 21, 18,00,00,5,5,65,accounts[1], {from: accounts[1], value: oneEth});
        var eventTitle = await eventInstance.getEventTitle(0);
        await assert.strictEqual(eventTitle.toString(),"Harry Styles concert","Event not listed");
    });

    it("Insufficent funds to buy tickets", async () => {
        await truffleAssert.reverts(
            platformInstance.buyTickets(1, 1, 500, {from: accounts[2], value: 0}),
            "Buyer has insufficient ETH to buy tickets"
        );
    });

    it("Quantity exceeded", async () => {
        // Maximum ticket purchase limit is set to 4
        await truffleAssert.reverts(
            platformInstance.buyTickets(1, 10, 500, {from: accounts[2], value: 100000}),
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
        let buyTicketProcess = await platformInstance.buyTickets(1, 3, 300, {from: accounts[2], value: 1000})
        truffleAssert.eventEmitted(buyTicketProcess, 'TransferToBuyerSuccessful');
    });

})