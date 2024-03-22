// SPDX-License-Identifier: UNLICENSED
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

pragma solidity ^0.8.24;

contract ARMToken is ERC20 {
    address public owner;

    constructor() ERC20("ARMToken", "ARM") {
        _mint(address(this), 1000000000000000000000000000);
        owner = msg.sender;
    }

    struct StakeInfo {
        uint256 amount;
        uint256 lockTime;
    }

    struct NodeDetail {
        uint256 nodeId;
        uint256 pubx;
        uint256 puby;
        string url;
    }

    struct Node {
        NodeDetail nodeDetails;
        StakeInfo stakeInfo;
    }

    mapping(address => Node) public mainNet;
    mapping(address => Node) public hangingNodes;

    function stake(uint256 amount) external {
        require(
            transferFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );
        hangingNodes[msg.sender].stakeInfo = StakeInfo({
            amount: amount,
            lockTime: block.timestamp
        });
    }

    function rewardFromStake() external {
        require(
            hangingNodes[msg.sender].stakeInfo.amount > 0,
            "No stake found"
        );
        require(
            block.timestamp - hangingNodes[msg.sender].stakeInfo.lockTime >
                1 days,
            "Stake is locked"
        );
        uint256 reward = hangingNodes[msg.sender].stakeInfo.amount / 10;
        _transfer(address(this), msg.sender, reward);
        hangingNodes[msg.sender].stakeInfo.lockTime = block.timestamp;
    }

    function withdrawStake() external {
        require(
            hangingNodes[msg.sender].stakeInfo.amount > 0,
            "No stake found"
        );
        require(
            block.timestamp - hangingNodes[msg.sender].stakeInfo.lockTime >
                1 days,
            "Stake is locked"
        );
        uint256 amount = hangingNodes[msg.sender].stakeInfo.amount;
        _transfer(address(this), msg.sender, amount);
        hangingNodes[msg.sender].stakeInfo.amount = 0;
    }
}
