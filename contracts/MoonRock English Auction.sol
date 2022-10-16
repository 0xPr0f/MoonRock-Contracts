//SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;

interface ITRX721 {
    function safeTransferFrom(
        address from,
        address to,
        uint256 tokenId
    ) external;

    function transferFrom(
        address,
        address,
        uint256
    ) external;
}

interface IAUCTIONFACTORY {
    function closeEnglishAuction(address _auctioncontract) external;
}

contract MoonRockEnglishAuction {
    event Start();
    event Bid(address indexed sender, uint256 amount);
    event Withdraw(address indexed bidder, uint256 amount);
    event End(address winner, uint256 amount);

    ITRX721 public nft;
    uint256 public nftId;

    address payable public seller;
    uint256 public startedAt;
    uint256 public endAt;
    bool public started;
    bool public ended;

    address public highestBidder;
    uint256 public highestBid;

    address immutable AUCTION_FACTORY;
    mapping(address => uint256) public bids;

    constructor(
        address _auction_factory,
        address _seller,
        address _nft,
        uint256 _nftId,
        uint256 _startingBid
    ) {
        nft = ITRX721(_nft);
        nftId = _nftId;
        AUCTION_FACTORY = _auction_factory;
        seller = payable(_seller);
        highestBid = _startingBid;
    }

    function start(uint256 _endDate) external {
        require(!started, "started");
        require(msg.sender == seller, "not seller");
        require(_endDate > block.timestamp, "end time is incorrect");

        nft.transferFrom(msg.sender, address(this), nftId);
        started = true;
        startedAt = block.timestamp;
        endAt = _endDate;

        emit Start();
    }

    function bid() external payable {
        require(msg.value + bids[msg.sender] > highestBid, "value < highest");
        bids[msg.sender] += msg.value;
        highestBidder = msg.sender;
        highestBid = bids[msg.sender];

        emit Bid(msg.sender, msg.value);
    }

    function withdraw() external {
        //require (highestBidder != msg.sender);
        uint256 bal = bids[msg.sender];
        bids[msg.sender] = 0;
        payable(msg.sender).transfer(bal);

        emit Withdraw(msg.sender, bal);
    }

    function end() external {
        require(started, "not started");
        require(block.timestamp >= endAt, "not ended");
        require(!ended, "ended");

        ended = true;
        if (highestBidder != address(0)) {
            nft.safeTransferFrom(address(this), highestBidder, nftId);
            seller.transfer(highestBid);
        } else {
            nft.safeTransferFrom(address(this), seller, nftId);
        }
        IAUCTIONFACTORY(AUCTION_FACTORY).closeEnglishAuction(address(this));
        emit End(highestBidder, highestBid);
    }

    function destroy() external {
        require(msg.sender == seller, "has to be owner");
        selfdestruct(seller);
    }
}
