// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

import "./NodeList.sol";

contract NodeListProxy {
    address public owner;

    uint256 public currentEpoch;
    NodeList private nodeListContract;

    struct Node {
        uint256 nodeId;
        uint256 pubx;
        uint256 puby;
        string url;
    }

    event EpochChanged(uint256 oldEpoch, uint256 newEpoch);
    event NodeListContractChanged(address oldContract, address newContract);

    constructor(address nodeListContractAddress, uint256 epoch) public {
        currentEpoch = epoch;
        nodeListContract = NodeList(nodeListContractAddress);
        owner = msg.sender;
    }

    function setCurrentEpoch(uint256 _newEpoch) external onlyOwner {
        uint256 oldEpoch = currentEpoch;
        currentEpoch = _newEpoch;
        emit EpochChanged(oldEpoch, _newEpoch);
    }

    function setNodeListContract(
        address nodeListContractAddress
    ) external onlyOwner {
        require(nodeListContractAddress != address(0), "no zero address");
        address oldAddress = address(nodeListContract);
        nodeListContract = NodeList(nodeListContractAddress);
        emit NodeListContractChanged(oldAddress, nodeListContractAddress);
    }

    function getNodes(uint256 epoch) external view returns (address[] memory) {
        return nodeListContract.getNodes(epoch);
    }

    function getNodeDetails(
        address nodeAddress
    )
        external
        view
        returns (uint256 nodeId, uint256 pubx, uint256 puby, string memory url)
    {
        return nodeListContract.getNodeDetails(nodeAddress);
    }

    function getPssStatus(
        uint256 oldEpoch,
        uint256 newEpoch
    ) external view returns (uint256) {
        return nodeListContract.getPssStatus(oldEpoch, newEpoch);
    }

    function isWhitelisted(
        uint256 epoch,
        address nodeAddress
    ) external view returns (bool) {
        return nodeListContract.isWhitelisted(epoch, nodeAddress);
    }

    function getEpochInfo(
        uint256 epoch
    )
        external
        view
        returns (
            uint256 id,
            uint256 n,
            uint256 k,
            uint256 t,
            address[] memory nodeList,
            uint256 prevEpoch,
            uint256 nextEpoch
        )
    {
        return nodeListContract.getEpochInfo(epoch);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
}
