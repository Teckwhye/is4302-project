const Event = artifacts.require("Event");
const EventToken = artifacts.require("EventToken");
const Account = artifacts.require("Account");
const Platform = artifacts.require("Platform");

module.exports = (deployer, network, account) => {
    deployer.deploy(EventToken)
    .then(function () {
        return deployer.deploy(Event)
    })
    .then(function () {
        return deployer.deploy(Account)
    })
    .then(function () {
        return deployer.deploy(Platform, Account.address, EventToken.address, Event.address)
    })
    ;
};
