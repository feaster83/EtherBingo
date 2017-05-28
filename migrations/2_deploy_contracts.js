var EtherBingo = artifacts.require("./EtherBingo.sol");

module.exports = function(deployer) {
    deployer.deploy(EtherBingo);
};
