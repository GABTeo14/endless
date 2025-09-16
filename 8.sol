// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @notice Very small ERC-721 style NFT (educational, not fully OZ-compliant)
contract SimpleERC721 {
    string public name = "MiniNFT";
    string public symbol = "MNFT";

    mapping(uint256 => address) private _ownerOf;
    mapping(address => uint256) private _balanceOf;
    mapping(uint256 => address) private _approvals;
    mapping(address => mapping(address => bool)) private _operatorApprovals;

    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event Approval(address indexed owner, address indexed approved, uint256 indexed tokenId);

    function ownerOf(uint256 tokenId) public view returns (address) {
        address owner = _ownerOf[tokenId];
        require(owner != address(0), "nonexistent");
        return owner;
    }

    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0), "zero");
        return _balanceOf[owner];
    }

    function _mint(address to, uint256 tokenId) internal {
        require(to != address(0), "zero");
        require(_ownerOf[tokenId] == address(0), "exists");
        _ownerOf[tokenId] = to;
        _balanceOf[to] += 1;
        emit Transfer(address(0), to, tokenId);
    }

    function mintTo(address to, uint256 tokenId) external {
        _mint(to, tokenId);
    }

    function transferFrom(address from, address to, uint256 tokenId) public {
        require(_ownerOf[tokenId] == from, "not owner");
        require(msg.sender == from || msg.sender == _approvals[tokenId] || _operatorApprovals[from][msg.sender], "not approved");
        require(to != address(0), "zero");
        // clear approvals
        _approvals[tokenId] = address(0);
        _ownerOf[tokenId] = to;
        _balanceOf[from] -= 1;
        _balanceOf[to] += 1;
        emit Transfer(from, to, tokenId);
    }

    function approve(address to, uint256 tokenId) external {
        address owner = ownerOf(tokenId);
        require(msg.sender == owner, "not owner");
        _approvals[tokenId] = to;
        emit Approval(owner, to, tokenId);
    }
}
