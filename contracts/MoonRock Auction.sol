//SPDX-License-Identifier: MIT
pragma solidity ^0.8.6;
import "./MoonRock English Auction.sol";
import "./MoonRock Dutch Auction.sol";

contract MoonRockAuctionFactory {
    event createEnglishAuctionContract(
        address _newEnglishAuctionContract,
        address _auctionNftcontractaddress,
        uint256 _auctionNftTokenId,
        address _owner,
        uint256 _startingBid,
        uint256 _timeCreated
    );
    event createDutchAuctionContract(
        address _newDutchAuctionContract,
        address _auctionNftcontractaddress,
        uint256 _auctionNftTokenId,
        address _owner,
        uint256 _startingPrice,
        uint256 _discountRate,
        uint256 _timeCreated
    );
    enum AuctionState {
        open,
        closed
    }
    EnglishAuctionItem[] activeEnglishAuctionList;

    struct EnglishAuctionItem {
        address _auctionContract;
        string _name;
        address _owner;
        address _auctionNftcontractaddress;
        uint256 _startingBid;
        uint256 _creationTime;
        AuctionState _auctionState;
    }

    struct DutchAuctionItem {
        address _auctionContract;
        string _name;
        address _owner;
        address _auctionNftcontractaddress;
        uint256 _startingPrice;
        uint256 _discountRate;
        uint256 _creationTime;
        AuctionState _auctionState;
    }

    EnglishAuctionItem[] public englishAuctionList;
    //EnglishAuctionItem[] public _activeEnglishAuctionList;

    DutchAuctionItem[] public dutchAuctionList;

    function createEnglishAuction(
        string calldata _name,
        address _nftaddress,
        uint256 _nfttokenId,
        uint256 _startingBid
    ) external {
        MoonRockEnglishAuction englishAuction = new MoonRockEnglishAuction(
            address(this),
            msg.sender,
            _nftaddress,
            _nfttokenId,
            _startingBid
        );

        EnglishAuctionItem memory _auctionItems = EnglishAuctionItem(
            address(englishAuction),
            _name,
            msg.sender,
            _nftaddress,
            _startingBid,
            block.timestamp,
            AuctionState.open
        );

        englishAuctionList.push(_auctionItems);
        emit createEnglishAuctionContract(
            address(englishAuction),
            _nftaddress,
            _nfttokenId,
            msg.sender,
            _startingBid,
            block.timestamp
        );
    }

    function createDutchAuction(
        string calldata _name,
        uint256 _startingPrice,
        uint256 _discountRate,
        address _nftaddress,
        uint256 _nfttokenId
    ) external {
        MoonRockDutchAuction dutchAuction = new MoonRockDutchAuction(
            address(this),
            msg.sender,
            _startingPrice,
            _discountRate,
            _nftaddress,
            _nfttokenId
        );

        DutchAuctionItem memory _auctionItems = DutchAuctionItem(
            address(dutchAuction),
            _name,
            msg.sender,
            _nftaddress,
            _startingPrice,
            _discountRate,
            block.timestamp,
            AuctionState.open
        );

        dutchAuctionList.push(_auctionItems);
        emit createDutchAuctionContract(
            address(dutchAuction),
            _nftaddress,
            _nfttokenId,
            msg.sender,
            _startingPrice,
            _discountRate,
            block.timestamp
        );
    }

    function closeEnglishAuction(address _auctioncontract) external {
        uint256 _englishAuctionListLength = englishAuctionList.length;
        require(
            msg.sender == _auctioncontract,
            "closeauction must be called fron the auction contract"
        );
        for (uint256 i = 0; i <= _englishAuctionListLength; ++i) {
            if (englishAuctionList[i]._auctionContract == _auctioncontract) {
                englishAuctionList[i]._auctionState = AuctionState.closed;
            }
        }
    }

    function closeDutchAuction(address _auctioncontract) external {
        uint256 _dutchAuctionListLength = dutchAuctionList.length;
        require(
            msg.sender == _auctioncontract,
            "closeauction must be called fron the auction contract"
        );
        for (uint256 i = 0; i <= _dutchAuctionListLength; ++i) {
            if (dutchAuctionList[i]._auctionContract == _auctioncontract) {
                dutchAuctionList[i]._auctionState = AuctionState.closed;
            }
        }
    }

    function fetchEnglishAuctionList()
        external
        view
        returns (EnglishAuctionItem[] memory)
    {
        return englishAuctionList;
    }

    function fetchDutchAuctionList()
        external
        view
        returns (DutchAuctionItem[] memory)
    {
        return dutchAuctionList;
    }

    function fetchActiveEnglishAuctionList()
        external
        view
        returns (EnglishAuctionItem[] memory)
    {
        uint256 counter = 0;
        uint256 _englishAuctionListLength = englishAuctionList.length;
        EnglishAuctionItem[]
            memory _activeEnglishAuctionList = new EnglishAuctionItem[](
                _englishAuctionListLength
            );
        for (uint256 i = 0; i <= _englishAuctionListLength; ++i) {
            ++counter;
            if (englishAuctionList[i]._auctionState == AuctionState.open) {
                _activeEnglishAuctionList[counter] = englishAuctionList[i];
            }
        }
        return _activeEnglishAuctionList;
    }

    function fetchActiveDutchAuctionList()
        external
        view
        returns (DutchAuctionItem[] memory)
    {
        uint256 counter = 0;
        uint256 _dutchAuctionListLength = dutchAuctionList.length;
        DutchAuctionItem[]
            memory _activeDutchAuctionList = new DutchAuctionItem[](
                _dutchAuctionListLength
            );
        for (uint256 i = 0; i <= _dutchAuctionListLength; ++i) {
            ++counter;
            if (englishAuctionList[i]._auctionState == AuctionState.open) {
                _activeDutchAuctionList[counter] = dutchAuctionList[i];
            }
        }
        return _activeDutchAuctionList;
    }

    function fetchClosedEnglishAuctionList()
        external
        view
        returns (EnglishAuctionItem[] memory)
    {
        uint256 counter = 0;
        uint256 _englishAuctionListLength = englishAuctionList.length;
        EnglishAuctionItem[]
            memory _closedEnglishAuctionList = new EnglishAuctionItem[](
                _englishAuctionListLength
            );
        for (uint256 i = 0; i <= _englishAuctionListLength; ++i) {
            ++counter;
            if (englishAuctionList[i]._auctionState == AuctionState.closed) {
                _closedEnglishAuctionList[counter] = englishAuctionList[i];
            }
        }
        return _closedEnglishAuctionList;
    }
}
