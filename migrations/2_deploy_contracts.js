const Migrations = artifacts.require("./Grader.sol");

module.exports = function(deployer) {
  deployer.deploy(Grader);
};
