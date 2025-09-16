// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @notice Minimal multi-signature wallet
contract MultiSigWallet {
    address[] public owners;
    mapping(address => bool) public isOwner;
    uint256 public required;

    struct Tx {
        address to;
        uint256 value;
        bytes data;
        bool executed;
        uint256 confirmations;
    }

    Tx[] public transactions;
    mapping(uint256 => mapping(address => bool)) public confirmed;

    event SubmitTx(uint256 indexed txId, address indexed to, uint256 value);
    event ConfirmTx(uint256 indexed txId, address indexed owner);
    event ExecuteTx(uint256 indexed txId);

    modifier onlyOwner() { require(isOwner[msg.sender], "only owner"); _; }

    constructor(address[] memory _owners, uint256 _required) {
        require(_owners.length > 0, "owners required");
        require(_required > 0 && _required <= _owners.length, "invalid required");
        for (uint i=0;i<_owners.length;i++){
            address o = _owners[i];
            require(o != address(0), "zero owner");
            require(!isOwner[o], "duplicate owner");
            isOwner[o] = true;
            owners.push(o);
        }
        required = _required;
    }

    receive() external payable {}

    function submitTransaction(address to, uint256 value, bytes calldata data) external onlyOwner returns (uint256) {
        transactions.push(Tx({to: to, value: value, data: data, executed: false, confirmations: 0}));
        uint256 txId = transactions.length - 1;
        emit SubmitTx(txId, to, value);
        return txId;
    }

    function confirmTransaction(uint256 txId) external onlyOwner {
        require(txId < transactions.length, "no tx");
        require(!confirmed[txId][msg.sender], "already confirmed");
        confirmed[txId][msg.sender] = true;
        transactions[txId].confirmations += 1;
        emit ConfirmTx(txId, msg.sender);
    }

    function executeTransaction(uint256 txId) external onlyOwner {
        Tx storage t = transactions[txId];
        require(!t.executed, "already");
        require(t.confirmations >= required, "not enough confirmations");
        t.executed = true;
        (bool ok, ) = t.to.call{value: t.value}(t.data);
        require(ok, "tx failed");
        emit ExecuteTx(txId);
    }

    // helper getters
    function getOwners() external view returns (address[] memory) { return owners; }
    function getTransactionCount() external view returns (uint256) { return transactions.length; }
}
