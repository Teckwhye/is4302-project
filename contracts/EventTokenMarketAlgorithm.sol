pragma solidity ^0.5.0;

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
    uint256 sellOrderFirstNum;                                       // Keep track of first order
    uint256 sellOrderLastNum;                                        // Keep track of last order
    mapping(uint256 => sellOrder) sellOrderList;
    



    /**
     * creates EventTokenMarketAlgorithm to maintain order of market
     *
     * param _eventTokenMarketAddress    address of event token market for sale of tokens     
     */
    constructor(address _eventTokenMarketAddress) public {
        sellOrderFirstNum = 0;
        sellOrderLastNum = 0;
        eventTokenMarketAddress = _eventTokenMarketAddress;
    }

    // modifier to ensure only market algorithm can do this
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
        // Remove quantity
        sellOrderList[sellOrderId].quantity = 0;
        return amountOfTokens;
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
    
}
