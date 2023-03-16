const _deploy_contracts = require("../migrations/2_deploy_contracts");
const truffleAssert = require("truffle-assertions"); // npm truffle-assertions
const BigNumber = require("bignumber.js"); // npm install bignumber.js
var assert = require("assert");

var ConcertToken = artifacts.require("../contracts/ConcertToken.sol");

contract("ConcertToken", function (accounts) {
    before(async () => {
        concertTokenInstance = await ConcertToken.deployed();
    });
    
    console.log("Testing ConcertToken contract");

    it("Get Concert Token", async () => {
        let totalSupplyBefore = await concertTokenInstance.getCurrentSupply({from: accounts[1]});
        await concertTokenInstance.getConcertToken({from: accounts[1], value: 5000000});
        let totalSupplyAfter = await concertTokenInstance.getCurrentSupply({from: accounts[1]});
        let totalSupplyAdded = totalSupplyAfter - totalSupplyBefore;
        assert.equal(await concertTokenInstance.checkConcertToken({from: accounts[1]}), 100);
        assert.equal(totalSupplyAdded, 100);
    });

    it("Refund Conert Token", async () => {
        let totalSupplyBefore = await concertTokenInstance.getCurrentSupply({from: accounts[1]});
        await concertTokenInstance.refundConcertToken(100,{from: accounts[1]});
        let totalSupplyAfter = await concertTokenInstance.getCurrentSupply({from: accounts[1]});
        let totalSupplyRemoved = totalSupplyBefore - totalSupplyAfter;
        assert.equal(await concertTokenInstance.checkConcertToken({from: accounts[1]}), 0);
        assert.equal(totalSupplyRemoved, 100);
    });
})