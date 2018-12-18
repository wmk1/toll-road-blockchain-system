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

  beforeEach('Deploying the necessary contracts before performing tests', async () => {
    regulator.instance = await Regulator.new({
      from: owner
    })
    regulatorInstance = regulator.instance
    await regulatorInstance.setVehicleType(vehicle, vehicleType, {
      from: owner
    })
    await regulatorInstance.setVehicleType(vehicle1, vehicleType1, {
      from: owner
    })
    let tx = await regulatorInstance.createNewOperator(owner1, deposit, {
      from: owner
    })
    tollBoothOperator.instance = await TollBoothOperator.at(tx.logs[1].args.newOperator)
    tollBoothOperatorInstance = tollBoothOperator.instance
    await tollBoothOperatorInstance.addTollBooth(booth, {
      from: owner1
    })
    await tollBoothOperatorInstance.addTollBooth(booth1, {
      from: owner1
    })
    await tollBoothOperatorInstance.setMultiplier(vehicleType, multiplier, {
      from: owner1
    })
    await tollBoothOperatorInstance.setMultiplier(vehicleType1, multiplier1, {
      from: owner1
    })
    await tollBoothOperatorInstance.setRoutePrice(booth, booth1, price, {
      from: owner1
    })
    await tollBoothOperatorInstance.setPaused(false, {
      from: owner1
    })
    hashed = await tollBoothOperatorInstance.hashSecret(secret)
    hashed1 = await tollBoothOperatorInstance.hashSecret(secret1)
  })

  it('1 - Given routeprice when is equal to deposit then no refund', async () => {
    //given
    await tollBoothOperatorInstance.enterRoad(booth, hashed, {
      from: vehicle,
      value: (deposit * multiplier)
    })
    await tollBoothOperatorInstance.setRoutePrice(booth, booth1, deposit, {
      from: owner1
    })

    // when
    const exitRoadTransaction = await tollBoothOperatorInstance.reportExitRoad(secret, {
      from: booth1
    })
    const transactionLogs = exitRoadTransaction.logs
    // then
    assert.equal(transactionLogs.length, 1, 'Wrong number of events')
    assert.equal(transactionLogs[0].event, 'LogRoadExited', 'Event name mismatched')
    assert.equal(transactionLogs[0].args.refundWeis.toNumber(), 0, 'Refund weis not correct')
  })

  it('2 - Given routeprice when is less than deposit then no refund', async () => {
    //given
    await tollBoothOperatorInstance.enterRoad(booth, hashed, {
      from: vehicle,
      value: (deposit * multiplier)
    })
    await tollBoothOperatorInstance.setRoutePrice(booth, booth1, deposit * 2, {
      from: owner1
    })

    // when
    const exitRoadTransaction = await tollBoothOperatorInstance.reportExitRoad(secret, {
      from: booth1
    })
    const transactionLogs = exitRoadTransaction.logs
    // then
    assert.equal(transactionLogs.length, 1, 'Wrong number of events')
    assert.equal(transactionLogs[0].event, 'LogRoadExited', 'Event name mismatched')
    assert.equal(transactionLogs[0].args.refundWeis.toNumber(), 0, 'Refund weis not correct')
  })

  it('3 - Given routeprice when is bigger than deposit then refund is issued', async () => {
    //given
    await tollBoothOperatorInstance.enterRoad(booth, hashed, {
      from: vehicle,
      value: (deposit * multiplier)
    })
    await tollBoothOperatorInstance.setRoutePrice(booth, booth1, deposit - 3, {
      from: owner1
    })

    // when
    const exitRoadTransaction = await tollBoothOperatorInstance.reportExitRoad(secret, {
      from: booth1
    })
    const transactionLogs = exitRoadTransaction.logs
    // then
    assert.equal(transactionLogs.length, 1, 'Wrong number of events')
    assert.equal(transactionLogs[0].event, 'LogRoadExited', 'Event name mismatched')
    assert.equal(transactionLogs[0].args.refundWeis.toNumber(), 3 * multiplier, 'Refund weis not correct')
  })

  it('4 - Given amount deposited when is greater than deposit and routeprice is equal to deposit then refund is issued', async () => {
    //given
    await tollBoothOperatorInstance.enterRoad(booth, hashed, {
      from: vehicle,
      value: (deposit * multiplier + 5 * multiplier)
    })
    await tollBoothOperatorInstance.setRoutePrice(booth, booth1, deposit, {
      from: owner1
    })

    // when
    const exitRoadTransaction = await tollBoothOperatorInstance.reportExitRoad(secret, {
      from: booth1
    })
    const transactionLogs = exitRoadTransaction.logs
    // then
    assert.equal(transactionLogs.length, 1, 'Wrong number of events')
    assert.equal(transactionLogs[0].event, 'LogRoadExited', 'Event name mismatched')
    assert.equal(transactionLogs[0].args.refundWeis.toNumber(), 5 * multiplier, 'Refund weis not correct')
  })

  it('5 - Given amount deposited when is greater than deposit and routeprice is greater than deposit then refund is issued', async () => {
    //given
    await tollBoothOperatorInstance.enterRoad(booth, hashed, {
      from: vehicle,
      value: (deposit * multiplier + 5 * multiplier)
    })
    await tollBoothOperatorInstance.setRoutePrice(booth, booth1, deposit + 1, {
      from: owner1
    })

    // when
    const exitRoadTransaction = await tollBoothOperatorInstance.reportExitRoad(secret, {
      from: booth1
    })
    const transactionLogs = exitRoadTransaction.logs
    // then
    assert.equal(transactionLogs.length, 1, 'Wrong number of events')
    assert.equal(transactionLogs[0].event, 'LogRoadExited', 'Event name mismatched')
    assert.equal(transactionLogs[0].args.refundWeis.toNumber(), 4 * multiplier, 'Refund weis mismatched')
  })

  it('Given two vehicles when enter road then first in first out  queue case scenario goes successfully', async () => {
    //given
    await tollBoothOperatorInstance.enterRoad(booth1, hashed, {
      from: vehicle,
      value: (deposit * multiplier + 5 * multiplier)
    })
    await tollBoothOperatorInstance.reportExitRoad(secret, {
      from: booth
    })
    await tollBoothOperatorInstance.enterRoad(booth1, hashed1, {
      from: vehicle1,
      value: (deposit * multiplier1)
    })
    await tollBoothOperatorInstance.reportExitRoad(secret1, {
      from: booth
    })
    // when
    const exitRoadTransactionTwo = await tollBoothOperatorInstance.setRoutePrice(booth1, booth, deposit + 1, {
      from: owner1
    })
    const transactionLogs = exitRoadTransactionTwo.logs
    await tollBoothOperatorInstance.clearSomePendingPayments(booth1, booth, 1)
    // then
    assert.equal(transactionLogs.length, 2, 'Event count mismatched')
    assert.equal(transactionLogs[1].args.refundWeis.toNumber(), 4 * multiplier, 'Refund weis mismatched')
  })
})
