const CheckEffectInteraction = artifacts.require('CheckEffectInteraction')
const { toBN } = web3.utils;

contract('CheckEffectInteraction', accounts => {

    it('user can withdraw ether', async () => {
        const checkEffectInteration = await CheckEffectInteraction.deployed()
        // Deposit money in the contract
        const deposit = toBN(1000000);
        await checkEffectInteration.deposit({from: accounts[0], value: deposit});
        // Check balance before withdraw, then withdraw 500000wei and check new balance
        const withdraw = toBN(500000);
        const oldBalance = toBN(await web3.eth.getBalance(accounts[0]))
        const tx = await checkEffectInteration.safeWithdraw(withdraw);
        const newBalance = toBN(await web3.eth.getBalance(accounts[0]));
        // New balance should be old balance + withdraw wei - fee costs of withdraw transaction
        const txFee = toBN(tx.receipt.gasUsed).mul(toBN(tx.receipt.effectiveGasPrice))
        console.log(`Old balance: ${oldBalance}`);
        console.log(`New balance: ${newBalance}`);
        console.log(`Gas used: ${toBN(tx.receipt.gasUsed)}`)
        console.log(`Gas price: ${toBN(tx.receipt.effectiveGasPrice)}`)
        console.log(`Transaction costs: ${txFee}`);        
        assert.equal(oldBalance + withdraw - txFee, newBalance, "SafeWithdraw returns all the money deposit");
    });
});