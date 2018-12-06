const Promise = require('bluebird')
Promise.promisifyAll(web3, { suffix: 'Promise' })
const assert = require('assert')

const toBytes32 = require('../utils/toBytes32.js')

if (typeof web3.eth.getAccountsPromise === 'undefined') {
  Promise.promisifyAll(web3.eth, { suffix: 'Promise' })
}

const Regulator = artifacts.require('./Regulator.sol')
const TollBoothOperator = artifacts.require('./TollBoothOperator.sol')

contract('Scenarios', accounts => {
  let owner, owner1
    let vehicle, vehicle1
    let booth, booth1
    let deposit
    let regulator
    let vehicleType, vehicleType1
    let price
    let multiplier, multiplier1
    let secret = toBytes32(1)
    let secret1 = toBytes32(2)
    let hashed, hashed1
    let tollBoothOperator

    before('Should set variables with values', () => {
      assert.isAtLeast(accounts.length, 6)
        owner = accounts[0]
        owner1 = accounts[1]
        vehicle = accounts[2]
        vehicle1 = accounts[3]
        booth = accounts[4]
        booth1 = accounts[5]
        deposit = 10
        vehicleType = 1
        vehicleType1 = 2
        price = 1
        multiplier = 32
        multiplier1 = 21
        return web3.eth.getBalancePromise(owner).then(balance => {
          assert.isAtLeast(web3.fromWei(balance).toNumber(), 10)
        })
    })

    beforeEach('Should deploy the necessary contracts', () => {
      return regulator = Regulator.new({ from: owner })
            .then(instance => regulator = instance)
            .then(() => regulator.setVehicleType(vehicle, vehicleType, { from: owner }))
            .then(tx => regulator.setVehicleType(vehicle1, vehicleType1, { from: owner }))
            .then(tx => regulator.createNewOperator(owner1, deposit, { from: owner }))
            .then(tx => tollBoothOperator = TollBoothOperator.at(tx.logs[1].args.newOperator))
            .then(() => tollBoothOperator.addTollBooth(booth, { from: owner1 }))
            .then(tx => tollBoothOperator.addTollBooth(booth1, { from: owner1 }))
            .then(tx => tollBoothOperator.setMultiplier(vehicleType, multiplier, { from: owner1 }))
            .then(tx => tollBoothOperator.setMultiplier(vehicleType1, multiplier1, { from: owner1 }))
            .then(tx => tollBoothOperator.setRoutePrice(booth, booth1, price, { from: owner1 }))
            .then(tx => tollBoothOperator.setPaused(false, { from: owner1 }))
            .then(tx => tollBoothOperator.hashSecret(secret))
            .then(hash => hashed = hash)
            .then(tx => tollBoothOperator.hashSecret(secret1))
            .then(hash => hashed1 = hash)
    })

    it('Given routeprice when is equal to deposit then no refund', () => {
        //given

        //when

        //then


    })
    it('given routeprice when is greater than deposit then no refund', () => {
        //given

        //when

        //then
    })
    
    it('given routeprice when is less than deposit then refund is issued', () => {
        //given

        //when

        //then
    })
    
    it('given amount deposited when is greater than deposit and routeprice equals deposit then refund is issued', () => {
        //given

        //when

        //then
    })
    
    it('given amount deposited when is greater than deposit and routeprice is greater than deposit then refund is issued', () => {
        //given

        //when

        //then
    })
    
    it('scenario 6 - FIFO queue test case', () => {
        //given

        //when

        //then
    })
})
