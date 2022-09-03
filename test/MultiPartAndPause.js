
let Test = require('../config/testConfig.js');

contract('MultiPartAndPause', async (accounts) => {

    let config;
    before('setup contract', async () => {
        config = await Test.Config(accounts);
    });

    it('contract owner can register new user', async () => {
        let caller = accounts[0];
        let newUser = config.testAddresses[0]; 
        await config.exerciseC6A.registerUser(newUser, false);
        let result = await config.exerciseC6A.isUserRegistered.call(newUser); 
        assert.equal(result, true, "Contract owner cannot register new user");
    });
    
    it('one approval is not enough to pause contract', async () => {
        let caller = accounts[0];
        await config.exerciseC6A.registerUser(caller, true);
        await config.exerciseC6A.setOperational(false);
        const operational = await config.exerciseC6A.operational.call();
        assert.equal(operational, true, "Contract is still operational. Number of approval steps not fulfilled");
    });

    it('multi-part consensus is working when approval steps fulfilled', async () => {
        let caller = accounts[0];
        await config.exerciseC6A.registerUser(accounts[1], true, {from: caller});
        await config.exerciseC6A.setOperational(false, {from: accounts[1]});
        const operational = await config.exerciseC6A.operational.call();
        assert.equal(operational, false, "Contract is paused operational. Number of approval steps fulfilled");
    });

});
