// SPDX-License-Identifier: MIT
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

pragma solidity ^0.8.25;

contract ARMToken is ERC20 {
    constructor() ERC20("ARMToken", "ARM") {
        _mint(msg.sender, 1000000000000000000000000);
    }
}
