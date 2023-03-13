pragma solidity ^0.5.0;
//import "./Buyer.sol";
//import "./Platform.sol";

contract Seller {
    //Buyer buyerContract;
    //Platform platformContract;
    sellerStatus status;
    address _owner;
    mapping(address => uint256) eventList;

    enum sellerStatus {
        unverified,
        verified
    }

    // constructor (Buyer buyerAddr, Platform platformAddr) public {
    //     buyerContract = buyerAddr;

    //     status = sellerStatus.unverified;
    //     _owner = msg.sender;
    // }

    function checkStatus() public view returns (sellerStatus) {
        return status;
    }

    // function applyPermissionToList(Platform platformContract) public {
    //     platformContract.applyPermission(address(this));
    //     testing
    // }

    // function changeSellerStatus(Platform platformContract, sellerStatus newStatus) public view () {
    //     require(msg.sender != _owner,"Cannot change own status!");
    //     require(msg.sender == platformContract, "Only platform can change status!");
    //     status = newStatus;
    // }

    // function listEvent(uint256 eventId, address eventAddr) public view () {
    //     require(msg.sender == _owner,"Only original seller can list event.");
    //     list[eventId] = eventAddr;
    // }


}