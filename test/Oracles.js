// Node Imports
const truffleAssert = require("truffle-assertions");
// Own imports
const Oracles = artifacts.require('Oracles')

// Constants
const TEST_ORACLES_COUNT = 20;
const ON_TIME = 10;

contract('Oracles', async (accounts) => {

    it('can register oracles', async () => {
        const oracles = await Oracles.deployed()
        const fee = await oracles.REGISTRATION_FEE.call();
        for(let i=1; i<=TEST_ORACLES_COUNT; i++) {
            await oracles.registerOracle({from: accounts[i], value: fee});
            const result = await oracles.getOracle(accounts[i])
            console.log(`Oracle registered: ${accounts[i]} - ${result[0].toNumber()} ${result[1].toNumber()} ${result[2].toNumber()}`)
        }
    });

    it('can request flight status', async () => {
        const oracles = await Oracles.deployed()
        const flight = 'ND1309';
        const timestamp = Math.floor(Date.now() / 1000);
        // Submit a request for oracles to get status information for a flight
        const tx = await oracles.fetchFlightStatus(flight, timestamp);
        truffleAssert.eventEmitted(tx, 'OracleRequest', ev => {
            console.log(`EVENT - Oracle Requested: ${ev.index.toNumber()} - ${ev.flight} - ${ev.timestamp.toNumber()}`);
            return ev.flight == 'ND1309' && ev.timestamp.toNumber() == timestamp;
        })
        // ACT
        // Since the Index assigned to each test account is opaque by design loop through all the accounts and for each account,
        // all its Indexes and submit a response. The contract will reject a submission if it was not requested so while sub-optimal,
        // it's a good test of that feature
        for(i=1;i<TEST_ORACLES_COUNT;i++) {
            // GET ORACLE INFORMATION
            // For a real contract, we would not want to have this capability so oracles can remain secret (at least to the extent
            // one doesn't look in the blockchain data)
            const oracleIndexes = await oracles.getOracle(accounts[i]);
            for(let j=0;j<3;j++) {
                try {
                    // Submit a response...it will only be accepted if there is an Index match
                    const tx = await oracles.submitOracleResponse(oracleIndexes[j], flight, timestamp, 10, { from: accounts[i] });
                    truffleAssert.eventEmitted(tx, 'FlightStatusInfo', ev => {
                        console.log(`EVENT - Flight Status: ${ev.flight} - ${ev.timestamp.toNumber()} - ${ev.status == ON_TIME?'ON_TIME':'NOT_ON_TIME'} - ${ev.verified?'VERIFIED':'NOT_VERIFIED'}`);
                        exit = ev.verified;
                        return true;
                    });
                }
                catch(e) {
                    // Enable this when debugging
                    console.log(`SubmitOracleResponse rejected: ${accounts[i]} - ${oracleIndexes[j]}`);
                }
            }
        } 
    });

});