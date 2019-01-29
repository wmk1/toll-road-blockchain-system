import Web3 from 'web3'
import {
  default as contract
} from 'truffle-contract'
import multiplierArtifacts from '../../build/contracts/MultiplierHolder.json'
import regulatorArtifacts from '../../build/contracts/Regulator.json'
import routePriceHolderArtifacts from '../../build/contracts/RoutePriceHolder.json'
import tollBoothOperatorArtifacts from '../../build/contracts/TollBoothOperator.json'
import tollBoothHolderArtifacts from '../../build/contracts/TollBoothHolder.json'


let MultiplierHolder = contract(multiplierArtifacts)
let Regulator = contract(regulatorArtifacts)
let RoutePriceHolder = contract(routePriceHolderArtifacts)
let TollBoothOperator = contract(tollBoothOperatorArtifacts)
let TollBoothHolder = contract(tollBoothHolderArtifacts)
const App = {
  web3: null,
  account: null,
  meta: null,

  start: async function() {
    const { web3 } = this

      // get contract instance
      const networkId = await web3.eth.net.getId()
      web3 = await new Web3(new Web3.providers.HttpProvider('http://127.0.0.1:8545'))

  },

  setVehicleType: async () => {
    let vehicleType = parseInt(document.getElementById('vehicleType').value)
    let recipient = document.getElementById('address').value
    let regulatorInstance

    if (vehicleType > 3 || vehicleType < 0) {
        console.log('Error')
        self.setStatus('Vehicle type value must be between 0 and 3')
        return 0
      }
    Regulator.deployed().then((instance) => {
        regulatorInstance = instance
        return regulatorInstance.setVehicleType(vehicleType, recipient, {
          from: account
        })
      }).then(() => {
        self.setStatus('Vehicle type set')
        self.refreshBalance()
      }).catch((e) => {
          console.log(e)
          self.setStatus('An error occured while setting vehicle type')
        })
  },

  sendCoin: async function() {
    const amount = parseInt(document.getElementById("amount").value)
    const receiver = document.getElementById("receiver").value

    this.setStatus("Initiating transaction... (please wait)")

    const { sendCoin } = this.meta.methods
    await sendCoin(receiver, amount).send({ from: this.account })

    this.setStatus("Transaction complete!")
    this.refreshBalance()
  },

  setStatus: function(message) {
    const status = document.getElementById("status")
    status.innerHTML = message
  },
}

window.App = App

window.addEventListener("load", function() {
  if (window.ethereum) {
    // use MetaMask's provider
    App.web3 = new Web3(window.ethereum)
    window.ethereum.enable() // get permission to access accounts
  } else {
    console.warn(
      "No web3 detected. Falling back to http://127.0.0.1:8545. You should remove this fallback when you deploy live",
    )
    // fallback - use your fallback strategy (local node / hosted node + in-dapp id mgmt / fail)
    App.web3 = new Web3(
      new Web3.providers.HttpProvider("http://127.0.0.1:8545"),
    )
  }

  App.start()
})