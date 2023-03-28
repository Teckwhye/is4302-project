pragma solidity ^0.5.0;
import "./EventToken.sol";
import "./EventTokenMarketAlgorithm.sol";

contract EventTokenMarket {

   EventToken eventTokenContract;                        // Our event token contract
   EventTokenMarketAlgorithm marketAlgorithmContract;    // Our event token algorithm contract
   uint256 public _comissionFeePercentage;               // What is the comission fee
   address _owner = msg.sender;                          // Owner of event token market
   mapping(address => uint256[]) usersCurrentListing;     // Save history of user listing

   event SellOrderListed(uint256 orderId, address _seller, uint256 _quantity);
   event SellOrderDelisted(address _seller, uint256 sellOrderId);

   modifier onlyOwner() {
         require(msg.sender == _owner, "You do not have permission to do this");
         _;
   }

   constructor(EventToken eventTokenAddress, uint256 comissionFeePercentage) public {
        eventTokenContract = eventTokenAddress;
        marketAlgorithmContract = new EventTokenMarketAlgorithm(address(this));
        // Comission fee should be only from 1-100
        require(comissionFeePercentage > 0 && comissionFeePercentage < 101, "Comission Fee can only be from 1-100");
        _comissionFeePercentage = comissionFeePercentage;
   }

   /**
     * Calculate comission fee based on comissionFeePercentage
     *
     * param purchase price of token
     * 
     */
   function getComissionFee(uint256 purchasePrice) public view returns(uint256){
      uint256 comissionFee = (purchasePrice / 100) * _comissionFeePercentage;
      return comissionFee;
   }

   /**
     * Allow user to list tokens to sell. Token price will be based on algo thus user can only list the amount of quantity.
     *
     * param amount of tokens to list
     * 
     */
   function list(uint256 _quantity) public {
      require(eventTokenContract.checkEventTokenOf(msg.sender) >= _quantity, "You do not have enough event tokens to sell");
      eventTokenContract.transferFrom(msg.sender, address(this), _quantity);
      uint256 sellOrderID = marketAlgorithmContract.addSellOrder(msg.sender, _quantity);
      usersCurrentListing[msg.sender].push(sellOrderID);
      emit SellOrderListed(sellOrderID, msg.sender, _quantity);
   }

   /**
     * Allow user to delist tokens to sell.
     *
     * param sell order id to delist
     * 
     */
   function unlist(uint256 sellOrderId) public {
      require(marketAlgorithmContract.isSellOrderSeller(msg.sender, sellOrderId), "You did not list this order");
      uint256 amountOfTokens = marketAlgorithmContract.removeSellOrder(sellOrderId);
      eventTokenContract.transferFrom(address(this), msg.sender, amountOfTokens);
      emit SellOrderDelisted(msg.sender, sellOrderId);
   }

   function checkCurrentSellOrder() public view returns(uint256[] memory) {
      return usersCurrentListing[msg.sender];
   }

   function getContractOwner() public view returns(address) {
      return _owner;
   }

}
