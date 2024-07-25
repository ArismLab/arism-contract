// SPDX-License-Identifier: MIT
pragma solidity ^0.8.25;

contract StakeNode {
    struct NodeDetail {
        address nodeAddress;
        uint256 amount;
        uint256 time;
        string endpoint;
    }

    mapping(address => bool) public whitelist;
    mapping(address => bool) public voted;
    mapping(uint256 => NodeDetail) public nodes;

    mapping(address => uint256) public votes;

    NodeDetail[] public WatingList;

    NodeDetail[] public Network;

    // Threshold for the number of nodes in the network
    uint256 public threshold = 5;
    // Threshold for the number of votes required to remove a node
    uint256 public voteThreshold = 3;

    function _updateThreshold(uint256 _threshold) internal {
        threshold = _threshold;
    }
    function _updateVoteThreshold(uint256 _voteThreshold) internal {
        voteThreshold = _voteThreshold;
    }

    function _listNode(
        address nodeAddress,
        uint256 amount,
        uint256 time,
        string memory endpoint
    ) internal whitelisted(msg.sender) {
        WatingList.push(NodeDetail(nodeAddress, amount, time, endpoint));
        whitelist[nodeAddress] = true;
    }

    function _listNetwork() internal {
        uint256 length = threshold - Network.length;
        for (uint256 i = 0; i < length; i++) {
            uint256 index = random(abi.encodePacked(msg.sig)) %
                WatingList.length;
            NodeDetail memory node = WatingList[index];
            nodes[i + 1] = node;
            Network.push(node);
            WatingList[index] = WatingList[WatingList.length - 1];
            WatingList.pop();
        }
    }

    function _voteRemoveNode(
        address nodeAddress
    ) internal whitelisted(msg.sender) {
        if (voted[nodeAddress]) {
            revert("Already voted");
        }
        voted[nodeAddress] = true;
        votes[nodeAddress]++;

        if (votes[nodeAddress] >= voteThreshold) {
            for (uint256 i = 0; i < Network.length; i++) {
                if (Network[i].nodeAddress == nodeAddress) {
                    Network[i] = Network[Network.length - 1];
                    Network.pop();
                    _listNetwork();
                }
            }
        }
    }

    function getNetwork() external view returns (NodeDetail[] memory) {
        return Network;
    }

    function random(bytes memory seed) internal view returns (uint256) {
        return
            uint256(
                keccak256(
                    abi.encodePacked(seed, block.timestamp, block.gaslimit)
                )
            );
    }

    modifier whitelisted(address nodeAdress) {
        if (!whitelist[nodeAdress]) {
            revert("Node is not whitelisted");
        }
        _;
    }
}
