// SPDX-License-Identifier: MIT
pragma solidity ^0.8.10;

import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./PriceConsumerV3.sol";

contract Wallet is Ownable {
    uint public constant usdDecimals = 2;
    uint public constant ethDecimals = 18;

    uint public nftPrice;
    uint public ownerEthAmountToWithdraw;
    uint public ownerTokenAmountToWithdraw;
    
    address public oracleEthUsdPrice;
    address public oracleTokenEthPrice;

    PriceConsumerV3 public ethUsdContract;
    PriceConsumerV3 public tokenEthContract;

    mapping( address => uint256) public userEthDeposit;
    mapping( address => mapping(address=>uint256)) public userTokenDeposit;

    constructor (address clEthUsd, address clTokenUsd) {
        oracleEthUsdPrice = clEthUsd;
        oracleTokenEthPrice = clTokenUsd;

        ethUsdContract = new PriceConsumerV3(oracleEthUsdPrice);
        tokenEthContract = new PriceConsumerV3(oracleTokenEthPrice);
    }

    receive() external payable {
        registerUserDeposit(msg.sender, msg.value);
    }

    function registerUserDeposit(address sender, uint256 value) internal {
        userEthDeposit[sender] += value;
    }

    function getNFTPrice() external view returns (uint256) {
        uint256 price;
        int256 iPrice;
        AggregatorV3Interface nftOraclePrice = AggregatorV3Interface(oracleTokenEthPrice);
         (   /*1*/,
            iPrice,
            /*2*/,
            /*3*/,
            /*4*/
            ) = nftOraclePrice.latestRoundData();
            price = uint256(iPrice);
            return price;
    }

    function convertEthInUsd(address user) public view returns (uint) {
        uint ethPriceDecimals = ethUsdContract.getDecimals();
        uint ethPrice = uint(ethUsdContract.getLatestPrice());
        uint divDecs = 18 + ethPriceDecimals - usdDecimals;
        uint userUSDDeposit = userEthDeposit[user] * ethPrice / (10 ** divDecs);
        return userUSDDeposit;
    }

    function convertUsdinETH(uint usdAmount) public view returns (uint) {
        uint ethPriceDecimals = ethUsdContract.getDecimals();
        uint ethPrice = uint(ethUsdContract.getLatestPrice());
        uint mulDecs = 18 + ethPriceDecimals - usdDecimals;
        uint convertAmountInEth = usdAmount * (10**mulDecs) / ethPrice;
        return convertAmountInEth;
    }

    // function transferETHAmountOnBuy(uint nftNumber) public {
    //     uint calcTotalUSDAmount = nftPrice + nftNumber * (10**2);
    //     uint ethAmountForBuying = convertUsdinETH(calcTotalUSDAmount);
    //     uint userEthDeposit[msg.sender] = ethAmountForBuiying;
    //     ownerEthAmountToWithdraw = ethAmountForBuying;
    //     userEthDeposit[msg.sender] = ethAmountForBuying;
    // }
    function userDeposit (address token, uint amount) external {
        SafeERC20.safeTransferFrom(IERC20(token), msg.sender, address(this), amount);
        //userTokenDeposits[msg.sender] [token] += amount;
    }

    function convertNFTPriceInISD() public view returns (uint) {
        uint tokenPriceDecimals = tokenEthContract.getPriceDecimals();
        uint tokenPrice = uint(tokenEthContract.getLatestPrice());

        uint ethPriceDecimals = ethUsdContract.getPriceDecimals();
        uint ethPrice = uint(ethUsdContract.getLatestPrice());
        uint divDecs = tokenPriceDecimals + ethPriceDecimals - usdDecimals;

        uint tokenUSDPrice = tokenPrice * ethPrice / (10 ** divDecs);
        return tokenUSDPrice;
    }

    function convertUSDinNFTAmount (uint usdAmount) public view returns (uint, uint) {
        uint tokenPriceDecimals = tokenEthContract.getPriceDecimals();
        uint tokenPrice = uint(tokenEthContract.getLatestPrice());

        uint ethPriceDecimals = ethUsdContract.getPriceDecimals();
        uint ethPrice = uint(ethUsdContract.getLatestPrice());
        uint mulDecs = tokenPriceDecimals + ethPriceDecimals - usdDecimals;
        uint convertAmountInEth = usdAmount * ( 10 ** mulDecs) / ethPrice;
        uint convertEthInTokens = convertAmountInEth /  tokenPrice;


        uint totalCosts = convertEthInTokens * tokenPrice * ethPrice / (10 ** 24);
        uint remaningUSD = usdAmount - totalCosts;
        return (convertEthInTokens, remaningUSD);
    }

    function getNativeCoinsBalance() external view returns (uint256) {
        return address(this).balance;
    }

    function getTokenBalance (address _token) external view returns (uint256) {
        return IERC20(_token).balanceOf(address(this));
    }

    function getNativeCoinsWithdraw() external onlyOwner {
        require(ownerEthAmountToWithdraw > 0, "no eth to withdraw");
        uint256 tmpAmount = ownerEthAmountToWithdraw;
        ownerEthAmountToWithdraw = 0;
        (bool sent, ) = payable (_msgSender()).call{value: tmpAmount}("");
        require(sent, "!sent");
    }

    function userEthWithdraw() external {
        require(userEthDeposit[msg.sender] > 0, "no eth to withdraw");
        (bool sent, ) = payable (_msgSender()).call{value: userEthDeposit[msg.sender]}("");
        require(sent, "!sent");
        userEthDeposit[msg.sender] = 0;

    }
    
}