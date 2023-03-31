const _deploy_contracts = require("../migrations/2_deploy_contracts");
const truffleAssert = require("truffle-assertions"); // npm truffle-assertions
const BigNumber = require("bignumber.js"); // npm install bignumber.js
var assert = require("assert");

var Platform = artifacts.require("../contracts/Platform.sol");
var Account = artifacts.require("../contracts/Account.sol");
let accountOwner;
let platformOwner;
contract("AccountVerification", function (accounts) {
    before(async () => {
        accountInstance = await Account.deployed();
        platformInstance = await Platform.deployed();
    });
    
    console.log("Testing Account Verification");

    it("Verifier is not certified", async () => {
        await truffleAssert.reverts(
            accountInstance.verifyAccount(accounts[6], {from: accounts[5]}),
            "Account not certified"
        );
    });

    it("Account is certified to vote", async () => {
        // make account[0] certified to verify organisations
        let certify = await accountInstance.certifyAccount(accounts[0]);

        // Set account[1] to be verified using account[0]
        let verifyAccount5 = await accountInstance.verifyAccount(accounts[1], {from: accounts[0]});
        assert(await accountInstance.viewAccountState(accounts[1]), await accountInstance.getVerifiedStatus() );
        assert(await accountInstance.viewAccountVerifier(accounts[1]), accounts[0]);
    });

    it("Revoking permission an account", async () => {
        // make account[0] certified to verify organisations
        let certify = await accountInstance.uncertifyAccount(accounts[0]);

        // account[0] should not be able to verify accounts
        await truffleAssert.reverts(
            accountInstance.verifyAccount(accounts[1], {from: accounts[0]}),
            "Account not certified"
        );
    });

            

})