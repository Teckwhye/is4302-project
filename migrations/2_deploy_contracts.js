const Event = artifacts.require("Event");
const EventToken = artifacts.require("EventToken");

module.exports = (deployer, network, account) => {
    deployer.deploy(ConcertToken);
    deployer.deploy(Event);
};
