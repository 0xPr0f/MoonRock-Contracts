//SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

interface TRXNFT {
    function balanceOf(address _owner) external view returns (uint256);

    function safeTransferFrom(
        address _from,
        address _to,
        uint256 _tokenId
    ) external payable;
}

contract MoonRockMarketplace {
    enum State {
        Created,
        Release,
        Inactive
    }

    struct MarketItem {
        address _nftcontractaddress;
        uint256 _tokenId;
        address _seller;
        uint256 _price;
        uint256 _timePlacedForSale;
        uint256 _timeSold;
        uint256 _id;
        State state;
    }
    uint256 id = 0;

    mapping(uint256 => MarketItem) private marketItems;

    event MarketSaleCreated(
        address _nftcontractaddress,
        uint256 _tokenId,
        address _seller,
        address _buyer,
        uint256 _price,
        uint256 _timePlacedForSale,
        uint256 _timeSold,
        uint256 _id,
        State _state
    );

    MarketItem[] public listOfSales;

    modifier checkIfandIfNotSold(uint256 _id) {
        require(
            marketItems[_id]._timePlacedForSale != 0,
            "NFT sale has been canceled"
        );
        require(marketItems[_id]._timeSold == 0, "NFT has been sold");
        _;
    }

    modifier checkID(uint256 _id) {
        require(_id <= id && _id != 0, "ID not found");
        _;
    }

    // call approve before this function
    function createMarketSale(
        uint256 _price,
        address _nftcontractaddress,
        uint256 _tokenId
    ) external {
        require(_price > 0, "Price must be at least 1 weitrx");

        TRXNFT(_nftcontractaddress).safeTransferFrom(
            /*_seller*/
            msg.sender,
            address(this),
            _tokenId
        );
        MarketItem memory _templistOfSales = MarketItem(
            _nftcontractaddress,
            _tokenId,
            msg.sender,
            _price,
            block.timestamp,
            0,
            ++id,
            State.Created
        );
        marketItems[id] = _templistOfSales;
        listOfSales.push(_templistOfSales);
    }

    function createMarketBuy(uint256 _id)
        external
        payable
        checkIfandIfNotSold(_id)
        checkID(_id)
    {
        (bool success, ) = msg.sender.call{value: marketItems[_id]._price}("");
        require(
            marketItems[_id].state == State.Created,
            "NFT is not open for sale"
        );
        require(success, "purchase failed");
        TRXNFT(marketItems[_id]._nftcontractaddress).safeTransferFrom(
            /*_seller*/
            address(this),
            msg.sender,
            marketItems[_id]._tokenId
        );
        marketItems[_id].state == State.Release;
    }

    function cancelMarketSale(uint256 _id)
        external
        view
        checkIfandIfNotSold(_id)
        checkID(_id)
    {
        marketItems[_id]._timePlacedForSale == 0;
        marketItems[_id].state == State.Inactive;
    }

    function fetchActiveListOfSales()
        public
        view
        returns (MarketItem[] memory)
    {
        return listOfSales;
    }

    function fetchListOfSalesByIndex(uint256 _index)
        public
        view
        returns (MarketItem memory)
    {
        return listOfSales[_index];
    }

    function fetchMyPurchasedItems()
        public
        view
        returns (MarketItem[] memory)
    {}

    function fetchMyCreatedItems() public view returns (MarketItem[] memory) {}

    /* function returnListOfSalesByID (uint _id) external view returns (MarketSale memory) {
        return listOfSales[_index];
    }
    */

    function onTRC721Received(
        address,
        address,
        uint256,
        bytes memory
    ) external pure returns (bytes4) {
        return
            bytes4(
                keccak256("onTRC721Received(address,address,uint256,bytes)")
            );
    }
}
