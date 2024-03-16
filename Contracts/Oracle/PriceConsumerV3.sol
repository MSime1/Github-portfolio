// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";


contract PriceConsumerV3 {

    AggregatorV3Interface internal priceFeed;

    /*
    network: mainnet
    aggregator: ETH/USD
    Address: 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419
    */
    constructor(address clOracleAddress) {
        priceFeed = AggregatorV3Interface(clOracleAddress);
    }

    function getLatestPrice() public view returns (int) {
        (   /*1*/,
            int price,
            /*2*/,
            /*3*/,
            /*4*/
            ) = priceFeed.latestRoundData();
        return price;
    }

    function getDecimals() public view returns (uint) {
        return uint(priceFeed.decimals());
    }
}