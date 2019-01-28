  // Import the page's CSS. Webpack will know what to do with it.
  import '../styles/app.css'

  // Import libraries we need
  import {
    default as Web3
  } from 'web3'
  import {
    default as contract
  } from 'truffle-contract'
  // Import our contract artifacts and turn them into usable abstractions.
  import multiplierArtifacts from '../../build/contracts/MultiplierHolder.json'
  import regulatorArtifacts from '../../build/contracts/Regulator.json'
  import routePriceHolderArtifacts from '../../build/contracts/RoutePriceHolder.json'
  import tollBoothOperatorArtifacts from '../../build/contracts/TollBoothOperator.json'
  import tollBoothHolderArtifacts from '../../build/contracts/TollBoothHolder.json'

  // MetaCoin is our usable abstraction, which we'll use through the code below.

  var MultiplierHolder = contract(multiplierArtifacts)
  var Regulator = contract(regulatorArtifacts)
  var RoutePriceHolder = contract(routePriceHolderArtifacts)
  var TollBoothOperator = contract(tollBoothOperatorArtifacts)
  var TollBoothHolder = contract(tollBoothHolderArtifacts)

  console.log(JSON.stringify(Web3))

  // The following code is simple to show off interacting with your contracts.
  // As your needs grow you will likely need to change its form and structure.
  // For application bootstrapping, check out window.addEventListener below.
  var accounts
  var account

  window.App = {

      start: function () {
        var self = this

        setVehicleType: () => {
            var self = this

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
          }

          createNewOperator: () => {
            var self = this

            let deposit = parseInt(document.getElementById('deposit').value)
            let newOperatorAddress = document.getElementById('newOperatorAddress').value

            let regulatorInstance
            Regulator.deployed().then((instance) => {
              regulatorInstance = instance
              return regulatorInstance.createNewOperator(newOperatorAddress, deposit, {
                from: account
              })
            }).then(() => {
              self.setStatus('Vehicle type set')
              self.refreshBalance()
            }).catch((e) => {
              console.log(e)
              self.setStatus('An error occured while setting vehicle type')
            })
          }

          addTollBooth: () => {
            var self = this

            let createdTollBoothAddress = document.getElementById('createdTollBooth').value

            let tollBoothHolderInstance
            TollBoothHolder.deployed().then((instance) => {
              tollBoothHolderInstance = instance
              return tollBoothHolderInstance.addTollBooth(createdTollBoothAddress, {
                from: account
              })
            }).then(() => {
              self.setStatus('New toll booth added: ' + createdTollBoothAddress)
              self.refreshBalance()
            }).catch((e) => {
              console.log(e)
              self.setStatus('An error occured while setting vehicle type')
            })
          }

          setRoutePrice: () => {
            var self = this

            let entryBooth = document.getElementById('entryBooth').value
            let exitBooth = document.getElementById('exitBooth').value
            let priceWeis = parseInt(document.getElementById('priceWeis').value)

            let routePriceHolderInstance
            RoutePriceHolder.deployed().then((instance) => {
              routePriceHolderInstance = instance
              return routePriceHolderInstance.setRoutePrice(entryBooth, exitBooth, priceWeis, {
                from: account
              })
            }).then(() => {
              self.setStatus('Vehicle type set')
              self.refreshBalance()
            }).catch((e) => {
              console.log(e)
              self.setStatus('An error occured while setting vehicle type')
            })
          }

          setMultiplier: () => {
            var self = this

            let vehicleType = parseInt(document.getElementById('multiplierVehicleType').value)
            let multiplier = parseInt(document.getElementById('multiplier').value)

            let multiplierInstance
            MultiplierHolder.deployed().then((instance) => {
              multiplierInstance = instance
              return multiplierInstance.setMultiplier(vehicleType, multiplier, {
                from: account
              })
            }).then(() => {
              self.setStatus('Multiplier set')
              self.refreshBalance()
            }).catch((e) => {
              console.log(e)
              self.setStatus('An error occured while setting multiplier type')
            })
          }
      }
    }