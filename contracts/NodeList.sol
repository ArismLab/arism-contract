// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.24;

contract NodeManagement {
    address public owner;

    constructor() {
        owner = msg.sender;
    }

    struct Node {
        uint256 nodeId;
        uint256 pubx;
        uint256 puby;
        string url;
    }
    struct Epoch {
        uint256 id;
        uint256 n;
        uint256 k;
        uint256 t;
        address[] nodeList;
        uint256 prevEpoch;
        uint256 nextEpoch;
    }
    event NodeListed(address publicKey, uint256 epoch, uint256 nodeId);

    mapping(uint256 => Epoch) public epochInfo;

    mapping(address => Node) public nodeDetails;

    mapping(uint256 => mapping(uint256 => uint256)) public pssStatus;

    mapping(uint256 => mapping(address => bool)) public whitelist;

    function listNode(
        uint256 epoch,
        uint256 pubx,
        uint256 puby,
        string memory url
    ) external whitelisted(epoch) epochValid(epoch) epochCreated(epoch) {
        require(
            !nodeRegistered(epoch, msg.sender),
            "Node is already registered"
        );
        Epoch storage epochI = epochInfo[epoch];
        epochI.nodeList.push(msg.sender);
        nodeDetails[msg.sender] = Node({
            nodeId: uint256(epochI.nodeList.length),
            pubx: pubx,
            puby: puby,
            url: url
        });
        emit NodeListed(msg.sender, epoch, epochI.nodeList.length);
    }

    function getNodes(
        uint256 epoch
    ) external view epochValid(epoch) returns (address[] memory) {
        return epochInfo[epoch].nodeList;
    }

    function getEpochInfo(
        uint256 epoch
    ) external view epochValid(epoch) returns (Epoch memory) {
        return epochInfo[epoch];
    }

    function getNodeDetails(
        address nodeAddress
    ) external view returns (Node memory) {
        return nodeDetails[nodeAddress];
    }

    function getPssStatus(
        uint256 oldEpoch,
        uint256 newEpoch
    ) external view returns (uint256) {
        return pssStatus[oldEpoch][newEpoch];
    }

    function updatePssStatus(
        uint256 oldEpoch,
        uint256 newEpoch,
        uint256 status
    ) public onlyOwner epochValid(oldEpoch) epochValid(newEpoch) {
        pssStatus[oldEpoch][newEpoch] = status;
    }

    function updateWhitelist(
        uint256 epoch,
        address nodeAddress,
        bool allowed
    ) public onlyOwner epochValid(epoch) {
        whitelist[epoch][nodeAddress] = allowed;
    }

    function updateEpoch(
        uint256 epoch,
        uint256 n,
        uint256 k,
        uint256 t,
        address[] memory nodeList,
        uint256 prevEpoch,
        uint256 nextEpoch
    ) public onlyOwner epochValid(epoch) {
        epochInfo[epoch] = Epoch(
            epoch,
            n,
            k,
            t,
            nodeList,
            prevEpoch,
            nextEpoch
        );
    }

    function isWhitelisted(
        uint256 epoch,
        address nodeAddress
    ) public view returns (bool) {
        return whitelist[epoch][nodeAddress];
    }

    function nodeRegistered(
        uint256 epoch,
        address nodeAddress
    ) public view returns (bool) {
        Epoch storage epochI = epochInfo[epoch];
        for (uint256 i = 0; i < epochI.nodeList.length; i++) {
            if (epochI.nodeList[i] == nodeAddress) {
                return true;
            }
        }
        return false;
    }

    modifier epochValid(uint256 epoch) {
        require(epoch != 0, "Epoch can't be 0");
        _;
    }

    modifier epochCreated(uint256 epoch) {
        require(epochInfo[epoch].id == epoch, "Epoch already created");
        _;
    }
    modifier whitelisted(uint256 epoch) {
        require(
            isWhitelisted(epoch, msg.sender),
            "Node isn't whitelisted for epoch"
        );
        _;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }
}
