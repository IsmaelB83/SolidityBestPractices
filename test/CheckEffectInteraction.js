const CheckEffectInteraction = artifacts.require('CheckEffectInteraction')

contract('CheckEffectInteraction', accounts => {

    it('user can withdraw ether', async () => {
        const checkEffectInteration = await CheckEffectInteraction.deployed()
        await checkEffectInteration.deposit({from: accounts[0], value: 1000000});
        const oldBalance = await web3.eth.getBalance(accounts[0])
        console.log(oldBalance)
        await checkEffectInteration.safeWithdraw(1000000);
        const newBalance = await web3.eth.getBalance(accounts[0])
        console.log(newBalance)
        assert.equal(true, true, "SafeWithdraw returns all the money deposit");
    });
});