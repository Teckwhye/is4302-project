const _deploy_contracts = require("../migrations/2_deploy_contracts");
const truffleAssert = require("truffle-assertions"); // npm truffle-assertions
const BigNumber = require("bignumber.js"); // npm install bignumber.js
var assert = require("assert");
const { platform } = require("os");

var EventToken = artifacts.require("../contracts/EventToken.sol");
var EventTokenMarket = artifacts.require("../contracts/EventTokenMarket.sol");
var Platform = artifacts.require("../contracts/Platform.sol");

contract("EventToken", function (accounts) {
    before(async () => {
        eventTokenInstance = await EventToken.deployed();
        eventTokenMarketInstance  = await EventTokenMarket.deployed();
        platformInstance = await Platform.deployed();
    });

    /*
        Acccount Management:

        accounts[0] == contract owner
        accounts[1] == verified seller
        accounts[2] == buyer
        accounts[3] == buyer
        accounts[4] == buyer
    */
    
    console.log("Testing EventToken contract functions");

    // Platform tries to mint token
    it("Mint Event Token as unauthorised address", async () => {
        await truffleAssert.reverts(
            eventTokenInstance.mintToken(5000000, accounts[2], {from:platformInstance.address}),
            "You do not have permission to do this"
        );
    });

    // Owner authorise platform to mint token
    it("Authorise an address to run mint function of EventToken", async () => {
        truffleAssert.eventEmitted(
            await eventTokenInstance.addAuthorisedAddress(platformInstance.address), 
            'NewAuthorisedAddress');
        assert.equal(await eventTokenInstance.checkAuthorisedAddress(platformInstance.address), true);

    });
    
    // Platform mint token for accounts[2]
    it("Mint Event Token as authorised address", async () => {
        let totalSupplyBefore = await eventTokenInstance.getCurrentSupply({from: accounts[2]});
        await eventTokenInstance.mintToken(5000000, accounts[2]);
        let totalSupplyAfter = await eventTokenInstance.getCurrentSupply({from: accounts[2]});
        let totalSupplyAdded = totalSupplyAfter - totalSupplyBefore;
        assert.equal(await eventTokenInstance.checkEventToken({from: accounts[2]}), 100);
        assert.equal(totalSupplyAdded, 100);
    });

    // Platform burn token for accounts[2]
    it("Burn Event Token", async () => {
        let totalSupplyBefore = await eventTokenInstance.getCurrentSupply({from: accounts[2]});
        await eventTokenInstance.burnToken(100, accounts[2]);
        let totalSupplyAfter = await eventTokenInstance.getCurrentSupply({from: accounts[2]});
        let totalSupplyRemoved = totalSupplyBefore - totalSupplyAfter;
        assert.equal(await eventTokenInstance.checkEventToken({from: accounts[2]}), 0);
        assert.equal(totalSupplyRemoved, 100);
    });

    

    console.log("Testing EventTokenMarket contract function");

    // Ensure EventTokenMarket have permissions to run certain functions on EventToken
    it("Authorise an address to run transferFrom function of EventToken", async () => {
        truffleAssert.eventEmitted(
            await eventTokenInstance.addAuthorisedAddress(eventTokenMarketInstance.address), 
            'NewAuthorisedAddress');
        assert.equal(await eventTokenInstance.checkAuthorisedAddress(eventTokenMarketInstance.address), true);

    });

    // Account 2 tries to list 5 tokens
    it("Listing of tokens when balance of token is less than quantity given", async () => {
        await truffleAssert.reverts(
            eventTokenMarketInstance.list(5, {from: accounts[2]}),
            "You do not have enough event tokens to sell"
        );
    });

    // Account 2 tries to list 50 tokens (100 tokens available)
    it("Listing of 50 tokens from account[2]", async () => {
        await eventTokenInstance.mintToken(5000000, accounts[2]); // This gives 100 tokens

        // Approve token
        await eventTokenInstance.approveToken(eventTokenMarketInstance.address, 50, {from: accounts[2]});
        let acc2allowance = new BigNumber(await eventTokenInstance.checkAllowance(accounts[2], eventTokenMarketInstance.address, {from: accounts[2]}));
        await assert(acc2allowance.isEqualTo(BigNumber(50)), "EventToken not approved");

        truffleAssert.eventEmitted(
            await eventTokenMarketInstance.list(50, {from: accounts[2]}), 
            'SellOrderListed',(ev) => {
                return ev.sellOrderId == 0;
            }
        );
        let userSellOrderIds = await eventTokenMarketInstance.checkCurrentSellOrder({from: accounts[2]});
        assert.equal(userSellOrderIds[0], 0);

    });

    // Account 3 tries to list 50 tokens (100 tokens available)
    it("Listing of 50 tokens from account[3]", async () => {
        await eventTokenInstance.mintToken(5000000, accounts[3]); // This gives 100 tokens
        
        // Approve token
        await eventTokenInstance.approveToken(eventTokenMarketInstance.address, 50, {from: accounts[3]});
        let acc2allowance = new BigNumber(await eventTokenInstance.checkAllowance(accounts[3], eventTokenMarketInstance.address, {from: accounts[3]}));
        await assert(acc2allowance.isEqualTo(BigNumber(50)), "EventToken not approved");

        truffleAssert.eventEmitted(
            await eventTokenMarketInstance.list(50, {from: accounts[3]}), 
            'SellOrderListed',(ev) => {
                return ev.sellOrderId == 1;
            }
        );
        let userSellOrderIds = await eventTokenMarketInstance.checkCurrentSellOrder({from: accounts[3]});
        assert.equal(userSellOrderIds[0], 1);

    });

    // Account 4 tries to purchase 150 tokens
    it("Purchase of 150 tokens from account[4] should fail due to not enough tokens", async () => {
        
        truffleAssert.reverts(
            eventTokenMarketInstance.purchaseTokens(150, {from: accounts[4], value: 1000000000}),
            "Quantity of tokens to purchase is more than total selling supply"
        );
    });

    // Account 4 tries to purchase 75 tokens but not enough eth
    it("Purchase of 100 tokens from account[4] should fail due to lack of eth", async () => {
        
        truffleAssert.reverts(
            eventTokenMarketInstance.purchaseTokens(75, {from: accounts[4], value: 1000000}),
            "You do not have enough ether to purchase tokens"
        );
    });


    // Account 4 succesfully purchase 30 tokens
    it("Purchase of 30 tokens from account[4]", async () => {
        let buyOrder = await eventTokenMarketInstance.checkCurrentPrice(30);
        let priceOfTokens = buyOrder[0] * buyOrder[1]
        let moneyToReceived = (priceOfTokens / 100) * 90
        truffleAssert.eventEmitted(
            await eventTokenMarketInstance.purchaseTokens(30, {from: accounts[4], value: priceOfTokens}), 
            'EarnedEth',(ev) => {
                return ev._seller == accounts[2] && ev.amount == moneyToReceived;
            }
        );
        let amountOfTokens = await eventTokenInstance.checkEventToken({from: accounts[4]})
        assert.equal(amountOfTokens, 30);
    });

    // Account 5 succesfully purchase 30 tokens should work with both sellers
    it("Purchase of 30 tokens from account[5]", async () => {
        let buyOrder = await eventTokenMarketInstance.checkCurrentPrice(30);
        let priceOfTokens = buyOrder[0] * buyOrder[1]
        await eventTokenMarketInstance.purchaseTokens(30, {from: accounts[5], value: priceOfTokens})
        
    });

    // Account 2 cannot delist other people order
    it("Delist of sell order 1 from account[2] should not work", async () => {
        
        truffleAssert.reverts(
            eventTokenMarketInstance.unlist(1, {from: accounts[2]}),
            "You did not list this order"
        );
    });

    // Account 3 delist sell order
    it("Delist of sellOrder from account[3] and account 6 should not be able to purchase token", async () => {
        
        truffleAssert.eventEmitted(
            await eventTokenMarketInstance.unlist(1, {from: accounts[3]}), 
            'SellOrderDelisted',(ev) => {
                return ev._seller == accounts[3] && ev.sellOrderId == 1;
            }
        );

        truffleAssert.reverts(
            eventTokenMarketInstance.purchaseTokens(10, {from: accounts[6], value: 1000000000}),
            "Quantity of tokens to purchase is more than total selling supply"
        );
        
    });

    
    it("Purchase should work even if inbetween sell orders there exist a delisted sell order", async () => {
        // Account 3 tries to list 50 tokens (50 tokens available)

        await eventTokenInstance.approveToken(eventTokenMarketInstance.address, 50, {from: accounts[3]});
        let acc2allowance = new BigNumber(await eventTokenInstance.checkAllowance(accounts[3], eventTokenMarketInstance.address, {from: accounts[3]}));
        await assert(acc2allowance.isEqualTo(BigNumber(50)), "EventToken not approved");

        truffleAssert.eventEmitted(
            await eventTokenMarketInstance.list(50, {from: accounts[3]}), 
            'SellOrderListed',(ev) => {
                return ev.sellOrderId == 2;
            }
        );
        let userSellOrderIds = await eventTokenMarketInstance.checkCurrentSellOrder({from: accounts[3]});
        assert.equal(userSellOrderIds[1], 2);
        
        // Account 3 delist order
        truffleAssert.eventEmitted(
            await eventTokenMarketInstance.unlist(2, {from: accounts[3]}), 
            'SellOrderDelisted',(ev) => {
                return ev._seller == accounts[3] && ev.sellOrderId == 2;
            }
        );
        
        // Account 3 list tokens again
        await eventTokenInstance.approveToken(eventTokenMarketInstance.address, 50, {from: accounts[3]});
        acc2allowance = new BigNumber(await eventTokenInstance.checkAllowance(accounts[3], eventTokenMarketInstance.address, {from: accounts[3]}));
        await assert(acc2allowance.isEqualTo(BigNumber(50)), "EventToken not approved");

        truffleAssert.eventEmitted(
            await eventTokenMarketInstance.list(50, {from: accounts[3]}), 
            'SellOrderListed',(ev) => {
                return ev.sellOrderId == 3;
            }
        );
        userSellOrderIds = await eventTokenMarketInstance.checkCurrentSellOrder({from: accounts[3]});
        assert.equal(userSellOrderIds[2], 3);

        // Account 6 successfully purchase order
        let buyOrder = await eventTokenMarketInstance.checkCurrentPrice(30);
        let priceOfTokens = buyOrder[0] * buyOrder[1]
        await eventTokenMarketInstance.purchaseTokens(30, {from: accounts[6], value: priceOfTokens})
        
    });

})
  