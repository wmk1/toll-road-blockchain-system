const assert = require('assert')

const toBytes32 = require('../utils/toBytes32.js')

// eslint-disable-next-line no-undef
const Regulator = artifacts.require('./Regulator.sol')
// eslint-disable-next-line no-undef
const TollBoothOperator = artifacts.require('./TollBoothOperator.sol')
// eslint-disable-next-line no-undef
contract('Scenarios', accounts => {
  let owner = accounts[0]
  let owner1 = accounts[1]
  let vehicle = accounts[2]
  let vehicle1 = accounts[3]
  let booth = accounts[4]
  let booth1 = accounts[5]
  let deposit = 10
  let vehicleType = 1
  let vehicleType1 = 2
  let routePrice = 10
  let multiplier = 32
  let multiplier1 = 21
  let secret = toBytes32(100)
  let secret1 = toBytes32(200)

  let hashed, hashed1

  let regulator
  let tollBoothOperator

  // eslint-disable-next-line no-undef
  beforeEach('Deploying the necessary contracts before performing tests', async () => {
    regulator = await Regulator.new({
      from: owner
    })
    await regulator.setVehicleType(vehicle, vehicleType, {
      from: owner
    })
    await regulator.setVehicleType(vehicle1, vehicleType1, {
      from: owner
    })
    let tx = await regulator.createNewOperator(owner1, deposit, {
      from: owner
    })
    tollBoothOperator = await TollBoothOperator.at(tx.logs[1].args.newOperator)
    await tollBoothOperator.addTollBooth(booth, {
      from: owner1
    })
    await tollBoothOperator.addTollBooth(booth1, {
      from: owner1
    })
    await tollBoothOperator.setMultiplier(vehicleType, multiplier, {
      from: owner1
    })
    await tollBoothOperator.setMultiplier(vehicleType1, multiplier1, {
      from: owner1
    })
    await tollBoothOperator.setPaused(false, {
      from: owner1
    })
    hashed = await tollBoothOperator.hashSecret(secret)
    hashed1 = await tollBoothOperator.hashSecret(secret1)
  })

// eslint-disable-next-line no-undef
  it('1 - Given routeprice when is equal to deposit then no refund', async () => {
    //given
    await tollBoothOperator.enterRoad(booth, hashed, {
      from: vehicle,
      value: (deposit * multiplier)
    })
    await tollBoothOperator.setRoutePrice(booth, booth1, deposit, {
      from: owner1
    })

    // when
    const exitRoadTransaction = await tollBoothOperator.reportExitRoad(secret, {
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
    await tollBoothOperator.enterRoad(booth, hashed, {
      from: vehicle,
      value: (deposit * multiplier)
    })
    await tollBoothOperator.setRoutePrice(booth, booth1, deposit * 2, {
      from: owner1
    })

    // when
    const exitRoadTransaction = await tollBoothOperator.reportExitRoad(secret, {
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
    await tollBoothOperator.enterRoad(booth, hashed, {
      from: vehicle,
      value: (deposit * multiplier)
    })
    await tollBoothOperator.setRoutePrice(booth, booth1, deposit - 3, {
      from: owner1
    })
    // when
    const exitRoadTransaction = await tollBoothOperator.reportExitRoad(secret, {
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
    await tollBoothOperator.enterRoad(booth, hashed, {
      from: vehicle,
      value: (deposit * multiplier + 5 * multiplier)
    })
    await tollBoothOperator.setRoutePrice(booth, booth1, deposit, {
      from: owner1
    })

    // when
    const exitRoadTransaction = await tollBoothOperator.reportExitRoad(secret, {
      from: booth1
    })
    const transactionLogs = exitRoadTransaction.logs
    // then
    assert.equal(transactionLogs.length, 1, 'Wrong number of events')
    assert.equal(transactionLogs[0].event, 'LogRoadExited', 'Event name mismatched')
    assert.equal(transactionLogs[0].args.refundWeis.toNumber(), 5 * multiplier, 'Refund weis not correct')
  })

  it('5 - Given amount deposited when is greater than deposit and routeprice is unknown than deposit then refund is issued', async () => {
    //given
    await tollBoothOperator.enterRoad(booth, hashed, {
      from: vehicle,
      value: (deposit * multiplier + 5 * multiplier)
    })
    await tollBoothOperator.reportExitRoad(secret, {
      from: booth1
    })
    // when
    const transaction = await tollBoothOperator.setRoutePrice(booth, booth1, deposit, {
      from: owner1
    })
    const transactionLogs = transaction.logs
    const logRoadExitedRefundedWeis = transactionLogs.find(l => l.event === 'LogRoadExited').args.refundWeis
    // then
    assert.equal(transactionLogs.length, 2, 'Wrong number of events')
    assert.equal(transactionLogs[0].event, 'LogRoutePriceSet', 'Event name mismatched')
    assert.equal(logRoadExitedRefundedWeis, 160, 'Refund weis mismatched')
  })

  it('6 - Given two vehicles when enter road with unknown price then after clear pending payment count proper refund is issued', async () => {
    //given
    await tollBoothOperator.enterRoad(booth1, hashed, {
      from: vehicle,
      value: (deposit * multiplier + 5 * multiplier)
    })
    await tollBoothOperator.reportExitRoad(secret, {
      from: booth
    })
    await tollBoothOperator.enterRoad(booth1, hashed1, {
      from: vehicle1,
      value: (deposit * multiplier1)
    })
    await tollBoothOperator.reportExitRoad(secret1, {
      from: booth
    })

    // when
    const exitRoadTransaction = await tollBoothOperator.setRoutePrice(booth1, booth, deposit + 1, {
      from: owner1
    })
    const exitRoadLogs = exitRoadTransaction.logs
    console.log(await tollBoothOperator.getPendingPaymentCount(booth, booth1))
    
    // then
    assert.equal(exitRoadLogs[0].event, 'LogRoutePriceSet', 'Event name mismatched')
    assert.equal(exitRoadLogs[1].args.refundWeis.toNumber(), 4 * multiplier, 'Refund weis mismatched')
    assert.equal(await tollBoothOperator.getPendingPaymentCount(booth, booth1), 0)
  })
})
