// SPDX-License-Identifier: MIT
pragma solidity 0.8.26;

import "forge-std/Test.sol";
import "../src/KittyPool.sol";
import "mocks/MockERC20.sol";
import "mocks/MockPriceFeed.sol";
import "mocks/MockAavePool.sol";
 
contract KittyPoolHandler is Test {
    KittyPool public pool;
    MockERC20 public token;
    
    address[] public actors;
    uint256 public totalDeposits;
    uint256 public totalWithdrawals;
    uint256 public mintCallCount;
    uint256 public burnCallCount;

    constructor(KittyPool _pool, MockERC20 _token) {
        pool = _pool;
        token = _token;
    }

    // Ghost variables to track system state
    function deposit(uint256 actorSeed, uint256 amount) public {
        amount = bound(amount, 1e18, 1000e18);
        address actor = getActor(actorSeed);
        
        // Mint tokens to actor
        deal(address(token), actor, amount);
        
        vm.startPrank(actor);
        token.approve(address(pool), amount);
        pool.depawsitMeowllateral(address(token), amount);
        vm.stopPrank();

        totalDeposits += amount;
    }

    function withdraw(uint256 actorSeed, uint256 amount) public {
        address actor = getActor(actorSeed);
        address vault = pool.getTokenToVault(address(token));
        uint256 balance = KittyVault(vault).getUserMeowllateral(actor);
        
        amount = bound(amount, 0, balance);
        if(amount == 0) return;

        vm.prank(actor);
        pool.whiskdrawMeowllateral(address(token), amount);

        totalWithdrawals += amount;
    }

    function mint(uint256 actorSeed, uint256 amount) public {
        amount = bound(amount, 1e18, 100e18);
        address actor = getActor(actorSeed);

        vm.prank(actor);
        pool.meowintKittyCoin(amount);

        mintCallCount++;
    }

    function burn(uint256 actorSeed, uint256 amount) public {
        address actor = getActor(actorSeed);
        uint256 debt = pool.getKittyCoinMeownted(actor);
        
        amount = bound(amount, 0, debt);
        if(amount == 0) return;

        vm.prank(actor);
        pool.burnKittyCoin(actor, amount);

        burnCallCount++;
    }

    // Helper functions
    function getActor(uint256 seed) internal returns (address) {
        if(actors.length == 0 || seed % 10 == 0) {
            address actor = address(uint160(seed));
            actors.push(actor);
            return actor;
        }
        return actors[seed % actors.length];
    }

    function getActors() external view returns (uint256[] memory) {
        return actors;
    }

    function callSummary() external view {
        console.log("Total deposits:", totalDeposits);
        console.log("Total withdrawals:", totalWithdrawals);
        console.log("Mint calls:", mintCallCount);
        console.log("Burn calls:", burnCallCount);
        console.log("Unique actors:", actors.length);
    }
}