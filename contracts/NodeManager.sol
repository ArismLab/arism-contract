// SPDX-License-Identifier: MIT

pragma solidity ^0.8.25;

import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {AccessControlUpgradeable} from "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import {EIP712Upgradeable} from "@openzeppelin/contracts-upgradeable/utils/cryptography/EIP712Upgradeable.sol";
import {ReentrancyGuardUpgradeable} from "@openzeppelin/contracts-upgradeable/utils/ReentrancyGuardUpgradeable.sol";

import {TransferToken} from "./libs/TransferToken.sol";
import {StakeNode} from "./internals/StakeNode.sol";
import {FeeManager} from "./internals/FeeManager.sol";

import {LibRoles} from "./constants/RoleConstants.sol";

contract NodeManagerUpdradeable is
    Initializable,
    UUPSUpgradeable,
    AccessControlUpgradeable,
    EIP712Upgradeable,
    ReentrancyGuardUpgradeable,
    StakeNode,
    FeeManager
{
    constructor() {
        _disableInitializers();
    }

    function initialize(
        string memory _name,
        string memory _version,
        address _admin,
        address _operator,
        address _currency,
        uint256 _threshold,
        uint256 _voteThreshold,
        uint256 _feePerHour
    ) public initializer {
        __AccessControl_init();
        __UUPSUpgradeable_init();
        __ReentrancyGuard_init();
        __EIP712_init(_name, _version);

        _grantRole(DEFAULT_ADMIN_ROLE, _admin);
        _grantRole(LibRoles.OPERATOR_ROLE, _operator);
        _grantRole(LibRoles.CURRENCY_ROLE, _currency);
        currency = _currency;

        _updateThreshold(_threshold);
        _updateVoteThreshold(_voteThreshold);
        _setFeePerDay(_feePerHour);
    }

    address currency;

    function _authorizeUpgrade(
        address newImplementation
    ) internal override onlyRole(DEFAULT_ADMIN_ROLE) {}

    // StakeNode

    function setWhitelist(
        address nodeAddress,
        bool status
    ) external onlyRole(LibRoles.OPERATOR_ROLE) {
        whitelist[nodeAddress] = status;
    }

    function updateThreshold(
        uint256 _threshold
    ) external onlyRole(LibRoles.OPERATOR_ROLE) {
        _updateThreshold(_threshold);
    }

    function updateVoteThreshold(
        uint256 _voteThreshold
    ) external onlyRole(LibRoles.OPERATOR_ROLE) {
        _updateVoteThreshold(_voteThreshold);
    }

    function listNode(
        address nodeAddress,
        uint256 amount,
        uint256 time,
        string memory endpoint
    ) external {
        TransferToken.transferERC20From(
            currency,
            msg.sender,
            address(this),
            amount
        );
        _listNode(nodeAddress, amount, time, endpoint);
    }

    function setFeePerHour(
        uint256 _feePerHour
    ) external onlyRole(LibRoles.OPERATOR_ROLE) {
        _setFeePerDay(_feePerHour);
    }

    function listNetwork() external onlyRole(LibRoles.OPERATOR_ROLE) {
        _listNetwork();
    }

    function unStake(address nodeAddress) external {
        NodeDetail memory node = _unListNodes(nodeAddress);
        uint totalFee = getFee(node.time);

        TransferToken.transferERC20(
            currency,
            nodeAddress,
            node.amount + totalFee
        );
    }

    function voteRemoveNode(address nodeAddress) external {
        _voteRemoveNode(nodeAddress);
    }

    receive() external payable {}
}
