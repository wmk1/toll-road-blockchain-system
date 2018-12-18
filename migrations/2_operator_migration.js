const Regulator = artifacts.require('./Regulator.sol')

module.exports = (deployer) => {
  deployer.deploy(Regulator)
}
