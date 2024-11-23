// SPDX-License-Identifier: MIT
pragma solidity 0.8.19;

import {Script, console} from "forge-std/Script.sol";
import {HelperConfig, CodeConstants} from "./HelperConfig.s.sol";
import {VRFCoordinatorV2_5Mock} from "@chainlink/contracts/src/v0.8/vrf/mocks/VRFCoordinatorV2_5Mock.sol";
import {LinkToken} from "../test/mocks/LinkToken.sol";
import {DevOpsTools} from "lib/foundry-devops/src/DevOpsTools.sol";

contract CreateSubscription is Script {
    HelperConfig helperConfig = new HelperConfig();

    function createSubscriptionUsingConfig() public returns (uint256, address) {
        address vrfConfig = helperConfig.getConfig().vrfCoordinator;
        // address account = helperConfig.getConfig().account;
        (uint256 subId, ) = createSubscription(vrfConfig /*, account*/);
        return (subId, vrfConfig);
    }

    function createSubscription(
        address vrfConfig /*, address account*/
    ) public returns (uint256, address) {
        console.log("Creating Subscription on chain id: ", block.chainid);
        vm.startBroadcast(/*helperConfig.getConfig().account*/);
        uint256 subId = VRFCoordinatorV2_5Mock(vrfConfig).createSubscription();
        vm.stopBroadcast();

        console.log("Your Subscription ID is", subId);
        console.log("Please update yur subscription ID in HelperConfig");
        return (subId, vrfConfig);
    }

    function run() public returns (uint256, address) {
        return createSubscriptionUsingConfig();
    }
}

contract FundSubscription is Script, CodeConstants {
    uint256 public constant FUND_AMOUNT = 63 ether;
    HelperConfig helperConfig = new HelperConfig();

    function fundSubscriptionUsingConfig() public {

        address vrfConfig = helperConfig.getConfig().vrfCoordinator;
        uint256 subscriptionId = helperConfig.getConfig().subscriptionId;
        address linkToken = helperConfig.getConfig().link;
        // address account = helperConfig.getConfig().account;
        
        fundSubscription(vrfConfig, subscriptionId, linkToken /*, account*/);
    }

    function fundSubscription(
        address vrfConfig,
        uint256 subscriptionId,
        address linkToken/*, address account*/
    ) public {
        console.log("Funding Subscription: ", subscriptionId);
        console.log("Using vrfCoordinator: ", vrfConfig);
        console.log("On ChainID: ", block.chainid);

        if (block.chainid == LOCAL_CHAIN_ID) {
            vm.startBroadcast();
            VRFCoordinatorV2_5Mock(vrfConfig).fundSubscription(
                subscriptionId,
                FUND_AMOUNT
            );
            vm.stopBroadcast();
        } else {
            vm.startBroadcast(/*helperConfig.getConfig().account*/);
            LinkToken(linkToken).transferAndCall(
                vrfConfig,
                FUND_AMOUNT,
                abi.encode(subscriptionId)
            );
            vm.stopBroadcast();
        }
    }

    function run() public{
        fundSubscriptionUsingConfig();
    }
}

contract AddConsumer is Script {
    HelperConfig helperConfig = new HelperConfig();

    function AddConsumerUsingConfig(address mostRecentlyDeployed) public {
        address vrfConfig = helperConfig.getConfig().vrfCoordinator;
        uint256 subscriptionId = helperConfig.getConfig().subscriptionId;
        // address account = helperConfig.getConfig().account;
        addConsumer(mostRecentlyDeployed, vrfConfig, subscriptionId/*, account*/);
    }

    function addConsumer(
        address contractToAddToVrf,
        address vrfCoordinator,
        uint256 subId/*, address account*/
    ) public {
        console.log("Adding Consumer contract: ", contractToAddToVrf);
        console.log("To VRF Coordinator: ", vrfCoordinator);
        console.log("On ChainID: ", block.chainid);

        vm.startBroadcast(/*helperConfig.getConfig().account*/);
        VRFCoordinatorV2_5Mock(vrfCoordinator).addConsumer(
            subId,
            contractToAddToVrf
        );
        vm.stopBroadcast();
    }

    function run() external {
        address mostRecentlyDeployed = DevOpsTools.get_most_recent_deployment(
            "Raffle",
            block.chainid
        );
        AddConsumerUsingConfig(mostRecentlyDeployed);
    }
}
