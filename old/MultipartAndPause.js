
const MultipartAndPause = artifacts.require('MultipartAndPause')

contract('MultipartAndPause', accounts => {

    it('contract owner can register new user', async () => {
        const multipartAndPause = await MultipartAndPause.deployed()
        let newUser = accounts[1]; 
        await multipartAndPause.registerUser(newUser, false);
        let result = await multipartAndPause.isUserRegistered.call(newUser); 
        assert.equal(result['isRegistered'], true, "Contract owner cannot register new user");
    });
    
    it('one approval is not enough to pause contract', async () => {
        const multipartAndPause = await MultipartAndPause.deployed()
        await multipartAndPause.registerUser(accounts[0], true);
        await multipartAndPause.setOperational(false);
        const operational = await multipartAndPause.operational.call();
        assert.equal(operational, true, "Contract is still operational. Number of approval steps not fulfilled");
    });

    it('multi-part consensus is working when approval steps fulfilled', async () => {
        const multipartAndPause = await MultipartAndPause.deployed()
        await multipartAndPause.registerUser(accounts[2], true, {from: accounts[0]});
        await multipartAndPause.setOperational(false, {from: accounts[2]});  // 2nd approval see previous test
        const operational = await multipartAndPause.operational.call();
        assert.equal(operational, false, "Contract is paused operational. Number of approval steps fulfilled");
    });

});
