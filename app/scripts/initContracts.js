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

let initContracts = async () => {
  
}




export default initContracts