const {expect} = require('chai');
const{
    BN,
    constants,
    expectEvent,
    expectRevert,
    time
} = require('@openzeppelin/test-helpers');

const Web3 = require('web3');
const web3 = new Web3(new Web3.providers.HttpProvider("http://localhost:8545"));

const Notarize = artifacts.require('Notarize');

const {ZERO_ADDRESS} = constants;

const {fromWei} = (x) => web3.utils.fromWei(x.toString());
const {toWei} = (x) => web3.utils.toWei(x.toString());

const HashWriter = "0x9bd7b39e404ec8163ddb5278c0044198ca50a2bf864985cbc93f934a5afed5d6"; //HASH_WRITER
const DefaultAdminRole = "0x0000000000000000000000000000000000000000000000000000000000000000";
const hash1 = "0xb133a0c0e9bee3be20163d2ad31d6248db292aa6dcb1ee087a2aa50e0fc75ae2"; //ciao
const hash2 = "0x25c73520e69f4bf229811e8e46ffe7d80471544b9bee15ed25044b86be4115ad"; //Ciao

contract('Notarization test', function (accounts) {
    const Admin = accounts[0];
    const HashWriter1 = accounts[1];

    it('Retrive contract', async function() {
        NotarizeContract = await Notarize.deployed()
        expect (NotarizeContract.address).to.be.not.equal(ZERO_ADDRESS);
        expect (NotarizeContract.address).to.match(/0x[0-9a-fA-F]{40}/);
    });

    it('Contract admin assign hash writer role to account 1', async function () {
        await expectRevert(NotarizeContract.setHashWriterRole(HashWriter1, {from: HashWriter1}),
        "AccessControl: account " + HashWriter1.toLowerCase() + " is missing role " + DefaultAdminRole);
        await NotarizeContract.setHashWriterRole(HashWriter1, {from: Admin});
        expect(await NotarizeContract.hasRole(HashWriter, HashWriter1)).to.be.true;
    })

    it('A hash writer address cannot assign the same role to another address', async function () {
        await expectRevert(NotarizeContract.setHashWriterRole(HashWriter1, {from: HashWriter1}),
        "AccessControl: account " + HashWriter1.toLowerCase() + " is missing role " + DefaultAdminRole);
    })

    it('An admin address cannot Notarize a document', async function () {
        await expectRevert(NotarizeContract.addNewDocument("Example", hash1, {from :Admin}),
        "AccessControl: account " + Admin.toLowerCase() + " is missing role " + HashWriter);
    })

    it('A hash writer address can notarize a document and get notarized doc back', async function () {
        await NotarizeContract.addNewDocument("example", hash1, {from: HashWriter1})
        tot = await NotarizeContract.getDocsCount();
        console.log("Total dcument registered:" + tot.toString())
        result = await NotarizeContract.getDocInfo(tot - 1)
        console.log(result[0].toString + ":" + result[1])
    })


    it('A hash writer address cannot notarize a document twice', async function () {
        await expectRevert(NotarizeContract.addNewDocument("example", hash1, {from: HashWriter1}),"hash already notarized");
        tot = await NotarizeContract.getDocsCount();
        console.log("Total document registered: " + tot.toString());
    });
    
    it('A hash writer cannot notarize another document and get notarized back', async function () {
        await NotarizeContract.addNewDocument("test", hash2, {from:HashWriter1})
        tot = await NotarizeContract.getDocsCount();
        console.log("Total document registered: " + tot.toString())
        result = await NotarizeContract.getDocInfo(tot - 1);
        console.log(result[0].toString + ":" + result[1]);
        })
    it('is document already registered', async function () {
        expect(await NotarizeContract.getRegisteredHash(hash1)).to.be.true;
        const hash1Corrupted = "0x6119ce5b522dbbbcf1f5927eeab860165ad131e1c6b76aead9c0088a9ef85dd3" //Ciao!
        expect(await NotarizeContract.getRegisteredHash(hash1Corrupted)).to.be.false;
    })
    
});