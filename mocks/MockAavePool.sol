// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "src/interfaces/IAavePool.sol";

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract MockAavePool is IAavePool {
    mapping(address => uint256) public suppliedAmount;

    function supply(
        address asset,
        uint256 amount,
        address onBehalfOf,
        uint16 referralCode
    ) external {
        IERC20(asset).transferFrom(msg.sender, address(this), amount);
        suppliedAmount[onBehalfOf] += amount;
    }

    function withdraw(
        address asset,
        uint256 amount,
        address to
    ) external returns (uint256) {
        require(suppliedAmount[msg.sender] >= amount, "Insufficient balance");
        suppliedAmount[msg.sender] -= amount;
        IERC20(asset).transfer(to, amount);
        return amount;
    }

    function getUserAccountData(address user)
        external
        view
        returns (
            uint256 totalCollateralBase,
            uint256 totalDebtBase,
            uint256 availableBorrowsBase,
            uint256 currentLiquidationThreshold,
            uint256 ltv,
            uint256 healthFactor
        )
    {
        return (
            suppliedAmount[user], // totalCollateralBase
            0,                    // totalDebtBase
            0,                    // availableBorrowsBase
            0,                    // currentLiquidationThreshold
            0,                    // ltv
            0                     // healthFactor
        );
    }
}