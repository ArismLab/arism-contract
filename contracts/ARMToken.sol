// SPDX-License-Identifier: UNLICENSED
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

pragma solidity ^0.8.24;

contract ARMToken is ERC20 {
    struct Stake {
        string url;
        uint256 locked;
        uint256 reward;
        uint256 timestamp;
    }
    struct Validator {
        address user;
        address[] votes;
    }

    enum Network {
        MAINNET,
        HANGING,
        DEADNET
    }

    address public owner;
    uint256 public hangingNodeCount;
    mapping(Network => mapping(address => Stake)) public stakes;
    mapping(Network => uint256) public interest;

    Validator[](5) public validators;

    constructor() ERC20("ARMToken", "ARM") {
        owner = msg.sender;
        _mint(msg.sender, 1000000000000000000000000000);
        _mint(address(this), 1000000000000000000000000000);

        interest[Network.MAINNET] = 10;
        interest[Network.HANGING] = 5;
        interest[Network.DEADNET] = 0;
    }

    function _refreshReward(address user) private {
        Network network = getNetwork(user);

        Stake storage stake = stakes[network][user];

        uint256 timeDiff = block.timestamp - stake.timestamp;
        uint256 reward = (timeDiff * interest[network]) / 100;
        stake.reward += reward;
        stake.timestamp = block.timestamp;
    }

    function hangingQueue() public view returns (address[] memory) {
        // TODO

        return new address[](0);
    }

    function getNetwork(address user) public view returns (Network) {
        if (stakes[Network.MAINNET][user].locked > 0) {
            return Network.MAINNET;
        } else if (stakes[Network.HANGING][user].locked > 0) {
            return Network.HANGING;
        } else if (stakes[Network.DEADNET][user].locked > 0) {
            return Network.DEADNET;
        }

        revert("Node not found");
    }

    function register(string memory url, uint256 locked) public {
        require(
            transferFrom(msg.sender, address(this), locked),
            "Transfer failed"
        );

        uint8 mainnetLength = mainnet.length;

        Stake storage stake = Stake(
            url,
            locked,
            0,
            block.timestamp
        );

        if (mainnetLength < 5) {
            stakes[Network.MAINNET][msg.sender] = stake;

            mainnet.push(msg.sender);
            validators.push(
                Validator(
                    msg.sender,
                    new address[](0)
                )
            );
        } else {
            stakes[Network.HANGING][msg.sender] = stake;
        }
    }

    function unregister() public {
        Network network = getNetwork(msg.sender);
        require(network != Network.MAINNET, "Node must not be in mainnet");

        _refreshReward(msg.sender);
        Stake storage stake = stakes[network][msg.sender];

        _transfer(address(this), msg.sender, stake.locked);
        delete stakes[network][msg.sender];
    }

    function withdrawReward() public {
        _refreshReward(msg.sender);

        Network network = getNetwork(msg.sender);
        Stake storage stake = stakes[network][msg.sender];

        uint256 reward = stake.reward;
        stake.reward = 0;

        _transfer(address(this), msg.sender, reward);
    }

    function vote(uint256 id) public {
        Network network = getNetwork(msg.sender);
        require(network == Network.MAINNET, "Node must be in mainnet");

        address victimAddress = mainnet[id - 1];
        Node storage victimNode = mainnet[victimAddress];

        require(
            validators[id - 1].votes.indexOf(msg.sender) == -1,
            "Already voted"
        );

        validators[id - 1].votes.push(msg.sender);

        if (victimNode.votes.length > 3) {
            _refreshReward(victimAddress);
            Stake storage victimStake = stakes[Network.MAINNET][victimAddress];
            victimStake.amount = 0;

            stakes[Network.DEADNET][victimAddress] = victimStake;
            delete stakes[Network.MAINNET][victimAddress];

            address newNode = hangingQueue()[0];

            stakes[Network.MAINNET][newNode] = stakes[network][newNode];;
            delete stakes[Network.HANGING][newNode];

            validators[id - 1] =  Validator(
                msg.sender,
                new address[](0)
            );;
        }
    }


    struct ValidatorResult {
        uint8 id;
        string url;
        address node;
    }

    function getValidators() public view returns (ValidatorResult[] memory) {
        ValidatorResult[] memory result = new ValidatorResult[](5);

        for (uint8 i = 0; i < 5; i++) {
            Validator storage validator = validators[i];
            result[i] = ValidatorResult(
                i + 1,
                stakes[Network.MAINNET][validator.user].url,
                validator.user
            );
        }

        return result;
    }
}