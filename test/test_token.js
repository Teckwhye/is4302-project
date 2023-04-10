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

    // Owner authorise platform
    it("Authorise an address to run authorised function of EventToken", async () => {
        truffleAssert.eventEmitted(
            await eventTokenInstance.addAuthorisedAddress(platformInstance.address), 
            'NewAuthorisedAddress');
        assert.equal(await eventTokenInstance.checkAuthorisedAddress(platformInstance.address), true);

    });
    
    // Test mint token for accounts[2]
    it("Mint Event Token as authorised address", async () => {
        let totalSupplyBefore = await eventTokenInstance.getCurrentSupply({from: accounts[2]});
        // Base price of tokens = 50,000
        // Minting is based on 5% of ticket's price divided by 50,000 wei which in this example is 100 tokens
        await eventTokenInstance.mintToken(5000000, accounts[2]);
        let totalSupplyAfter = await eventTokenInstance.getCurrentSupply({from: accounts[2]});
        let totalSupplyAdded = totalSupplyAfter - totalSupplyBefore;
        assert.equal(await eventTokenInstance.checkEventToken({from: accounts[2]}), 100);
        assert.equal(totalSupplyAdded, 100);
    });

    // Burn token for accounts[2]
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
        await eventTokenInstance.mintToken(5000000, accounts[2]); // This gives 100 tokens to account 2

        // Listing of tokens will emit sellOrderId which is used for tracking Buyer's sell order
        truffleAssert.eventEmitted(
            await eventTokenMarketInstance.list(50, {from: accounts[2]}), 
            'SellOrderListed',(ev) => {
                return ev.sellOrderId == 0;
            }
        );
        // Getting history of buyer's sell order
        let userSellOrderIds = await eventTokenMarketInstance.checkCurrentSellOrder({from: accounts[2]});

        // Check if first result is the same as event emitted to ensure it is listed
        assert.equal(userSellOrderIds[0], 0);

    });

    // Account 3 tries to list 50 tokens (100 tokens available)
    it("Listing of 50 tokens from account[3]", async () => {
        await eventTokenInstance.mintToken(5000000, accounts[3]); // This gives 100 tokens account 3

        // Sell order should increment
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
        // Check price of 30 tokens
        let buyOrder = await eventTokenMarketInstance.checkCurrentPrice(30);
        // Check if algorithm price is correct as total 30% of the selling quantity is purchased
        // Every addtional 1% of market will increase price of each token by 10,000 which first percent is only base price
        // 29 * 10,000 + 50,000 = 340,000
        assert.equal(buyOrder[1], 340000); 
        // index 0 is buy quantity and index 1 is the price of each tokens
        let priceOfTokens = buyOrder[0] * buyOrder[1];
        // Because market takes 10% comission fee
        let moneyToReceived = (priceOfTokens / 100) * 90;

        // Check before balance
        let initialbalance4 = new BigNumber(await web3.eth.getBalance(accounts[4]));
        let initialbalance2 = new BigNumber(await web3.eth.getBalance(accounts[2]));

        // Purchase ticket
        let purchaseToken = await eventTokenMarketInstance.purchaseTokens(30, {from: accounts[4], value: 100000000000})
        truffleAssert.eventEmitted(
            purchaseToken, 
            'EarnedEth',(ev) => {
                return ev._seller == accounts[2] && ev.amount == moneyToReceived;
            }
        );

        // Check if account 2 recieved the eth
        let afterbalance2 = new BigNumber(await web3.eth.getBalance(accounts[2]));
        assert.equal(moneyToReceived, afterbalance2.minus(initialbalance2));
        
        // Calculate tx fee
        let gasUsed = new BigNumber(purchaseToken.receipt.gasUsed);
        let tx = await web3.eth.getTransaction(purchaseToken.tx);
        let transactionFee =  BigNumber(tx.gasPrice).multipliedBy(gasUsed);
        
        // Check account 4 recieved it's tokens and balance is correct
        let amountOfTokens = await eventTokenInstance.checkEventToken({from: accounts[4]});
        let afterbalance4 = new BigNumber(await web3.eth.getBalance(accounts[4]));
        assert.equal(amountOfTokens, 30);
        assert.equal(priceOfTokens, initialbalance4.minus(afterbalance4).minus(transactionFee))

        // Check market have the comissionFee
        let marketBalance = new BigNumber(await web3.eth.getBalance(eventTokenMarketInstance.address));
        assert.equal(marketBalance, (priceOfTokens / 100) * 10)
    });

    // Account 4 succesfully purchase 30 tokens should work with both sellers
    it("Purchase of 30 tokens from account[4]", async () => {
        let buyOrder = await eventTokenMarketInstance.checkCurrentPrice(30);
        // Check if algorithm price is correct as total 42% of the selling quantity is purchased (30/70)
        // Every addtional 1% of market will increase price of each token by 10,000 which first percent is only base price
        // 42 * 10,000 + 50,000 = 470,000
        assert.equal(buyOrder[1], 470000);
        // index 0 is buy quantity and index 1 is the price of each tokens

        // Check before balance (Only checking if seller gets money as we already check for buyer previously)
        let initialbalance2 = new BigNumber(await web3.eth.getBalance(accounts[2]));
        let initialbalance3 = new BigNumber(await web3.eth.getBalance(accounts[3]));

        // Check buyer got the correct amount of tokens
        await eventTokenMarketInstance.purchaseTokens(30, {from: accounts[4], value: 100000000000});
        let amountOfTokens = await eventTokenInstance.checkEventToken({from: accounts[4]});
        assert.equal(amountOfTokens, 60);

        // Check if account 2 recieved the eth
        let afterbalance2 = new BigNumber(await web3.eth.getBalance(accounts[2]));
        // Should recieve price for 20 tokens
        let moneyToReceived2 = ( (20 * buyOrder[1]) / 100) * 90;
        assert.equal(moneyToReceived2, afterbalance2.minus(initialbalance2));

        // Check if account 3 recieved the eth
        let afterbalance3 = new BigNumber(await web3.eth.getBalance(accounts[3]));
        // Should recieve price for 10 tokens
        let moneyToReceived3 = ( (10 * buyOrder[1]) / 100) * 90;
        assert.equal(moneyToReceived3, afterbalance3.minus(initialbalance3));
        
    });

    // Account 2 cannot delist other people order (sellOrderId 1 belongs to account[3])
    it("Delist of sell order 1 from account[2] should not work", async () => {
        
        truffleAssert.reverts(
            eventTokenMarketInstance.unlist(1, {from: accounts[2]}),
            "You did not list this order"
        );
    });

    // Account 3 delist sell order
    it("Delist of sellOrder from account[3] and account 4 should not be able to purchase token", async () => {
        
        truffleAssert.eventEmitted(
            await eventTokenMarketInstance.unlist(1, {from: accounts[3]}), 
            'SellOrderDelisted',(ev) => {
                return ev._seller == accounts[3] && ev.sellOrderId == 1;
            }
        );

        truffleAssert.reverts(
            eventTokenMarketInstance.purchaseTokens(10, {from: accounts[4], value: 1000000000}),
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

        // Account 4 successfully purchase order
        let buyOrder = await eventTokenMarketInstance.checkCurrentPrice(30);
        let priceOfTokens = buyOrder[0] * buyOrder[1];
        await eventTokenMarketInstance.purchaseTokens(30, {from: accounts[4], value: priceOfTokens});

        let amountOfTokens = await eventTokenInstance.checkEventToken({from: accounts[4]});
        assert.equal(amountOfTokens, 90);

        // Check only left 20 tokens in sell
        assert.equal(await eventTokenMarketInstance.getCurrentSellQuantity(), 20);
        
    });

})
  