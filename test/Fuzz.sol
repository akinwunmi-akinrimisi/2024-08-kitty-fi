// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "forge-std/Test.sol";
import "../src/KittyPool.sol";
import "mocks/MockERC20.sol";
import "mocks/MockPriceFeed.sol";
import "mocks/MockAavePool.sol";
contract KittyPoolFuzzTest is Test {
    // Events to track state changes
    event DepositMade(address user, uint256 amount);
    event VaultUpdated(uint256 newBalance);

    // Test invariant: deposited amount should match vault balance
    function testFuzz_DepositInvariant(
        address user,
        uint256 amount,
        int256 price
    ) public {
        // Assume valid inputs
        vm.assume(user != address(0));
        vm.assume(amount > 0 && amount < type(uint256).max);
        vm.assume(price > 0);

        // Setup contracts
        MockERC20 token = new MockERC20("Mock", "MCK");
        MockPriceFeed priceFeed = new MockPriceFeed();
        MockAavePool aavePool = new MockAavePool();
        
        KittyPool pool = new KittyPool(
            address(this),
            address(priceFeed),
            address(aavePool)
        );

        // Setup vault
        pool.meownufactureKittyVault(address(token), address(priceFeed));
        priceFeed.setPrice(price);

        // Pre-state checks
        assertEq(token.balanceOf(user), 0);
        
        // Setup user
        deal(address(token), user, amount);
        assertEq(token.balanceOf(user), amount);

        // Execute deposit
        vm.startPrank(user);
        token.approve(address(pool), amount);
        pool.depawsitMeowllateral(address(token), amount);
        vm.stopPrank();

        // Post-state checks
        address vaultAddr = pool.getTokenToVault(address(token));
        uint256 vaultBalance = KittyVault(vaultAddr).getUserMeowllateral(user);
        
        // Verify invariants
        assertEq(vaultBalance, amount, "Vault balance should match deposit");
        assertEq(token.balanceOf(user), 0, "User balance should be zero");
        assertEq(token.balanceOf(vaultAddr), amount, "Vault should hold tokens");
    }

    // Test invalid states
    function testFuzz_DepositInvalidStates(
        address user,
        uint256 amount
    ) public {
        // Setup minimal contracts
        MockERC20 token = new MockERC20("Mock", "MCK");
        KittyPool pool = new KittyPool(
            address(this),
            address(1),
            address(1)
        );

        // Test invalid token
        vm.expectRevert();
        pool.depawsitMeowllateral(address(token), amount);

        // Test zero amount
        pool.meownufactureKittyVault(address(token), address(1));
        vm.assume(amount == 0);
        vm.expectRevert();
        pool.depawsitMeowllateral(address(token), amount);

        // Test insufficient balance
        vm.assume(amount > 0);
        vm.prank(user);
        vm.expectRevert();
        pool.depawsitMeowllateral(address(token), amount);
    }
}