// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface INFT {
    function transferFrom(address from, address to, uint256 tokenId) external;
}

contract SimpleMarketplace {
    struct Listing { address seller; address nft; uint256 tokenId; uint256 price; bool active; }
    uint256 public nextListingId;
    mapping(uint256 => Listing) public listings;
    event Listed(uint256 indexed id, address seller, address nft, uint256 tokenId, uint256 price);
    event Bought(uint256 indexed id, address buyer);

    function list(address nft, uint256 tokenId, uint256 price) external returns (uint256) {
        require(price > 0, "price>0");
        uint256 id = nextListingId++;
        listings[id] = Listing({seller: msg.sender, nft: nft, tokenId: tokenId, price: price, active: true});
        // seller must transfer NFT to marketplace prior to purchase, or marketplace can pull on buy
        emit Listed(id, msg.sender, nft, tokenId, price);
        return id;
    }

    function buy(uint256 id) external payable {
        Listing storage l = listings[id];
        require(l.active, "not active");
        require(msg.value >= l.price, "not enough eth");
        l.active = false;
        payable(l.seller).transfer(l.price);
        INFT(l.nft).transferFrom(l.seller, msg.sender, l.tokenId);
        emit Bought(id, msg.sender);
        // refund extra ETH if sent more than price
        if (msg.value > l.price) {
            payable(msg.sender).transfer(msg.value - l.price);
        }
    }

    function cancel(uint256 id) external {
        Listing storage l = listings[id];
        require(l.seller == msg.sender, "only seller");
        require(l.active, "not active");
        l.active = false;
    }
}
