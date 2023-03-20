const _deploy_contracts = require("../migrations/2_deploy_contracts");
const truffleAssert = require("truffle-assertions"); // npm truffle-assertions
const BigNumber = require("bignumber.js"); // npm install bignumber.js
var assert = require("assert");

var Platform = artifacts.require("../contracts/Platform.sol");

contract("Platform", function (accounts) {
    before(async () => {
        platformInstance = await Platform.deployed();
    });
    
    console.log("Testing Platform contract");

    it("Insufficent funds to buy tickets", async () => {
        await truffleAssert.reverts(
            platformInstance.buyTickets(1, 1, 500, {from: accounts[1], value: 0}),
            "Buyer has insufficient ETH to buy tickets"
        );
    });

    it("Quantity exceeded", async () => {
        // Maximum ticket purchase limit is set to 4
        await truffleAssert.reverts(
            platformInstance.buyTickets(1, 10, 500, {from: accounts[1], value: 100000}),
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
        let buyTicketProcess = await platformInstance.buyTickets(1, 3, 300, {from: accounts[1], value: 1000})
        truffleAssert.eventEmitted(buyTicketProcess, 'TransferToBuyerSuccessful');
    });

})