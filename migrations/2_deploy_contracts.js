const Event = artifacts.require("Event");
const Ticket = artifacts.require("Ticket");
const EventToken = artifacts.require("EventToken");

module.exports = (deployer, network, account) => {
    deployer
        .deploy(Ticket)
        .then(function () {
            return deployer.deploy(Event, Ticket.address);
        })
        .then (function() {
            return deployer.deploy(EventToken);
        });
};
