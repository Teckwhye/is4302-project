const Event = artifacts.require("Event");
const ConcertToken = artifacts.require("ConcertToken");

module.exports = (deployer, network, account) => {
    deployer.deploy(ConcertToken);
    deployer.deploy(Event);
};
