pragma solidity ^0.5.0;
pragma experimental ABIEncoderV2;

import "./EventToken.sol";

contract EventTokenMarketAlgorithm {


    /**
     * sellOrder Object that keep track of seller and quantity of token per order
     *
     * param seller    address of token seller
     * param quantity  amount of token to sell
     *
     */
    struct sellOrder {
        address seller;
        uint256 quantity;
    }

    address eventTokenMarketAddress;
    EventToken eventTokenContract; 
    uint256 sellOrderFirstNum;                                       // Keep track of first sell order
    uint256 sellOrderLastNum;                                        // Keep track of last sell order
    uint256 currentSellQuantity;
    mapping(uint256 => sellOrder) sellOrderList;
    



    /**
     * creates EventTokenMarketAlgorithm to maintain order of market
     *
     * param _eventTokenMarketAddress    address of event token market for sale of tokens
     * param eventTokenAddress           address of event token to check current supply to decide price of tokens     
     */
    constructor(address _eventTokenMarketAddress, EventToken eventTokenAddress) public {
        sellOrderFirstNum = 0;
        sellOrderLastNum = 0;
        currentSellQuantity = 0;
        eventTokenMarketAddress = _eventTokenMarketAddress;
        eventTokenContract = eventTokenAddress;
    }

    // modifier to ensure only token market can do this
    modifier onlyEventTokenMarketAddress() {
        require(msg.sender == eventTokenMarketAddress, "You are not allowed to do this");
        _;
    }

    /**
     * All checks to be done on EventTokenMarket
     * add sell order to queue
     *
     * param _seller address of seller of tokens
     * param _quantity amount of tokens to sell
     */
    function addSellOrder(address _seller, uint256 _quantity) onlyEventTokenMarketAddress public returns (uint256) {
        
        // Get order id
        uint256 sellOrderId = sellOrderLastNum;
        // Create market order
        sellOrder memory newSellOrder = sellOrder(_seller, _quantity);
        // List order
        sellOrderList[sellOrderId] = newSellOrder;
        // Add total sell quantity
        currentSellQuantity = currentSellQuantity + _quantity;
        // Increment number for next order id
        sellOrderLastNum = sellOrderLastNum + 1;
        // Return order id
        return sellOrderId;
    }

    /**
     * All checks to be done on EventTokenMarket
     * remove sell order
     *
     * param sellOrderId id of sell order to remove
     */
    function removeSellOrder(uint256 sellOrderId) onlyEventTokenMarketAddress public returns (uint256) {
        
        // Save old quantity
        uint256 amountOfTokens = sellOrderList[sellOrderId].quantity;
        currentSellQuantity -= amountOfTokens;
        // Remove quantity
        sellOrderList[sellOrderId].quantity = 0;
        return amountOfTokens;
    }

    /**
     * All checks to be done on EventTokenMarket, ensure that no one will buy more than what is avaiable.
     * buy tokens
     *
     * param sellOrderId id of sell order to remove
     */
    function buyTokens(uint256[2] memory order)  public returns (uint256[] memory, address[] memory, uint256){

        uint256 quantityToBuy = order[0];
        uint256[] memory quantities = new uint256[](10);
        address[] memory sellers = new address[](10);
        uint256 startnum = 0;
        while (sellOrderFirstNum < sellOrderLastNum && quantityToBuy > 0) { // There is still tokens to sell
             uint256 quantityAvailable = sellOrderList[sellOrderFirstNum].quantity;
            if (quantityAvailable > quantityToBuy) { // Seller have leftover tokens
                quantities[startnum] = quantityToBuy; 
                sellers[startnum] = sellOrderList[sellOrderFirstNum].seller;
                sellOrderList[sellOrderFirstNum].quantity = sellOrderList[sellOrderFirstNum].quantity - quantityToBuy;
                currentSellQuantity -= quantityToBuy;
                break;
            } 
            else { // Seller sells everything
                if (quantityAvailable == 0) { // Check if no quantity
                    sellOrderFirstNum = sellOrderFirstNum + 1;
                    continue;
                }
                quantityToBuy = quantityToBuy - quantityAvailable; // Update total quantity to buy
                quantities[startnum] = quantityAvailable; // Seller sold quantityAvailable
                sellers[startnum] = sellOrderList[sellOrderFirstNum].seller; // Who is the seller
                sellOrderList[sellOrderFirstNum].quantity = 0; // Seller have no more tokens
                startnum = startnum + 1; // increment to add new seller
                sellOrderFirstNum = sellOrderFirstNum + 1;
                currentSellQuantity -= quantityAvailable;
            }
        }
        startnum += 1;
        return (quantities, sellers, startnum);
    }

    /**
     * decide price of tokens (Can brainstorm the algorithm, just a sample one for now)
     *
     * param quantity of tokens to sell
     * returns price and token quantity
     */
    function getPriceOfBuyOrder(uint256 _quantity) public view returns (uint256[2] memory) {
        uint256[2] memory order;
        if (currentSellQuantity == 0) {
            order = [uint256(0),0];
            return order;
        }
        uint256 basePriceOfToken = eventTokenContract.getBasePriceOfToken();
        uint256 buyQuantity = _quantity;
        
        // How many percentage of token is buyer buying from the sale market? 
        if (_quantity >= currentSellQuantity) {
            buyQuantity = currentSellQuantity;
        }
        uint256 percentageOfSaleMarket = (((buyQuantity * 100) -1) / currentSellQuantity ); // Every percentage of market will increase price of token by 10000
        uint256 priceOfEachToken = basePriceOfToken + (10000 * percentageOfSaleMarket);
        order = [buyQuantity, priceOfEachToken];
        return order;
    }

    /**
     * check if sell order belongs to address
     *
     * param _address address to check
     * param sellOrderId id of sell order to check
     */
    function isSellOrderSeller(address _address, uint256 sellOrderId) public view returns (bool) {
        return sellOrderList[sellOrderId].seller == _address;
    }

    /**
     * check current sell quantity in market
     *
     */
    function getCurrentSellQuantity() public view returns (uint256) {
        return currentSellQuantity;
    }
    
    
}
