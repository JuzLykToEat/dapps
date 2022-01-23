// SPDX-License-Identifier: MIT
pragma solidity ^0.8.7;

import "@chainlink/contracts/src/v0.8/interfaces/AggregatorV3Interface.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";

contract SmartWallet {
    address constant USDT_ADDRESS = 0x337610d27c682E347C9cD60BD4b3b107C9d34dDd;

    AggregatorV3Interface internal bnbPriceFeed;
    AggregatorV3Interface internal usdtPriceFeed;

    struct Balance {
        uint256 bnbAmount;
        uint256 usdtAmount;
    }

    mapping(address => Balance) public users;

    /**
     * Network: BSC Testnet
     * Aggregator: BNB/USD
     * Address: 0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526
     * Aggregator: USDT/USD
     * Address: 0xEca2605f0BCF2BA5966372C99837b1F182d3D620
     */
    constructor() {
        bnbPriceFeed = AggregatorV3Interface(0x2514895c72f50D8bd4B4F9b1110F0D6bD2c97526);
        usdtPriceFeed = AggregatorV3Interface(0xEca2605f0BCF2BA5966372C99837b1F182d3D620);
    }

    /**
     * Returns the latest Eth price
     */
    function getLatestEthPrice() public view returns (int) {
        (
            uint80 roundID,
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = bnbPriceFeed.latestRoundData();
        return price;
    }

    /**
     * Returns the latest USDT price
     */
    function getLatestUsdtPrice() public view returns (int) {
        (
            uint80 roundID,
            int price,
            uint startedAt,
            uint timeStamp,
            uint80 answeredInRound
        ) = usdtPriceFeed.latestRoundData();
        return price;
    }

    function depositBnb() public payable {
        Balance storage user = users[msg.sender];
        user.bnbAmount += msg.value;
    }

    function depositUsdt(uint256 amount) public {
        IERC20 usdt = IERC20(USDT_ADDRESS);

		require(usdt.balanceOf(msg.sender) >= amount, "Insufficient USDT");

		usdt.transferFrom(msg.sender, address(this), amount);
        Balance storage user = users[msg.sender];
        user.usdtAmount += amount;
    }

    function withdrawBnb(uint256 amount) public {
        Balance storage user = users[msg.sender];
        require(user.bnbAmount >= amount, "Insufficient BNB");
		user.bnbAmount -= amount;
		payable(msg.sender).transfer(amount);
    }

    function withdrawUsdt(uint256 amount) public {
        IERC20 usdt = IERC20(USDT_ADDRESS);

        Balance storage user = users[msg.sender];
        require(user.usdtAmount >= amount, "Insufficient USDT");
		user.usdtAmount -= amount;
        usdt.transfer(msg.sender, amount);
    }
}
