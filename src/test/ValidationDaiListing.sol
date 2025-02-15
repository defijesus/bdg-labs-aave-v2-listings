// SPDX-License-Identifier: MIT
pragma solidity 0.8.11;

import "forge-std/Test.sol";
import "forge-std/console.sol";
import { AaveAddressBookV2 } from 'aave-address-book/AaveAddressBookV2.sol';
import {AaveV2Helpers, ReserveConfig, ReserveTokens, InterestStrategyValues} from "./utils/AaveV2Helpers.sol";
import {AaveGovHelpers, IAaveGov} from "./utils/AaveGovHelpers.sol";

import {ArcDaiListingPayload} from "../ArcDaiListingPayload.sol";
import {IERC20} from "../interfaces/IERC20.sol";

contract ValidationDaiListing is Test {
    address internal constant AAVE_WHALE =
        0x25F2226B597E8F9514B3F68F00f494cF4f286491;

    address internal constant AAVE = 0x7Fc66500c84A76Ad7e9c93437bFc5Ac33E2DDaE9;

    address internal constant ASSET = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

    uint8 public constant ASSET_DECIMALS = 18;

    address internal constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;

    address internal POOL = address(AaveAddressBookV2.getMarket(AaveAddressBookV2.AaveV2EthereumArc).POOL);

    address internal constant RESERVE_TREASURY_ADDRESS = 0x464C71f6c2F760DdA6093dCB91C24c39e5d6e18c;

    address internal LENDING_POOL_ADDRESSES_PROVIDER = address(AaveAddressBookV2.getMarket(AaveAddressBookV2.AaveV2EthereumArc).POOL_ADDRESSES_PROVIDER);

    address internal constant INCENTIVES_CONTROLLER = address(0);

    // string internal constant ATOKEN_NAME = "Aave interest bearing 1INCH";

    // string internal constant ATOKEN_SYMBOL = "a1INCH";

    // string internal constant STABLE_DEBT_TOKEN_NAME = "Aave stable debt bearing 1INCH";

    // string internal constant STABLE_DEBT_TOKEN_SYMBOL = "stableDebt1INCH";

    // string internal constant VARIABLE_DEBT_TOKEN_NAME = "Aave variable debt bearing 1INCH";
    
    // string internal constant VARIABLE_DEBT_TOKEN_SYMBOL = "variableDebt1INCH";

    address internal constant DAI_WHALE =
        0xbEbc44782C7dB0a1A60Cb6fe97d0b483032FF1C7;

    address public constant ASSET_WHALE =
        0x12e1062d629DCf98D17cA5615e766ADa53945bf3;

    // can't be constant for some reason
    string internal MARKET_NAME = AaveAddressBookV2.AaveV2EthereumArc;

    // artifacts
    // string internal constant aTokenArtifact = "AToken.sol:AToken";
    // string internal constant stableDebtArtifact = "stableDebt.sol:StableDebtToken";
    // string internal constant variableDebtArtifact = "varDebt.sol:VariableDebtToken";
    // string internal constant interestRateStrategyArtifact = "interestRateStrat.sol:DefaultReserveInterestRateStrategy";


    // uint256 internal constant OPTIMAL_UTILIZATION_RATE = 450000000000000000000000000;

    // uint256 internal constant BASE_VARIABLE_BORROW_RATE = 0;

    // uint256 internal constant VARIABLE_RATE_SLOPE_1 = 70000000000000000000000000;

    // uint256 internal constant VARIABLE_RATE_SLOPE_2 = 3000000000000000000000000000;

    // uint256 internal constant STABLE_RATE_SLOPE_1 = 100000000000000000000000000;

    // uint256 internal constant STABLE_RATE_SLOPE_2 = 3000000000000000000000000000;

    function setUp() public {}

    /// @dev Uses an already deployed payload on the target network
    function testProposalPostPayload() public {
        /// deploy payload
        ArcDaiListingPayload dai = new ArcDaiListingPayload();
        address payload = address(dai);
        _testProposal(payload);
    }

    function _testProposal(address payload) internal {
        ReserveConfig[] memory allConfigsBefore = AaveV2Helpers
            ._getReservesConfigs(false, MARKET_NAME);

        address[] memory targets = new address[](1);
        targets[0] = payload;
        uint256[] memory values = new uint256[](1);
        values[0] = 0;
        string[] memory signatures = new string[](1);
        signatures[0] = "executeQueueTimelock()";
        bytes[] memory calldatas = new bytes[](1);
        calldatas[0] = "";
        bool[] memory withDelegatecalls = new bool[](1);
        withDelegatecalls[0] = true;

        uint256 proposalId = AaveGovHelpers._createProposal(
            vm,
            AAVE_WHALE,
            IAaveGov.SPropCreateParams({
                executor: AaveGovHelpers.ARC_SHORT_EXECUTOR,
                targets: targets,
                values: values,
                signatures: signatures,
                calldatas: calldatas,
                withDelegatecalls: withDelegatecalls,
                ipfsHash: bytes32(0)
            })
        );

        AaveGovHelpers._passVote(vm, AAVE_WHALE, proposalId);

        AaveGovHelpers._executeArcTimelock(vm);

        ReserveConfig[] memory allConfigsAfter = AaveV2Helpers
            ._getReservesConfigs(false, MARKET_NAME);

        AaveV2Helpers._validateCountOfListings(
            1,
            allConfigsBefore,
            allConfigsAfter
        );

        ReserveConfig memory expectedEnsConfig = ReserveConfig({
            symbol: "DAI",
            underlying: ASSET,
            aToken: address(0), // Mock, as they don't get validated, because of the "dynamic" deployment on proposal execution
            variableDebtToken: address(0), // Mock, as they don't get validated, because of the "dynamic" deployment on proposal execution
            stableDebtToken: address(0), // Mock, as they don't get validated, because of the "dynamic" deployment on proposal execution
            decimals: 18,
            ltv: 7700,
            liquidationThreshold: 8000,
            liquidationBonus: 10500,
            reserveFactor: 1000,
            usageAsCollateralEnabled: true,
            borrowingEnabled: true,
            interestRateStrategy: ArcDaiListingPayload(payload).INTEREST_RATE_STRATEGY(),
            stableBorrowRateEnabled: true,
            isActive: true,
            isFrozen: false
        });

        AaveV2Helpers._validateReserveConfig(
            expectedEnsConfig,
            allConfigsAfter
        );

        AaveV2Helpers._validateInterestRateStrategy(
            ASSET,
            ArcDaiListingPayload(payload).INTEREST_RATE_STRATEGY(),
            InterestStrategyValues({
                excessUtilization: 20 * (AaveV2Helpers.RAY / 100),
                optimalUtilization: 80 * (AaveV2Helpers.RAY / 100),
                baseVariableBorrowRate: 0,
                stableRateSlope1: 20000000000000000000000000,
                stableRateSlope2: 750000000000000000000000000,
                variableRateSlope1: 4 * (AaveV2Helpers.RAY / 100),
                variableRateSlope2: 75 * (AaveV2Helpers.RAY / 100)
            }),
            MARKET_NAME
        );

        AaveV2Helpers._noReservesConfigsChangesApartNewListings(
            allConfigsBefore,
            allConfigsAfter
        );

        AaveV2Helpers._validateReserveTokensImpls(
            vm,
            AaveV2Helpers._findReserveConfig(allConfigsAfter, "DAI", false),
            ReserveTokens({
                aToken: ArcDaiListingPayload(payload).ATOKEN_IMPL(),
                stableDebtToken: ArcDaiListingPayload(payload).STABLE_DEBT_IMPL(),
                variableDebtToken: ArcDaiListingPayload(payload)
                    .VARIABLE_DEBT_IMPL()
            }),
            MARKET_NAME
        );

        AaveV2Helpers._validateAssetSourceOnOracle(
            ASSET,
            ArcDaiListingPayload(payload).FEED_DAI_ETH(),
            MARKET_NAME
        );

        _validatePoolActionsPostListing(allConfigsAfter);
    }

    function _validatePoolActionsPostListing(
        ReserveConfig[] memory allReservesConfigs
    ) internal {
        AaveV2Helpers._deposit(
            vm,
            ASSET_WHALE,
            ASSET_WHALE,
            ASSET,
            666 ether,
            true,
            AaveV2Helpers
                ._findReserveConfig(allReservesConfigs, "DAI", false)
                .aToken,
            MARKET_NAME
        );
        AaveV2Helpers._deposit(
            vm,
            AAVE_WHALE,
            AAVE_WHALE,
            AAVE,
            666 ether,
            true,
            AaveV2Helpers
                ._findReserveConfig(allReservesConfigs, "AAVE", false)
                .aToken,
            MARKET_NAME
        );

        AaveV2Helpers._borrow(
            vm,
            ASSET_WHALE,
            ASSET_WHALE,
            DAI,
            10 ether,
            2,
            AaveV2Helpers
                ._findReserveConfig(allReservesConfigs, "DAI", false)
                .variableDebtToken,
            MARKET_NAME
        );

        AaveV2Helpers._borrow(
            vm,
            AAVE_WHALE,
            AAVE_WHALE,
            ASSET,
            10 ether,
            2,
            AaveV2Helpers
                ._findReserveConfig(allReservesConfigs, "DAI", false)
                .variableDebtToken,
            MARKET_NAME
        );

        try
            AaveV2Helpers._borrow(
                vm,
                AAVE_WHALE,
                AAVE_WHALE,
                ASSET,
                10 ether,
                1,
                AaveV2Helpers
                    ._findReserveConfig(allReservesConfigs, "DAI", false)
                    .stableDebtToken,
                MARKET_NAME
            )
        {
            revert("_testProposal() : STABLE_BORROW_NOT_REVERTING");
        } catch Error(string memory revertReason) {
            require(
                keccak256(bytes(revertReason)) == keccak256(bytes("12")),
                "_testProposal() : INVALID_STABLE_REVERT_MSG"
            );
            vm.stopPrank();
        }

        AaveV2Helpers._repay(
            vm,
            AAVE_WHALE,
            AAVE_WHALE,
            ASSET,
            type(uint256).max,
            2,
            AaveV2Helpers
                ._findReserveConfig(allReservesConfigs, "DAI", false)
                .variableDebtToken,
            true,
            MARKET_NAME
        );

        vm.startPrank(DAI_WHALE);
        IERC20(DAI).transfer(ASSET_WHALE, 300 ether);
        vm.stopPrank();

        AaveV2Helpers._repay(
            vm,
            ASSET_WHALE,
            ASSET_WHALE,
            DAI,
            IERC20(DAI).balanceOf(ASSET_WHALE),
            2,
            AaveV2Helpers
                ._findReserveConfig(allReservesConfigs, "DAI", false)
                .variableDebtToken,
            true,
            MARKET_NAME
        );

        AaveV2Helpers._withdraw(
            vm,
            ASSET_WHALE,
            ASSET_WHALE,
            ASSET,
            type(uint256).max,
            AaveV2Helpers
                ._findReserveConfig(allReservesConfigs, "DAI", false)
                .aToken,
            MARKET_NAME
        );
    }
}
