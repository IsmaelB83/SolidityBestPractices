const CheckEffectInteraction = artifacts.require("CheckEffectInteraction");
const MultipartAndPause = artifacts.require("MultipartAndPause");
const RateLimit = artifacts.require("RateLimit");
const Employees = artifacts.require("SplitAppData/Employees");

module.exports = function(deployer) {
    deployer.deploy(CheckEffectInteraction);
    deployer.deploy(MultipartAndPause);
    deployer.deploy(RateLimit);
    deployer.deploy(Employees);
}