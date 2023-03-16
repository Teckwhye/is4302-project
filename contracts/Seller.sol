pragma solidity ^0.5.0;

import "./Account.sol";

contract Seller {
    Account accountContract;
    mapping(uint256 => address) eventList; // list eventID => eventAddr

    constructor (Account accountAddr) public {
        accountContract = accountAddr;
    }
    
    modifier isSeller(address addr) {
        require(accountContract.viewAccountState() == Account.status.verified,"You're not verified as a Seller");
        _;
    }


    // function applyPermissionToList(Address sellerAddr) public {
    //     platformContract.applyPermission(sellerAddr);
    //     
    // }

    // function changeSellerStatus(Platform platformContract, sellerStatus newStatus) public view () {
    //     require(accountContract.viewAccountState() == Account.status.pending,"You've yet to apply for permission to list");
    //    
    //    
    // }

    function listEvent(uint256 eventId, address eventAddr) public isSeller( msg.sender) {
        eventList[eventId] = eventAddr;
    }


}