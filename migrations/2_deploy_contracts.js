var Grader = artifacts.require("./Grader.sol");

module.exports = function(deployer) {
  deployer.deploy(Grader);
};