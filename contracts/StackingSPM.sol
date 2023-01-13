// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/security/Pausable.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Context.sol";

interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount)
        external
        returns (bool);

    function allowance(address owner, address spender)
        external
        view
        returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function decimals() external view returns (uint8);

    function transferFrom(
        address sender,
        address recipient,
        uint256 amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(
        address indexed owner,
        address indexed spender,
        uint256 value
    );
}

contract StackingSPM is Ownable, ReentrancyGuard {
    IERC20 token;

    // 365 Days (365 * 24 * 60 * 60)
    uint256 public planDuration = 31536000;

    uint8 public interestRate = 20;

    uint8 public totalStakers;

    struct StakeInfo {
        uint256 startTS;
        uint256 amount;
    }

    mapping(address => StakeInfo) public stakeInfos;
    mapping(address => uint256) public totalRewards;
    mapping(address => bool) public addressStaked;

    event Staked(address indexed from, uint256 amount);
    event Withdraw(address indexed from, uint256 amount);

    constructor(IERC20 _tokenAddress) {
        require(
            address(_tokenAddress) != address(0),
            "Token Address cannot be address 0"
        );
        token = _tokenAddress;
        totalStakers = 0;
    }

    function withdrawToken() external returns (bool) {
        require(addressStaked[msg.sender] == true, "You are not participated");

        uint256 stakeAmount = stakeInfos[msg.sender].amount;
        uint256 totalTokens = stakeAmount +
            (stakeAmount *
                (interestRate / 100) *
                (block.timestamp - stakeInfos[msg.sender].startTS)) /
            planDuration;

        uint256 currentReward = (stakeAmount *
            (interestRate / 100) *
            (block.timestamp - stakeInfos[msg.sender].startTS)) / planDuration;

        token.transfer(msg.sender, totalTokens);
        totalRewards[msg.sender] += currentReward;
        stakeInfos[msg.sender].amount = 0;

        emit Withdraw(msg.sender, totalTokens);

        return true;
    }

    function withdrawToken(uint256 _amount) external returns (bool) {
        require(addressStaked[msg.sender] == true, "You are not participated");

        require(
            stakeInfos[msg.sender].amount >= _amount,
            "Insufficient Balance"
        );

        token.transfer(msg.sender, _amount);

        stakeInfos[msg.sender].amount -= _amount;
        stakeInfos[msg.sender].startTS = block.timestamp;

        emit Withdraw(msg.sender, _amount);

        return true;
    }

    function claimReward() external returns (bool) {
        require(addressStaked[msg.sender] == true, "You are not participated");
        require(stakeInfos[msg.sender].amount > 0, "Insufficient Balance");

        uint256 stakeAmount = stakeInfos[msg.sender].amount;

        uint256 rewardToken = (stakeAmount *
            (interestRate / 100) *
            (block.timestamp - stakeInfos[msg.sender].startTS)) / planDuration;

        token.transfer(msg.sender, rewardToken);

        totalRewards[msg.sender] += rewardToken;
        stakeInfos[msg.sender].startTS = block.timestamp;

        return true;
    }

    function stakeToken(uint256 stakeAmount) external payable {
        require(stakeAmount > 0, "Stake amount should be correct");
        require(addressStaked[msg.sender] == false, "You already participated");
        require(
            token.balanceOf(msg.sender) >= stakeAmount,
            "Insufficient Balance"
        );

        token.transferFrom(msg.sender, address(this), stakeAmount);
        totalStakers++;
        addressStaked[msg.sender] = true;

        stakeInfos[msg.sender] = StakeInfo({
            startTS: block.timestamp,
            amount: stakeAmount
        });

        emit Staked(msg.sender, stakeAmount);
    }
}
