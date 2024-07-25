// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

library TransferToken {
    function transferERC20(address token, address to, uint256 amount) external {
        IERC20(token).transfer(to, amount);
    }

    function transferERC20From(
        address token,
        address from,
        address to,
        uint256 amount
    ) external {
        IERC20(token).transferFrom(from, to, amount);
    }

    function transferETH(address to, uint256 amount) external {
        payable(to).transfer(amount);
    }

    function getBalance(address token) external view returns (uint256) {
        return IERC20(token).balanceOf(address(this));
    }

    function getETHBalance() external view returns (uint256) {
        return address(this).balance;
    }
}
