// SPDX-License-Identifier: UNLICENSED
import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "./TreeMap.sol";

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
        Validator,
        HANGING,
        DEADNET
    }

    address public owner;
    uint256 public hangingNodeCount;
    using TreeMap for TreeMap.Map;

    mapping(Network => mapping(address => Stake)) public stakes;
    mapping(Network => uint256) public interest;

    mapping(uint256 => address) keyIndex;

    TreeMap.Map public hangingQueue;
    Validator[] public validators;

    constructor() ERC20("ARMToken", "ARM") {
        owner = msg.sender;
        _mint(msg.sender, 1000000000000000000000000000);
        _mint(address(this), 1000000000000000000000000000);
        interest[Network.Validator] = 10;
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

    function getNetwork(address user) public view returns (Network) {
        if (stakes[Network.Validator][user].locked > 0) {
            return Network.Validator;
        } else if (stakes[Network.HANGING][user].locked > 0) {
            return Network.HANGING;
        } else if (stakes[Network.DEADNET][user].locked > 0) {
            return Network.DEADNET;
        }

        revert("Node not found");
    }

    function register(string memory url, uint256 locked) public payable {
        _transfer(msg.sender, address(this), locked);

        uint256 validatorLength = validators.length;

        Stake memory stake = Stake(url, locked, 0, block.timestamp);

        if (validatorLength < 5) {
            stakes[Network.Validator][msg.sender] = stake;
            validators.push(Validator(msg.sender, new address[](0)));
        } else {
            stakes[Network.HANGING][msg.sender] = stake;
            keyIndex[hangingNodeCount] = msg.sender;
            hangingQueue.putIfAbsent(hangingNodeCount, locked);
            hangingNodeCount++;
        }
    }

    function unregister() public {
        Network network = getNetwork(msg.sender);
        require(network != Network.Validator, "Node must not be in Validator");

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
        require(network == Network.Validator, "Node must be in Validator");

        Validator storage victimNode = validators[id - 1];

        require(victimNode.user != msg.sender, "Node cannot vote for itself");

        validators[id - 1].votes.push(msg.sender);

        if (victimNode.votes.length > 3) {
            _refreshReward(victimNode.user);
            Stake storage victimStake = stakes[Network.Validator][
                victimNode.user
            ];
            victimStake.locked = 0;

            stakes[Network.DEADNET][victimNode.user] = victimStake;
            delete stakes[Network.Validator][victimNode.user];

            address newNode = keyIndex[hangingQueue.size() - 1];
            hangingQueue.remove(hangingQueue.size() - 1);

            stakes[Network.Validator][newNode] = stakes[network][newNode];
            delete stakes[Network.HANGING][newNode];
            validators[id - 1] = Validator(msg.sender, new address[](0));
        }
    }

    struct ValidatorResult {
        uint8 id;
        string url;
        address node;
    }

    function getValidators() public view returns (ValidatorResult[] memory) {
        ValidatorResult[] memory result = new ValidatorResult[](5);

        for (uint8 i = 0; i < validators.length; i++) {
            Validator storage validator = validators[i];
            result[i] = ValidatorResult(
                i + 1,
                stakes[Network.Validator][validator.user].url,
                validator.user
            );
        }

        return result;
    }

    function getMyBalance() public view returns (uint256) {
        return balanceOf(msg.sender);
    }
}
