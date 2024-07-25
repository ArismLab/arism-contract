// SPDX-License-Identifier: MIT

pragma solidity ^0.8.25;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {EIP712Upgradeable} from "@openzeppelin/contracts-upgradeable/utils/cryptography/EIP712Upgradeable.sol";
import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

import {TransferToken} from "./internals/TransferToken.sol";
import {StakeNode} from "./internals/StakeNode.sol";

import {LibRoles} from "./constants/RoleConstants.sol";

contract NodeManagerUpdradeable is
    Initializable,
    UUPSUpgradeable,
    AccessControlUpgradeable,
    TransferToken,
    EIP712Upgradeable,
    ReentrancyGuardUpgradeable,
    StakeNode
{
    constructor() {
        _disableInitializers();
    }

    function initialize(
        string memory name,
        string memory version,
        address admin,
        address operator,
        address currency
    ) public initializer {
        __AccessControl_init();
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();
        __EIP712_init(name, version);

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(LibRoles.OPERATOR_ROLE, operator);
        _grantRole(LibRoles.CURRENCY_ROLE, currency);
    }

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(DEFAULT_ADMIN_ROLE) {}

    // StakeNode

    function updateThreshold(
        uint256 _threshold
    ) external onlyRole(LibRoles.OPERATOR_ROLE) {
        _updateThreshold(_threshold);
    }

    function listNode(
        address nodeAddress,
        uint256 amount,
        uint256 time,
        string memory endpoint
    ) external onlyRole(LibRoles.OPERATOR_ROLE) {
        _listNode(nodeAddress, amount, time, endpoint);
    }

    function listNetwork() external onlyRole(LibRoles.OPERATOR_ROLE) {
        _listNetwork();
    }
}
