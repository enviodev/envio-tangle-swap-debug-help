// TODO: move to `eventFetching`

let factoryAbi = `
[{"type":"event","name":"PoolCreated","inputs":[{"name":"token0","type":"address","indexed":true},{"name":"token1","type":"address","indexed":true},{"name":"fee","type":"uint24","indexed":true},{"name":"tickSpacing","type":"int24","indexed":false},{"name":"pool","type":"address","indexed":false}],"anonymous":false}]
`->Js.Json.parseExn
let nonfungiblePositionManagerAbi = `
[{"type":"event","name":"DecreaseLiquidity","inputs":[{"name":"tokenId","type":"uint256","indexed":true},{"name":"liquidity","type":"uint128","indexed":false},{"name":"amount0","type":"uint256","indexed":false},{"name":"amount1","type":"uint256","indexed":false}],"anonymous":false},{"type":"event","name":"IncreaseLiquidity","inputs":[{"name":"tokenId","type":"uint256","indexed":true},{"name":"liquidity","type":"uint128","indexed":false},{"name":"amount0","type":"uint256","indexed":false},{"name":"amount1","type":"uint256","indexed":false}],"anonymous":false},{"type":"event","name":"Transfer","inputs":[{"name":"from","type":"address","indexed":true},{"name":"to","type":"address","indexed":true},{"name":"tokenId","type":"uint256","indexed":true}],"anonymous":false}]
`->Js.Json.parseExn
let poolAbi = `
[{"type":"event","name":"Swap","inputs":[{"name":"sender","type":"address","indexed":true},{"name":"recipient","type":"address","indexed":true},{"name":"amount0","type":"int256","indexed":false},{"name":"amount1","type":"int256","indexed":false},{"name":"sqrtPriceX96","type":"uint160","indexed":false},{"name":"liquidity","type":"uint128","indexed":false},{"name":"tick","type":"int24","indexed":false}],"anonymous":false}]
`->Js.Json.parseExn
