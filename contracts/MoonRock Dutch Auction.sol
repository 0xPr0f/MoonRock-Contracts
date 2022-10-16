// SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

interface TRX721 {
    function transferFrom(
        address _from,
        address _to,
        uint256 _nftId
    ) external;
}

interface IAUCTION_FACTORY {
    function closeDutchAuction(address _auctioncontract) external;
}

contract MoonRockDutchAuction {
    uint256 private constant DURATION = 7 days;

    TRX721 public immutable nft;
    uint256 public immutable nftId;
    address immutable AUCTION_FACTORY;
    address payable public immutable seller;
    uint256 public immutable startingPrice;
    uint256 public immutable startAt;
    uint256 public immutable expiresAt;
    uint256 public immutable discountRate;

    constructor(
        address _auction_factory,
        address _seller,
        uint256 _startingPrice,
        uint256 _discountRate,
        address _nft,
        uint256 _nftId
    ) {
        seller = payable(_seller);
        startingPrice = _startingPrice;
        startAt = block.timestamp;
        expiresAt = block.timestamp + DURATION;
        discountRate = _discountRate;
        AUCTION_FACTORY = _auction_factory;
        require(
            _startingPrice >= _discountRate * DURATION,
            "starting price < min"
        );

        nft = TRX721(_nft);
        nftId = _nftId;
    }

    function getPrice() public view returns (uint256) {
        uint256 timeElapsed = block.timestamp - startAt;
        uint256 discount = discountRate * timeElapsed;
        return startingPrice - discount;
    }

    function buy() external payable {
        require(block.timestamp < expiresAt, "auction expired");

        uint256 price = getPrice();
        require(msg.value >= price, "TRX < price");

        nft.transferFrom(seller, msg.sender, nftId);
        uint256 refund = msg.value - price;
        if (refund > 0) {
            payable(msg.sender).transfer(refund);
        }
        seller.transfer(address(this).balance);
        IAUCTION_FACTORY(AUCTION_FACTORY).closeDutchAuction(address(this));
        //selfdestruct(seller);
    }

    function destroy() external {
        require(msg.sender == seller, "has to be owner");
        selfdestruct(seller);
    }
}
