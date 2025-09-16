// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/// @notice Simple escrow: buyer deposits ETH, seller marks delivered, arbiter can resolve
contract Escrow {
    address public buyer;
    address public seller;
    address public arbiter;
    uint256 public amount;
    enum State { AWAITING_PAYMENT, AWAITING_DELIVERY, COMPLETE, REFUNDED }
    State public state;

    event Deposited(address indexed from, uint256 amount);
    event Delivered();
    event Refunded();
    event ReleasedToSeller();

    constructor(address _seller, address _arbiter) payable {
        buyer = msg.sender;
        seller = _seller;
        arbiter = _arbiter;
        state = State.AWAITING_PAYMENT;
    }

    function deposit() external payable {
        require(msg.sender == buyer, "only buyer");
        require(state == State.AWAITING_PAYMENT, "not awaiting");
        require(msg.value > 0, "zero");
        amount = msg.value;
        state = State.AWAITING_DELIVERY;
        emit Deposited(msg.sender, msg.value);
    }

    function confirmDelivery() external {
        require(msg.sender == buyer, "only buyer");
        require(state == State.AWAITING_DELIVERY, "not awaiting");
        state = State.COMPLETE;
        payable(seller).transfer(amount);
        emit ReleasedToSeller();
    }

    function refundByArbiter() external {
        require(msg.sender == arbiter, "only arbiter");
        require(state == State.AWAITING_DELIVERY, "not awaiting");
        state = State.REFUNDED;
        payable(buyer).transfer(amount);
        emit Refunded();
    }
}
