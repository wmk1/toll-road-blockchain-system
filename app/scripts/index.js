import getWeb3 from './getWeb3.js'
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

const regulatorAddress = '0xc9ae4a38cec6999610951f4c7d7765aaa8ac4e29'

const App = {
  web3: null,
  account: null,
  meta: null,

  start: async () => {
    const web3 = await getWeb3
    console.log(web3)
  },

  checkBalance: async () => {
    const recipient = document.getElementById('individualVehicleAddress').value
  },

  setVehicleType: async () => {
    let vehicleType = parseInt(document.getElementById('vehicleType').value)
    let recipient = document.getElementById('address').value
    console.log('Regulator artifacts: ')
    console.log(regulatorArtifacts.abi)
    let regulator = web3.eth.contract(JSON.stringify(regulatorArtifacts))
    const regulatorContract = await contract({
      abi: regulatorArtifacts.abi
    })
    regulatorContract.setProvider(web3.currentProvider)
    console.log(regulatorContract)
    console.log('Regulator abi: ')
    console.log(regulator.abi)
    console.log('Gas estimate: ')
    console.log(web3.eth.gasEstimate)
    console.log('Web3')
    console.log(web3)
    console.log('Regulator new')
    console.log(regulatorContract)
    await regulatorContract.at(regulatorAddress)
      .then(instance => {
        instance.setVehicleType(vehicleType, recipient, {
          from: this.account
        })
      }).then(console.log('Success!'))
   /* let gasEstimate = await this.web3.eth.estimateGasPromise({
      data: regulatorArtifacts.bytecode
    })
    console.log(gasEstimate)
    const regulatorInstance = await Regulator.new({
      data: regulatorArtifacts.bytecode,
      from: this.state.accounts[0],
      gas: gasEstimate
    })
    Promise.promisifyAll(regulatorInstance, { suffix: 'Promise' })
    console.log(regulatorInstance)
    this.setState({
      regulatorInstance: regulatorInstance
    })*/
  },

  sendCoin: async () => {
    const amount = parseInt(document.getElementById("amount").value)
    const receiver = document.getElementById("receiver").value

    this.setStatus("Initiating transaction... (please wait)")

    const { sendCoin } = this.meta.methods
    await sendCoin(receiver, amount).send({ from: this.account })

    this.setStatus('Transaction complete!')
    this.refreshBalance()
  },

  setRoutePrice: async () => {
    const entryBooth = document.getElementById("entryBooth").value
    const exitBooth = document.getElementById("exitBooth").value
    const amount = parseInt(document.getElementById("routePriceAmount").value)
  },

  setStatus: (message) => {
    const status = document.getElementById("status")
    status.innerHTML = message
  },

  createNewOperator: async() => {
    const operatorAddress = document.getElementById('receiver').value
    const operatorDeposit = parseInt(document.getElementById('operatorDeposit').value)
  }
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
    // fallbaxck - use your fallback strategy (local node / hosted node + in-dapp id mgmt / fail)
    App.web3 = new Web3(
      new Web3.providers.HttpProvider("http://127.0.0.1:8545"),
    )
  }

  App.start()
})