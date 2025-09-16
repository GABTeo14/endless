// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @notice Simple ERC721 with tokenURI mapping, owner-only baseURI control
contract NFTWithMetadata {
    string public name = "MetaNFT";
    string public symbol = "MNFT2";
    address public owner;
    uint256 public nextId;

    mapping(uint256 => address) public ownerOf;
    mapping(address => uint256) public balanceOf;
    mapping(uint256 => string) private _tokenURIs;

    event Transfer(address indexed from, address indexed to, uint256 indexed id);
    event Mint(address indexed to, uint256 indexed id);

    modifier onlyOwner() { require(msg.sender == owner, "only owner"); _; }

    constructor() {
        owner = msg.sender;
        nextId = 1;
    }

    function _mint(address to, string memory uri) internal returns (uint256) {
        uint256 id = nextId++;
        ownerOf[id] = to;
        balanceOf[to] += 1;
        _tokenURIs[id] = uri;
        emit Mint(to, id);
        emit Transfer(address(0), to, id);
        return id;
    }

    function mint(string calldata uri) external returns (uint256) {
        // anyone can mint in this example; change to onlyOwner() if desired
        return _mint(msg.sender, uri);
    }

    function tokenURI(uint256 id) public view returns (string memory) {
        require(ownerOf[id] != address(0), "no token");
        return _tokenURIs[id];
    }

    function transfer(address to, uint256 id) external {
        address from = msg.sender;
        require(ownerOf[id] == from, "not owner");
        require(to != address(0), "zero");
        ownerOf[id] = to;
        balanceOf[from] -= 1;
        balanceOf[to] += 1;
        emit Transfer(from, to, id);
    }
}
