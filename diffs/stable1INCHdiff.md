```diff --git a/./src/etherscan/0xD23A44eB2db8AD0817c994D3533528C030279F7c/Flattened.sol b/./src/stableDebt.sol
index 4998758..7ba73de 100644
--- a/./src/etherscan/0xD23A44eB2db8AD0817c994D3533528C030279F7c/Flattened.sol
+++ b/./src/stableDebt.sol
@@ -1,5 +1,6 @@
 // SPDX-License-Identifier: agpl-3.0
 pragma solidity 0.6.12;
+pragma experimental ABIEncoderV2;
 
 /**
  * @title LendingPoolAddressesProvider contract
@@ -536,6 +537,28 @@ interface ICreditDelegationToken {
   function borrowAllowance(address fromUser, address toUser) external view returns (uint256);
 }
 
+interface IDebtTokenBase {
+  /**
+   * @dev Emitted when a debt token is initialized
+   * @param underlyingAsset The address of the underlying asset
+   * @param pool The address of the associated lending pool
+   * @param incentivesController The address of the incentives controller for this aToken
+   * @param debtTokenDecimals the decimals of the debt token
+   * @param debtTokenName the name of the debt token
+   * @param debtTokenSymbol the symbol of the debt token
+   * @param params A set of encoded parameters for additional initialization
+   **/
+  event Initialized(
+    address indexed underlyingAsset,
+    address indexed pool,
+    address incentivesController,
+    uint8 debtTokenDecimals,
+    string debtTokenName,
+    string debtTokenSymbol,
+    bytes params
+  );
+}
+
 /**
  * @title VersionedInitializable
  *
@@ -585,14 +608,14 @@ abstract contract VersionedInitializable {
   }
 
   /**
-  * @dev returns the revision number of the contract
-  * Needs to be defined in the inherited class as a constant.
-  **/ 
+   * @dev returns the revision number of the contract
+   * Needs to be defined in the inherited class as a constant.
+   **/
   function getRevision() internal pure virtual returns (uint256);
 
   /**
-  * @dev Returns true if and only if the function is running in the constructor
-  **/ 
+   * @dev Returns true if and only if the function is running in the constructor
+   **/
   function isConstructor() private view returns (bool) {
     // extcodesize checks the size of the code stored in an address, and
     // address returns the current address. Since the code is still not
@@ -622,11 +645,11 @@ abstract contract VersionedInitializable {
  * This contract is only required for intermediate, library-like contracts.
  */
 abstract contract Context {
-  function _msgSender() internal virtual view returns (address payable) {
+  function _msgSender() internal view virtual returns (address payable) {
     return msg.sender;
   }
 
-  function _msgData() internal virtual view returns (bytes memory) {
+  function _msgData() internal view virtual returns (bytes memory) {
     this; // silence state mutability warning without generating bytecode - see https://github.com/ethereum/solidity/issues/2691
     return msg.data;
   }
@@ -1258,7 +1281,8 @@ library Errors {
 abstract contract DebtTokenBase is
   IncentivizedERC20,
   VersionedInitializable,
-  ICreditDelegationToken
+  ICreditDelegationToken,
+  IDebtTokenBase
 {
   address public immutable UNDERLYING_ASSET_ADDRESS;
   ILendingPool public immutable POOL;
@@ -1302,6 +1326,16 @@ abstract contract DebtTokenBase is
     _setName(name);
     _setSymbol(symbol);
     _setDecimals(decimals);
+
+    emit Initialized(
+      UNDERLYING_ASSET_ADDRESS,
+      address(POOL),
+      address(_incentivesController),
+      decimals,
+      name,
+      symbol,
+      ''
+    );
   }
 
   /**
