const {expect} = require('chai');
const{
    BN,
    constants,
    expectEvent,
    expectRevert,
    time
} = require('@openzeppelin/test-helpers');
const {web3} = require('@openzeppelin/test-helpers/src/setup');
const {ZERO_ADDRESS} = constants;

const Wallet = artifacts.require("Wallet");
const Token = artifacts.require("Token");
const PriceConsumerV3 = artifacts.require("PriceConsumerV3");

const ethUsdContract = "0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419";
const azukiPriceContract = "0xA8B9A447C73191744D5B79BcE864F343455E1150";

const fromWei = (x) => web3.utils.fromWei(x.toString());
const toWei = (x) => web3.utils.toWei(x.toString());
const fromWei8Dec = (x) => Number(x) / Math.pow(10, 8);
const toWei8Dec = (x) => Number(x) * Math.pow(10, 8);
const fromWei2Dec = (x) => Number(x) / Math.pow(10, 2);
const toWei2Dec = (x) => Number(x) * Math.pow(10, 2);

contract('Wallet', function (accounts) {
    const [deployer , firstAccount, secondAccount] = accounts;


    it('Retrive contract', async function() {
        tokenContract = await Token.deployed()
        expect (tokenContract.address).to.be.not.equal(ZERO_ADDRESS);
        expect (tokenContract.address).to.match(/0x[0-9a-fA-F]{40}/);

        walletContract = await Wallet.deployed();

        priceEthUsd = await PriceConsumerV3.deployed();
    });
// NON MINTA PERCHE' IL COSTRUTTORE PUO' AVERE MAX 2 PARAMETRI IN TRUFFLE 5^
    //it('distribuite some tokens from deployer', async function () {
    //    await tokenContract.transfer(firstAccount, toWei(100000));
    //    await tokenContract.transfer(secondAccount, toWei(150000));

    //    balDepl = await tokenContract.balanceOf(deployer);
    //    balFA = await tokenContract.balanceOf(firstAccount);
    //    balSA = await tokenContract.balanceOf(secondAccount);

    //    console.log(fromWei(balDepl), fromWei(balFA), fromWei(balSA));
    //});

    it('Eth / Usd Price', async function () {
        ret = await priceEthUsd.getPriceDecimals();
        console.log(ret.toString());
        res = await priceEthUsd.getLatestPrice();
        console.log(fromWei8Dec(res))
    })

    //AZUKI NON VA. COS'E' AGGREGATOR PROXY? 

    it('convert ETH in USD', async function () {

    await walletContract.sendTransaction({from: firstAccount, value: toWei(2)})
    ret = await walletContract.convertEthinUsd(firstAccount)
    console.log(fromWei2Dec(ret));

    ret = await walletContract.convertUsdinEth(toWei2Dec(5000));
    console.log(fromWei(ret));

    ret = await walletContract.convertNFTPriceinUSD()
    console.log(fromWei2Dec(ret))

    ret = await walletContract.convertUSDinNFTAmount(toWei2Dec(5000))
    console.log(ret[0].toString(), fromWei2Dec(ret[1]))

    ret = await walletContract.convertUSDinNFTAmount(toWei2Dec(8000))
    console.log(ret[0].toString(), fromWei2Dec(ret[1]))
    })

    
});
