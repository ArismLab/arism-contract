// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

contract Network {
    address public owner;

    constructor(address _armToken) {
        owner = msg.sender;
        armToken = IERC20(_armToken);
    }

    IERC20 public armToken;

    struct StakeInfo {
        address staker;
        uint256 amount;
        uint256 lockTime;
    }
    StakeInfo[] public stakeInfo;

    function setTotalSupply(uint256 amount) external {
        require(msg.sender == owner, "Not owner");
        armToken.approve(address(this), amount);
    }

    function stakeARM(uint256 amount) external {
        require(
            armToken.transferFrom(msg.sender, address(this), amount),
            "Transfer failed"
        );
        stakeInfo.push(
            StakeInfo({
                staker: msg.sender,
                amount: amount,
                lockTime: block.timestamp
            })
        );
    }

    function rewardFromStake(uint256 index) external {
        StakeInfo storage stake = stakeInfo[index];
        require(stake.staker == msg.sender, "Not staker");
        require(
            block.timestamp - stake.lockTime > 1 days,
            "Lock time not passed"
        );
        armToken.transfer(msg.sender, stake.amount);
        delete stakeInfo[index];
    }
}

interface IERC20 {
    function transfer(
        address recipient,
        uint256 amount
    ) external returns (bool);

    function balanceOf(address account) external view returns (uint256);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    function approve(address spender, uint256 amount) external returns (bool);

    function allowance(
        address owner,
        address spender
    ) external view returns (uint256);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}
