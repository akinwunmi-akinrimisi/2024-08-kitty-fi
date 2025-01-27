// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "test/KittyPoolHandler.sol";
import "forge-std/Test.sol";
import "../src/KittyPool.sol";
import "mocks/MockERC20.sol";
import "mocks/MockPriceFeed.sol";
import "mocks/MockAavePool.sol";
contract KittyPoolInvariantTest is Test {
    KittyPool public pool;
    MockERC20 public token;
    MockPriceFeed public priceFeed;
    MockAavePool public aavePool;
    KittyPoolHandler public handler;

    function setUp() public {
        // Deploy mocks
        token = new MockERC20("Mock Token", "MTK");
        priceFeed = new MockPriceFeed();
        aavePool = new MockAavePool();

        // Deploy main contract
        pool = new KittyPool(
            address(this),
            address(priceFeed),
            address(aavePool)
        );

        // Create vault
        pool.meownufactureKittyVault(address(token), address(priceFeed));

        // Deploy handler
        handler = new KittyPoolHandler(pool, token);

        // Target contract functions to test
        targetContract(address(handler));

        // Label contracts for better traces
        vm.label(address(pool), "KittyPool");
        vm.label(address(token), "Token");
        vm.label(address(handler), "Handler");
    }

    function invariant_totalSupply() public {
        // Total token supply in vault should match tracked amount
        assertEq(
            token.balanceOf(pool.getTokenToVault(address(token))),
            handler.totalDeposits()
        );
    }

    function invariant_collateralization() public {
        // All positions should maintain minimum collateral ratio
        uint256[] memory actors = handler.getActors();
        for(uint256 i = 0; i < actors.length; i++) {
            if(pool.getKittyCoinMeownted(address(actors[i])) > 0) {
                assertTrue(pool._hasEnoughMeowllateral(address(actors[i])));
            }
        }
    }

    function invariant_userBalances() public {
        // User shares should correctly represent their portion of vault
        uint256[] memory actors = handler.getActors();
        address vaultAddr = pool.getTokenToVault(address(token));
        KittyVault vault = KittyVault(vaultAddr);
        
        uint256 totalShares = vault.totalCattyNip();
        if(totalShares > 0) {
            for(uint256 i = 0; i < actors.length; i++) {
                uint256 userShares = vault.userToCattyNip(address(actors[i]));
                uint256 userBalance = vault.getUserMeowllateral(address(actors[i]));
                
                assertApproxEqRel(
                    userBalance,
                    (userShares * vault.getTotalMeowllateral()) / totalShares,
                    1e15 // 0.1% tolerance for rounding
                );
            }
        }
    }

    function invariant_mathInvariants() public {
        // Various mathematical invariants that should always hold
        assertTrue(handler.totalDeposits() >= handler.totalWithdrawals());
        assertTrue(handler.mintCallCount() >= handler.burnCallCount());
    }

    function invariant_callSummary() public view {
        handler.callSummary();
    }
}