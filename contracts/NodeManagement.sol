// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

contract NodeManagement {
    address public owner;

    struct Node {
        address nodeAddress;
        string endpoint;
        string publicKey;
        uint8 nodeId;
        string experyDate;
    }

    Node[] public operatorsNodes;
    Node[] public backupNodes;

    uint8 public votesForRemoveNode = 0;

    mapping(address => bool) whitelist;

    constructor() {
        owner = msg.sender;
    }

    function addNode(Node node) public {
        require(msg.sender == owner, "Only owner can add node");
        backupNodes.push(node);
    }

    function voteForRemoveNode(address nodeAddress) public {
        require(backupNodes.length > 0, "No backup nodes available");
        require(whitelist[msg.sender], "Only whitelisted can vote");
        for (uint8 i = 0; i < operatorsNodes.length; i++) {
            if (operatorsNodes[i].nodeAddress == nodeAddress) {
                votesForRemoveNode++;
                break;
            }
        }
        if (votesForRemoveNode >= 3) {
            whitelist[operatorsNodes[i].nodeAddress] = false;
            delete operatorsNodes[i];
            operatorsNodes.push(backupNodes[0].nodeAddress);
            whitelist[backupNodes[0].nodeAddress] = true;
            delete backupNodes[0];
            votesForRemoveNode = 0;
        }
    }
}
