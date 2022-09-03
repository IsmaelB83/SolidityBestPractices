const CheckEffectInteraction = artifacts.require("CheckEffectInteraction");
const MultipartAndPause = artifacts.require("MultipartAndPause");

module.exports = function(deployer) {
    deployer.deploy(CheckEffectInteraction);
    deployer.deploy(MultipartAndPause);
}