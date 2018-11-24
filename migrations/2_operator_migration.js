const Regulator = artifacts.require('./Regulator.sol')

module.export = (deployer) => {
  deployer.deploy(Regulator)
}
