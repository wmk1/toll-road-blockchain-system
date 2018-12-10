const assert = require('assert')

const toBytes32 = require('../utils/toBytes32.js')

const Regulator = artifacts.require('./Regulator.sol')
const TollBoothOperator = artifacts.require('./TollBoothOperator.sol')

contract('Scenarios', accounts => {
  let regulator = {}
  let tollBoothOperator = {}
  let owner = accounts[0]
  let owner1 = accounts[1]
  let vehicle = accounts[2]
  let vehicle1 = accounts[3]
  let booth = accounts[4]
  let booth1 = accounts[5]
  let deposit = 10
  let vehicleType = 1
  let vehicleType1 = 2
  let price = 1
  let multiplier = 32
  let multiplier1 = 21
  let secret = toBytes32(100)
  let secret1 = toBytes32(200)

  let hashed, hashed1

  let regulatorInstance
  let tollBoothOperatorInstance
 
  beforeEach('Should deploy the necessary contracts', async () => {
    regulator.instance = await Regulator.new({ from: owner })
    regulatorInstance = regulator.instance
    await regulatorInstance.setVehicleType(vehicle, vehicleType, { from: owner })
    await regulatorInstance.setVehicleType(vehicle1, vehicleType1, { from: owner })
    let tx = await regulatorInstance.createNewOperator(owner1, deposit, { from: owner })
    tollBoothOperator.instance = await TollBoothOperator.at(tx.logs[1].args.newOperator)
    tollBoothOperatorInstance = tollBoothOperator.instance
    await tollBoothOperatorInstance.addTollBooth(booth, { from: owner1 })
    await tollBoothOperatorInstance.addTollBooth(booth1, { from: owner1 })
    await tollBoothOperatorInstance.setMultiplier(vehicleType, multiplier, { from: owner1 })
    await tollBoothOperatorInstance.setMultiplier(vehicleType1, multiplier1, { from: owner1 })
    await tollBoothOperatorInstance.setRoutePrice(booth, booth1, price, { from: owner1 })
    hashed = tollBoothOperatorInstance.hashSecret(secret)
    hashed1 = tollBoothOperatorInstance.hashSecret(secret1)
  })

  it('Given routeprice when is equal to deposit then no refund', () => {
    //given

    // when
    const transaction = tollBoothOperatorInstance
    .enterRoad
    .call(booth, hashed, { from: vehicle, value: (deposit * multiplier) })
    const events = transaction.logs
    console.log(transaction)

    // then
    assert.equal(events.length, 1, 'Wrong number of events')
    
  })

  it('Given routeprice when is less than deposit then no refund', async () => {
    //given



    // when
    const transaction = await tollBoothOperatorInstance
    .enterRoad(booth, hashed, { from: vehicle, value: (deposit * multiplier) })
    const events = transaction.logs

    // then
    assert.equal(events.length, 1, 'Wrong number of events')
    
  })

  it('Given routeprice when is bigger than deposit then refund is issued', () => {
    //given



    // when
    const transaction = tollBoothOperatorInstance
    .enterRoad
    .call(booth, hashed, { from: vehicle, value: (deposit * multiplier) })
    const events = transaction.logs

    // then
    assert.equal(events.length, 1, 'Wrong number of events')
    
  })

  it('Given amount deposited when is greater than deposit and routeprice is equal to deposit then refund is issued', () => {
    //given

    // when
    const transaction = tollBoothOperatorInstance
    .enterRoad
    .call(booth, hashed, { from: vehicle, value: (deposit * multiplier) })
    const events = transaction.logs

    // then
    assert.equal(events.length, 1, 'Wrong number of events')
    
  })

  it('Given amount deposited when is greater than deposit and routeprice is greater than deposit then refund is issued', () => {
    //given



    // when
    const transaction = tollBoothOperatorInstance
    .enterRoad
    .call(booth, hashed, { from: vehicle, value: (deposit * multiplier) })
    const events = transaction.logs

    // then
    assert.equal(events.length, 1, 'Wrong number of events')
    
  })

  it('Given two vehicles when enter road then fifo queue case goes successfully', () => {
    //given



    // when
    const transaction = tollBoothOperatorInstance
    .enterRoad
    .call(booth, hashed, { from: vehicle, value: (deposit * multiplier) })
    const events = transaction.logs

    // then
    assert.equal(events.length, 1, 'Wrong number of events')
    
  })
})
