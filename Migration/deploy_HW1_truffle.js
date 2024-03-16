const Blacklist = artifacts.require("Blacklist");
const Token = artifacts.require("Token");


module.exports = async(deployer) =>{
    await deployer.deploy(Blacklist);
    const blacklist = await Blacklist.deployed();
    console.log("Blacklist deployed @:", blacklist.address);

        await deployer.deploy(Token, "myToken", "MTK", blacklist.address);
        const token = await Token.deployed();
        console.log("Token deployed @:", token.address);

}