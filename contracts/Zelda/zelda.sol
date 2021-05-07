// SPDX-License-Identifier: MIT
pragma solidity 0.6.12;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/token/ERC20/SafeERC20.sol";
import "@openzeppelin/contracts/math/SafeMath.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Pausable.sol";

/**
 * @title Zelda lottery contract
 */
contract ZeldaV2 is Ownable, Pausable {
    using SafeMath for uint256;
    using SafeERC20 for IERC20;

    IERC20 public att;
    uint256 private totalAllocation;
    uint256 private nextAnnouncementDelay;
    uint256 public lastAnnouncementBlock;
    uint256 public rewardScheme;

    address[] public winners;
    mapping(address => uint256) private userRewards;
    mapping(address => bool) public nodes;

    constructor(IERC20 _att) public {
        att = _att;
        lastAnnouncementBlock = block.number;
        nextAnnouncementDelay = 1200; // ~ 1hr
        rewardScheme = 50000000000; //$50
    }

    event WinnerAnnouncement(address indexed user, uint256 amount);
    event Claim(address indexed user, uint256 amount);
    event RewardSchemeUpdate( uint256 amount);

    modifier onlyNode() {
        require(nodes[msg.sender] == true, "ZELDA: AUTH_FAILED");
        _;
    }

  /**
     * @dev Notifies Zelda daily lottery winners.
     * Can only be called by trusted nodes.
     * @param _winner current winner.
     */
    function announceWinner(address _winner)
        external
        onlyNode
        whenNotPaused
    {
        require(lastAnnouncementBlock.add(nextAnnouncementDelay) < block.number, "ZELDA: WAIT_FOR_COOLDOWN");
            
            userRewards[_winner] = userRewards[_winner].add(
                rewardScheme
            );
            totalAllocation = totalAllocation.add(rewardScheme);
        
        lastAnnouncementBlock = block.number;
        emit WinnerAnnouncement(_winner, rewardScheme);
    }

  /**
     * @dev Transfers user win amount.
     */
    function claim() external whenNotPaused {
        uint256 claimAmount = userRewards[msg.sender]; // gas optimization
        require(claimAmount > 0, "ZELDA : NO_CLAIM");
        userRewards[msg.sender] = 0;
        totalAllocation = totalAllocation.sub(claimAmount);
        safeAttTransfer(msg.sender, claimAmount);
    }

     function safeAttTransfer(address _to, uint256 _amount) internal {
        uint256 Bal = balance();
        if (_amount > Bal) {
            _amount = Bal;
        }
        att.transfer(_to, _amount);
        emit Claim(_to,_amount);
    }

    /**
     * @dev Sets nodes status.
     * @param _node node address.
     * @param _status node status.
     */
    function setNode(address _node, bool _status) external onlyOwner {
        nodes[_node] = _status;
    }

    /**
     * @dev Updates reward allocation on specific position.
     * @param _amount new amount.
     */
    function updateReward( uint256 _amount)
        external
        onlyOwner
        whenPaused
    {
        rewardScheme = _amount;
        emit RewardSchemeUpdate( _amount);
    }

  /**
     * @dev Returns ATT balance of zelda.
     */
    function balance() public view returns (uint256) {
        return att.balanceOf(address(this));
    }

  /**
     * @dev Returns user's claimable ATT balance.
     * @param _who user's wallet address.
     */
    function pendingReward(address _who) public view returns (uint256) {
        return userRewards[_who];
    }

  /**
     * @dev Returns last zelda announcement count.
     */
    function getTotalAllocation() external view returns (uint256) {
        return totalAllocation;
    }

    /**
     * @dev Returns last zelda announcement block.
     */
    function getLastAnnouncementBlock() external view returns (uint256) {
        return lastAnnouncementBlock;
    }

    /**
     * @dev Returns next zelda announcement block.
     */
    function getNextAnnouncementBlock() external view returns (uint256) {
        return lastAnnouncementBlock.add(nextAnnouncementDelay);
    }

    /**
     * @dev EMERGENCY ONLY. Withdraw ATT amount from zelda. 
     * @param _amount amount to be withdrawn.
     */
    function emergencyWithdraw(uint256 _amount) external onlyOwner whenPaused {
        safeAttTransfer(address(msg.sender), _amount);
    }

  /**
     * @dev Pause zelda state
     */
    function pause() external onlyOwner {
        _pause();
    }

    /**
     * @dev Unpause zelda state
     */
    function unPause() external onlyOwner {
        _unpause();
    }
}
