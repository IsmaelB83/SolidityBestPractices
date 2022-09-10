const CheckEffectInteraction = artifacts.require('CheckEffectInteraction')
const { toBN } = web3.utils;

contract('CheckEffectInteraction', accounts => {

    it('user can withdraw ether', async () => {
        const checkEffectInteration = await CheckEffectInteraction.deployed()
        // Deposit money in the contract
        //console.log(`My Balance now (BEFORE DEPOSIT) = ${await web3.eth.getBalance(accounts[4])}`);
        checkEffectInteration.deposit({from: accounts[4], value: 5000000000000000});
        //console.log(`My Balance now (AFTER DEPOSIT) = ${await web3.eth.getBalance(accounts[4])}`);
        //console.log(`My Balance now (IN CONTRACT)= ${await checkEffectInteration.getBalance.call({from: accounts[4]})}`);
        // Check balance after withdraw, then withdraw and check new balance
        checkEffectInteration.safeWithdraw(5000000000000000, {from: accounts[4]});
        //console.log(`My Balance now (AFTER WITHDRAW) = ${await web3.eth.getBalance(accounts[4])}`);
        //console.log(`My Balance now (IN CONTRACT) = ${await checkEffectInteration.getBalance.call({from: accounts[4]})}`);
    });
});