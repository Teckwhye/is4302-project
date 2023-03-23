const _deploy_contracts = require("../migrations/2_deploy_contracts");
const truffleAssert = require("truffle-assertions"); // npm truffle-assertions
const BigNumber = require("bignumber.js"); // npm install bignumber.js
var assert = require("assert");

var Event = artifacts.require("../contracts/Event.sol");
var Ticket = artifacts.require("../contracts/Ticket.sol");


contract("Event", function (accounts) {
    before(async () => {
        ticketInstance = await Ticket.deployed();
        eventInstance = await Event.deployed();
    });
    
    console.log("Testing Event contract");

    it("Create Event", async () => {
        
        await eventInstance.createEvent("Title 0", "Venue 0", 2024, 3, 11, 12, 30, 0, 10, 10, 5, accounts[1], {from: accounts[1]});

        const title0 = await eventInstance.getEventTitle(0);

        await assert("Title 0", title0, "Failed to create event");
        
    });
})