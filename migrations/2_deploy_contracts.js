const Event = artifacts.require("Event");
const EventToken = artifacts.require("EventToken");

module.exports = (deployer, network, account) => {
    deployer.deploy(EventToken);
    deployer.deploy(Event);
};
