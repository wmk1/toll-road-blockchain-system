const Web3 = require("web3")

const regulatorArtifacts = require('../../build/contracts/Regulator.json')
const tollBoothOperatorArtifacts = require('../../build/contracts/TollBoothOperator.json')

const App = {
  web3: null,
  account: null,
  regulator: null,
  tollBoothOperator: null,

  start: async () => {
    try {
      const { web3 } = this
      console.log(web3)
      const networkId = await web3.web3.eth.getId()
      const deployedNetwork = regulatorArtifacts.networks[networkId]
      this.regulator = new web3.eth.Contract(
      regulatorArtifacts.abi,
      deployedNetwork.address
    )
      this.tollBoothOperator = new web3.eth.Contract(
      tollBoothOperatorArtifacts.abi,
      deployedNetwork.address
    )
    console.log('regulator')
    console.log(regulator)
    } catch (error) {
      console.error('Something aint right yo')
      console.error(error)
    }
  },

  checkBalance: async () => {
    const recipient = document.getElementById('individualVehicleAddress').value
  },

  changeVehicleType: async () => {
    const { setVehicleType } = this.regulator.methods
    let vehicleType = parseInt(document.getElementById('vehicleType').value)
    let recipient = document.getElementById('address').value
    await setVehicleType(vehicleType, recipient).send({ from: this.account }) 
  },

  updateRoutePrice: async () => {
    const { setRoutePrice } = this.regulator.methods

    const entryBooth = document.getElementById('entryBooth').value
    const exitBooth = document.getElementById('exitBooth').value
    const amount = parseInt(document.getElementById('routePriceAmount').value)

    await setRoutePrice(entryBooth, exitBooth, amount).send({ from: this.account })
  },

  reportVehicleExit: async() => {
    const { reportExitRoad } = this.tollBoothOperator.methods
    const individualVehicleAddress = document.getElementById('individualVehicleAddress').value
    await reportExitRoad(individualVehicleAddress).send({ from: this.account })
  },

  setStatus: (message) => {
    const status = document.getElementById('status')
    status.innerHTML = message
  },

  createNewOperator: async() => {
    const operatorAddress = document.getElementById('receiver').value
    const operatorDeposit = parseInt(document.getElementById('operatorDeposit').value)
  }
}

window.App = App

window.addEventListener('load', () => {
  if (window.ethereum) {
    // use MetaMask's provider
    App.web3 = new Web3(window.ethereum)
    window.ethereum.enable() // get permission to access accounts
  } else {
    console.warn(
      'No web3 detected. Falling back to http://127.0.0.1:8545. You should remove this fallback when you deploy live',
    )
    // fallback - use your fallback strategy (local node / hosted node + in-dapp id mgmt / fail)
    App.web3 = new Web3(
      new Web3.providers.HttpProvider('http://127.0.0.1:8545'),
    )
  }
  console.log(App.web3)
  App.start()
})
