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
        accountOwner = accounts[0];
        platformOwner = accounts[1];
        accountInstance = await Account.deployed({from:accountOwner});
        platformInstance = await Platform.deployed({from:platformOwner});
    });
    
    console.log("Testing Account Verification");

    it("Verifier is not certified", async () => {
        await truffleAssert.reverts(
            platformInstance.verifyAccount(accounts[6], {from: accounts[5]}),
            "Account not certified"
        );
    });

    it("Ensure Platform can verify accounts (for listing event)", async () => {
        // make platform contract a certfied party
        let setPlatformAddr = await accountInstance.setPlatformAddress(platformOwner);
        let certifyPlatform = await accountInstance.certifyAccount(platformOwner);

        // Set account 5 to be verified first using account contract called by platform contract
        let verifyAccount5 = await accountInstance.verifyAccount(accounts[5], platformOwner, {from: platformOwner});
        assert(await accountInstance.viewAccountState(accounts[5]), await accountInstance.getVerifiedStatus() );
        assert(await accountInstance.viewAccountVerifier(accounts[5]), platformOwner );
    });

            

})