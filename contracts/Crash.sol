// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";

contract Crash is Ownable, ReentrancyGuard {
    IERC20 public immutable token;
    uint256 public withdrawalFee; // Fee in wei
    uint256 public feePercentage; // Percentage as a whole number

    mapping(address => bool) internal validators;
    address internal validator;

    event Deposit(address indexed player, uint256 amount);
    event WithdrawRequest(address indexed player, uint256 amount);

    constructor() Ownable(msg.sender) {
        token = IERC20(0xe8f8aC9De378f93E48f2cED125AcAE77E0f8FBC5);
        withdrawalFee = 0.0003 ether;
        feePercentage = 1; // Set feePercentage to 1%
        validator = 0x07c4F8C46f4a11aBcCb31A85Da194357053B56C4;
        validators[validator] = true;
    }

    modifier onlyValidator() {
        require(
            validators[msg.sender] || owner() == msg.sender,
            "Not validator"
        );
        _;
    }

    function getBalance() external view returns (uint256) {
        return token.balanceOf(address(this));
    }

    function setWithdrawalFee(uint256 newFee) external onlyOwner {
        require(newFee != withdrawalFee, "New fee must be different");
        withdrawalFee = newFee;
    }

    function setFeePercentage(uint256 newPercentage) external onlyOwner {
        require(
            newPercentage != feePercentage,
            "New percentage must be different"
        );
        feePercentage = newPercentage;
    }

    function addValidator(address validatorAddress) external onlyOwner {
        validators[validatorAddress] = true;
    }

    function removeValidator(address validatorAddress) external onlyOwner {
        validators[validatorAddress] = false;
    }

    function deposit(uint256 amount) external nonReentrant {
        require(amount > 0, "Amount must be greater than 0");

        // Calculate the fee
        uint256 feeAmount = (amount * feePercentage) / 100;
        uint256 amountAfterFee = amount - feeAmount;

        // Transfer the fee to the admin account
        require(
            token.transferFrom(msg.sender, owner(), feeAmount),
            "Fee transfer failed"
        );

        // Transfer the remaining amount to the contract
        require(
            token.transferFrom(msg.sender, address(this), amountAfterFee),
            "Transfer failed"
        );

        emit Deposit(msg.sender, amountAfterFee);
    }

    function requestWithdraw(uint256 amount) external payable nonReentrant {
        require(msg.value >= withdrawalFee, "Amount must be greater than fee");
        require(
            token.balanceOf(address(this)) >= amount,
            "Insufficient balance"
        );
        require(payable(validator).send(msg.value), "Fee transfer failed");
        emit WithdrawRequest(msg.sender, amount);
    }

    function validateWithdraw(
        address to,
        uint256 amount
    ) external onlyValidator {
        require(to != address(0), "Invalid address");
        require(amount > 0, "Amount must be greater than 0");
        require(
            token.balanceOf(address(this)) >= amount,
            "Insufficient balance"
        );
        require(token.transfer(to, amount), "Transfer failed");
    }

    function withdrawAdmin(uint256 amount) external onlyOwner {
        require(amount > 0, "Amount must be greater than 0");
        require(
            token.balanceOf(address(this)) >= amount,
            "Insufficient balance"
        );
        require(token.transfer(owner(), amount), "Transfer failed");
    }
}
