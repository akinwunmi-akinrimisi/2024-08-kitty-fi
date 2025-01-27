1. The exchange rate between KittyCoin and EUR should remain stable (1:1)

2. Total protocol collateral value must always exceed total minted KittyCoin value by the required overcollateralization ratio

3. Sum of all user collateral balances in a vault must equal total vault collateral

4. Access Control

- Only KittyPool should be able to interact with KittyVault functions
- Only Meowntainer role can execute Aave protocol interactions
- Users should only be able to interact with their own positions

5. Liquidations should only be possible when positions are undercollateralized
