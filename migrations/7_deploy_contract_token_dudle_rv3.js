const DudleTokenRVVoteAddNewOwners = artifacts.require("DudleTokenRVVoteAddNewOwners");

module.exports = function (deployer) {
  deployer.deploy(DudleTokenRVVoteAddNewOwners);
};