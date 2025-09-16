// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ISimpleToken {
    function transfer(address to, uint256 amount) external returns (bool);
}

contract SimpleCrowdsale {
    address public owner;
    ISimpleToken public token;
    uint256 public rate; // tokens per 1 ETH (e.g., rate = 100 -> 1 ETH = 100 tokens)
    uint256 public weiRaised;

    event Bought(address indexed buyer, uint256 weiAmount, uint256 tokenAmount);
    event WithdrawETH(address indexed to, uint256 amount);

    modifier onlyOwner() { require(msg.sender == owner, "only owner"); _; }

    constructor(address _token, uint256 _rate) {
        require(_token != address(0), "zero token");
        owner = msg.sender;
        token = ISimpleToken(_token);
        rate = _rate;
    }

    receive() external payable {
        buyTokens();
    }

    function buyTokens() public payable {
        require(msg.value > 0, "zero");
        uint256 tokens = msg.value * rate;
        weiRaised += msg.value;
        require(token.transfer(msg.sender, tokens), "token transfer fail");
        emit Bought(msg.sender, msg.value, tokens);
    }

    function withdraw() external onlyOwner {
        uint256 bal = address(this).balance;
        require(bal > 0, "no eth");
        payable(owner).transfer(bal);
        emit WithdrawETH(owner, bal);
    }
}
