```diff --git a/./src/etherscan/0x3F87b818f94F3cC21e47FD3Bf015E8D8183A3E08/Flattened.sol b/./src/varDebt.sol
index 63383e9..9c8757c 100644
--- a/./src/etherscan/0x3F87b818f94F3cC21e47FD3Bf015E8D8183A3E08/Flattened.sol
+++ b/./src/varDebt.sol
@@ -1,5 +1,6 @@
 // SPDX-License-Identifier: agpl-3.0
 pragma solidity 0.6.12;
+pragma experimental ABIEncoderV2;
 
 interface IScaledBalanceToken {
   /**
