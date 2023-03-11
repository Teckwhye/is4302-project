const Event = artifacts.require("Event");

module.exports = (deployer, network, account) => {
    deployer.deploy(Event);
};
