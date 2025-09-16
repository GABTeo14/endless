// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @notice Very small governance DAO: create proposal, vote with weight = Ether staked, execute after deadline
contract SimpleDAO {
    struct Proposal {
        address target;
        bytes data;
        uint256 endTime;
        uint256 yes;
        uint256 no;
        bool executed;
    }

    Proposal[] public proposals;
    mapping(address => uint256) public stake; // stake ether to get voting weight
    mapping(uint256 => mapping(address => bool)) public voted;

    event Staked(address indexed who, uint256 amount);
    event ProposalCreated(uint256 indexed id, address target, uint256 endTime);
    event Voted(uint256 indexed id, address voter, bool support, uint256 weight);
    event Executed(uint256 indexed id);

    function stakeETH() external payable {
        require(msg.value > 0, "zero");
        stake[msg.sender] += msg.value;
        emit Staked(msg.sender, msg.value);
    }

    function createProposal(address target, bytes calldata data, uint256 durationSeconds) external returns (uint256) {
        proposals.push(Proposal({target: target, data: data, endTime: block.timestamp + durationSeconds, yes: 0, no: 0, executed: false}));
        uint256 id = proposals.length - 1;
        emit ProposalCreated(id, target, block.timestamp + durationSeconds);
        return id;
    }

    function vote(uint256 id, bool support) external {
        Proposal storage p = proposals[id];
        require(block.timestamp < p.endTime, "voting ended");
        require(!voted[id][msg.sender], "already voted");
        uint256 weight = stake[msg.sender];
        require(weight > 0, "no stake");
        voted[id][msg.sender] = true;
        if (support) p.yes += weight; else p.no += weight;
        emit Voted(id, msg.sender, support, weight);
    }

    function execute(uint256 id) external {
        Proposal storage p = proposals[id];
        require(block.timestamp >= p.endTime, "not ended");
        require(!p.executed, "already");
        require(p.yes > p.no, "not passed");
        p.executed = true;
        (bool ok,) = p.target.call{value:0}(p.data);
        require(ok, "call failed");
        emit Executed(id);
    }

    // withdraw stake (simple, no lock)
    function withdrawStake(uint256 amount) external {
        require(stake[msg.sender] >= amount, "insufficient");
        stake[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
    }

    // contract can receive ETH to fund any proposals' target calls if needed
    receive() external payable {}
}
