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

    struct Node {
        uint256 nodeId;
        uint256 pubx;
        uint256 puby;
        string url;
    }

    mapping(address => Node) public nodeDetails;
    mapping(address => bool) public whitelist;
    mapping(address => StakeInfo) public stakeInfo;

    function stakeARM(uint256 amount) external {
        require(
            transferFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );
        stakeInfo[msg.sender] = StakeInfo({
            amount: amount,
            lockTime: block.timestamp
        });
    }

    function rewardFromStake() external {
        require(stakeInfo[msg.sender].amount > 0, "No stake found");
        require(
            block.timestamp - stakeInfo[msg.sender].lockTime > 1 days,
            "Stake is locked"
        );
        uint256 reward = stakeInfo[msg.sender].amount / 10;
        _transfer(address(this), msg.sender, reward);
        stakeInfo[msg.sender].lockTime = block.timestamp;
    }
}
