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

let addressBalance = 0

const Promise = require('bluebird')

let regulatorContract
let toolBoothOperatorContract

const App = {
  web3: null,
  account: null,
  meta: null,

  start: async () => {
    const web3 = await getWeb3
    
    console.log('START: web3')
    console.log(web3)
    Promise.promisifyAll(web3.web3.eth, {
      suffix: 'Promise'
    })
    console.log('Regulator artifacts: ')
    console.log(regulatorArtifacts.abi)
    console.log('Gas estimate: ')
    console.log('Web3 eth')
    console.log(web3.web3.eth)
    console.log('Regulator new')
    console.log(regulatorContract)
    console.log('Coinbase: ')
    console.log(web3.web3.eth.accounts.length)
    console.log('Regulator address')
    console.log(web3.web3.eth.getCoinbase)
  },

  checkBalance: async () => {
    const recipient = document.getElementById('individualVehicleAddress').value
  },

  setVehicleType: async () => {
    console.log(await web3.eth.getCoinbase)
    let vehicleType = parseInt(document.getElementById('vehicleType').value)
    let recipient = document.getElementById('address').value
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
    const entryBooth = document.getElementById('entryBooth').value
    const exitBooth = document.getElementById('exitBooth').value
    const amount = parseInt(document.getElementById('routePriceAmount').value)
  },

  reportExitRoad: async() => {
    const individualVehicleAddress = document.getElementById('individualVehicleAddress').value
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
  App.start()
})
