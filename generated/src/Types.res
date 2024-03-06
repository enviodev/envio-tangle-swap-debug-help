//*************
//***ENTITIES**
//*************
@spice @genType.as("Id")
type id = string

@@warning("-30")
@genType
type rec bundleLoaderConfig = bool
and burnLoaderConfig = {
  loadTransaction?: transactionLoaderConfig,
  loadToken0?: tokenLoaderConfig,
  loadPool?: poolLoaderConfig,
  loadToken1?: tokenLoaderConfig,
}
and collectLoaderConfig = {loadTransaction?: transactionLoaderConfig, loadPool?: poolLoaderConfig}
and factoryLoaderConfig = bool
and flashLoaderConfig = {loadPool?: poolLoaderConfig, loadTransaction?: transactionLoaderConfig}
and mintLoaderConfig = {
  loadToken0?: tokenLoaderConfig,
  loadTransaction?: transactionLoaderConfig,
  loadPool?: poolLoaderConfig,
  loadToken1?: tokenLoaderConfig,
}
and poolLoaderConfig = {loadToken1?: tokenLoaderConfig, loadToken0?: tokenLoaderConfig}
and poolDayDataLoaderConfig = {loadPool?: poolLoaderConfig}
and poolHourDataLoaderConfig = {loadPool?: poolLoaderConfig}
and positionLoaderConfig = {
  loadToken1?: tokenLoaderConfig,
  loadToken0?: tokenLoaderConfig,
  loadTickLower?: tickLoaderConfig,
  loadTransaction?: transactionLoaderConfig,
  loadPool?: poolLoaderConfig,
  loadTickUpper?: tickLoaderConfig,
}
and positionSnapshotLoaderConfig = {
  loadPool?: poolLoaderConfig,
  loadPosition?: positionLoaderConfig,
  loadTransaction?: transactionLoaderConfig,
}
and swapLoaderConfig = {
  loadTick?: tickLoaderConfig,
  loadTransaction?: transactionLoaderConfig,
  loadToken1?: tokenLoaderConfig,
  loadToken0?: tokenLoaderConfig,
  loadPool?: poolLoaderConfig,
}
and tickLoaderConfig = {loadPool?: poolLoaderConfig}
and tickDayDataLoaderConfig = {loadPool?: poolLoaderConfig, loadTick?: tickLoaderConfig}
and tickHourDataLoaderConfig = {loadTick?: tickLoaderConfig, loadPool?: poolLoaderConfig}
and tokenLoaderConfig = bool
and tokenDayDataLoaderConfig = {loadToken?: tokenLoaderConfig}
and tokenHourDataLoaderConfig = {loadToken?: tokenLoaderConfig}
and tokenPoolWhitelistLoaderConfig = {loadToken?: tokenLoaderConfig, loadPool?: poolLoaderConfig}
and transactionLoaderConfig = bool
and uniswapDayDataLoaderConfig = bool

@@warning("+30")
@genType
type entityRead =
  | BundleRead(id)
  | BurnRead(id, burnLoaderConfig)
  | CollectRead(id, collectLoaderConfig)
  | FactoryRead(id)
  | FlashRead(id, flashLoaderConfig)
  | MintRead(id, mintLoaderConfig)
  | PoolRead(id, poolLoaderConfig)
  | PoolDayDataRead(id, poolDayDataLoaderConfig)
  | PoolHourDataRead(id, poolHourDataLoaderConfig)
  | PositionRead(id, positionLoaderConfig)
  | PositionSnapshotRead(id, positionSnapshotLoaderConfig)
  | SwapRead(id, swapLoaderConfig)
  | TickRead(id, tickLoaderConfig)
  | TickDayDataRead(id, tickDayDataLoaderConfig)
  | TickHourDataRead(id, tickHourDataLoaderConfig)
  | TokenRead(id)
  | TokenDayDataRead(id, tokenDayDataLoaderConfig)
  | TokenHourDataRead(id, tokenHourDataLoaderConfig)
  | TokenPoolWhitelistRead(id, tokenPoolWhitelistLoaderConfig)
  | TransactionRead(id)
  | UniswapDayDataRead(id)

@genType
type rawEventsEntity = {
  @as("chain_id") chainId: int,
  @as("event_id") eventId: string,
  @as("block_number") blockNumber: int,
  @as("log_index") logIndex: int,
  @as("transaction_index") transactionIndex: int,
  @as("transaction_hash") transactionHash: string,
  @as("src_address") srcAddress: Ethers.ethAddress,
  @as("block_hash") blockHash: string,
  @as("block_timestamp") blockTimestamp: int,
  @as("event_type") eventType: Js.Json.t,
  params: string,
}

@genType
type dynamicContractRegistryEntity = {
  @as("chain_id") chainId: int,
  @as("event_id") eventId: Ethers.BigInt.t,
  @as("contract_address") contractAddress: Ethers.ethAddress,
  @as("contract_type") contractType: string,
}

@spice @genType.as("BundleEntity")
type bundleEntity = {
  id: id,
  ethPriceUSD: float,
}

@spice @genType.as("BurnEntity")
type burnEntity = {
  timestamp: Ethers.BigInt.t,
  transaction_id: id,
  token0_id: id,
  tickLower: Ethers.BigInt.t,
  pool_id: id,
  amountUSD: option<float>,
  amount0: float,
  tickUpper: Ethers.BigInt.t,
  amount1: float,
  id: id,
  owner: option<string>,
  amount: Ethers.BigInt.t,
  token1_id: id,
  origin: string,
  logIndex: option<Ethers.BigInt.t>,
}

@spice @genType.as("CollectEntity")
type collectEntity = {
  amountUSD: option<float>,
  owner: option<string>,
  id: id,
  amount0: float,
  transaction_id: id,
  timestamp: Ethers.BigInt.t,
  pool_id: id,
  amount1: float,
  tickLower: Ethers.BigInt.t,
  tickUpper: Ethers.BigInt.t,
  logIndex: option<Ethers.BigInt.t>,
}

@spice @genType.as("FactoryEntity")
type factoryEntity = {
  totalValueLockedUSD: float,
  id: id,
  totalFeesETH: float,
  totalValueLockedETHUntracked: float,
  totalValueLockedUSDUntracked: float,
  totalValueLockedETH: float,
  owner: id,
  totalVolumeUSD: float,
  txCount: Ethers.BigInt.t,
  totalFeesUSD: float,
  poolCount: Ethers.BigInt.t,
  untrackedVolumeUSD: float,
  totalVolumeETH: float,
}

@spice @genType.as("FlashEntity")
type flashEntity = {
  timestamp: Ethers.BigInt.t,
  sender: string,
  id: id,
  pool_id: id,
  amount1: float,
  amountUSD: float,
  amount0: float,
  amount0Paid: float,
  amount1Paid: float,
  logIndex: option<Ethers.BigInt.t>,
  transaction_id: id,
  recipient: string,
}

@spice @genType.as("MintEntity")
type mintEntity = {
  sender: option<string>,
  origin: string,
  amount: Ethers.BigInt.t,
  amount0: float,
  tickUpper: Ethers.BigInt.t,
  logIndex: option<Ethers.BigInt.t>,
  token0_id: id,
  amountUSD: option<float>,
  transaction_id: id,
  pool_id: id,
  amount1: float,
  tickLower: Ethers.BigInt.t,
  id: id,
  timestamp: Ethers.BigInt.t,
  token1_id: id,
  owner: string,
}

@spice @genType.as("PoolEntity")
type poolEntity = {
  token1_id: id,
  volumeToken1: float,
  id: id,
  token0_id: id,
  txCount: Ethers.BigInt.t,
  tick: option<Ethers.BigInt.t>,
  liquidity: Ethers.BigInt.t,
  observationIndex: Ethers.BigInt.t,
  feeTier: Ethers.BigInt.t,
  untrackedVolumeUSD: float,
  collectedFeesUSD: float,
  volumeToken0: float,
  totalValueLockedUSD: float,
  token1Price: float,
  feeGrowthGlobal0X128: Ethers.BigInt.t,
  totalValueLockedToken1: float,
  liquidityProviderCount: Ethers.BigInt.t,
  collectedFeesToken1: float,
  volumeUSD: float,
  createdAtTimestamp: Ethers.BigInt.t,
  feeGrowthGlobal1X128: Ethers.BigInt.t,
  sqrtPrice: Ethers.BigInt.t,
  totalValueLockedToken0: float,
  totalValueLockedETH: float,
  totalValueLockedUSDUntracked: float,
  feesUSD: float,
  collectedFeesToken0: float,
  token0Price: float,
  createdAtBlockNumber: Ethers.BigInt.t,
}

@spice @genType.as("PoolDayDataEntity")
type poolDayDataEntity = {
  tick: option<Ethers.BigInt.t>,
  feeGrowthGlobal1X128: Ethers.BigInt.t,
  volumeUSD: float,
  sqrtPrice: Ethers.BigInt.t,
  feesUSD: float,
  liquidity: Ethers.BigInt.t,
  txCount: Ethers.BigInt.t,
  openPrice0: float,
  volumeToken0: float,
  high: float,
  low: float,
  tvlUSD: float,
  date: int,
  token1Price: float,
  close: float,
  token0Price: float,
  pool_id: id,
  feeGrowthGlobal0X128: Ethers.BigInt.t,
  volumeToken1: float,
  id: id,
}

@spice @genType.as("PoolHourDataEntity")
type poolHourDataEntity = {
  token1Price: float,
  feesUSD: float,
  liquidity: Ethers.BigInt.t,
  sqrtPrice: Ethers.BigInt.t,
  volumeToken1: float,
  pool_id: id,
  tick: option<Ethers.BigInt.t>,
  feeGrowthGlobal1X128: Ethers.BigInt.t,
  volumeUSD: float,
  high: float,
  openPrice0: float,
  token0Price: float,
  feeGrowthGlobal0X128: Ethers.BigInt.t,
  txCount: Ethers.BigInt.t,
  close: float,
  tvlUSD: float,
  volumeToken0: float,
  periodStartUnix: int,
  id: id,
  low: float,
}

@spice @genType.as("PositionEntity")
type positionEntity = {
  owner: string,
  feeGrowthInside0LastX128: Ethers.BigInt.t,
  liquidity: Ethers.BigInt.t,
  token1_id: id,
  token0_id: id,
  tickLower_id: id,
  transaction_id: id,
  collectedFeesToken1: float,
  feeGrowthInside1LastX128: Ethers.BigInt.t,
  id: id,
  pool_id: id,
  withdrawnToken1: float,
  collectedToken1: float,
  depositedToken0: float,
  withdrawnToken0: float,
  depositedToken1: float,
  collectedToken0: float,
  tickUpper_id: id,
  collectedFeesToken0: float,
}

@spice @genType.as("PositionSnapshotEntity")
type positionSnapshotEntity = {
  owner: string,
  depositedToken1: float,
  feeGrowthInside0LastX128: Ethers.BigInt.t,
  withdrawnToken1: float,
  id: id,
  timestamp: Ethers.BigInt.t,
  pool_id: id,
  position_id: id,
  liquidity: Ethers.BigInt.t,
  collectedFeesToken0: float,
  transaction_id: id,
  depositedToken0: float,
  feeGrowthInside1LastX128: Ethers.BigInt.t,
  collectedFeesToken1: float,
  blockNumber: Ethers.BigInt.t,
  withdrawnToken0: float,
}

@spice @genType.as("SwapEntity")
type swapEntity = {
  origin: string,
  sqrtPriceX96: Ethers.BigInt.t,
  tick_id: id,
  amount0: float,
  transaction_id: id,
  timestamp: Ethers.BigInt.t,
  amount1: float,
  token1_id: id,
  logIndex: option<Ethers.BigInt.t>,
  sender: string,
  recipient: string,
  amountUSD: float,
  token0_id: id,
  id: id,
  pool_id: id,
}

@spice @genType.as("TickEntity")
type tickEntity = {
  collectedFeesToken1: float,
  createdAtTimestamp: Ethers.BigInt.t,
  createdAtBlockNumber: Ethers.BigInt.t,
  id: id,
  liquidityNet: Ethers.BigInt.t,
  volumeToken0: float,
  volumeToken1: float,
  collectedFeesToken0: float,
  collectedFeesUSD: float,
  feeGrowthOutside1X128: Ethers.BigInt.t,
  price1: float,
  liquidityProviderCount: Ethers.BigInt.t,
  feeGrowthOutside0X128: Ethers.BigInt.t,
  liquidityGross: Ethers.BigInt.t,
  volumeUSD: float,
  price0: float,
  untrackedVolumeUSD: float,
  poolAddress: option<string>,
  feesUSD: float,
  pool_id: id,
  tickIdx: Ethers.BigInt.t,
}

@spice @genType.as("TickDayDataEntity")
type tickDayDataEntity = {
  feesUSD: float,
  pool_id: id,
  tick_id: id,
  date: int,
  liquidityNet: Ethers.BigInt.t,
  feeGrowthOutside0X128: Ethers.BigInt.t,
  volumeUSD: float,
  feeGrowthOutside1X128: Ethers.BigInt.t,
  volumeToken1: float,
  id: id,
  volumeToken0: float,
  liquidityGross: Ethers.BigInt.t,
}

@spice @genType.as("TickHourDataEntity")
type tickHourDataEntity = {
  id: id,
  tick_id: id,
  liquidityGross: Ethers.BigInt.t,
  volumeToken0: float,
  liquidityNet: Ethers.BigInt.t,
  volumeUSD: float,
  pool_id: id,
  feesUSD: float,
  periodStartUnix: int,
  volumeToken1: float,
}

@spice @genType.as("TokenEntity")
type tokenEntity = {
  txCount: Ethers.BigInt.t,
  untrackedVolumeUSD: float,
  derivedETH: float,
  name: string,
  symbol: string,
  feesUSD: float,
  totalValueLocked: float,
  id: id,
  volumeUSD: float,
  totalSupply: Ethers.BigInt.t,
  poolCount: Ethers.BigInt.t,
  decimals: Ethers.BigInt.t,
  volume: float,
  totalValueLockedUSDUntracked: float,
  totalValueLockedUSD: float,
}

@spice @genType.as("TokenDayDataEntity")
type tokenDayDataEntity = {
  high: float,
  totalValueLocked: float,
  low: float,
  feesUSD: float,
  close: float,
  volumeUSD: float,
  volume: float,
  untrackedVolumeUSD: float,
  totalValueLockedUSD: float,
  priceUSD: float,
  date: int,
  token_id: id,
  openPrice: float,
  id: id,
}

@spice @genType.as("TokenHourDataEntity")
type tokenHourDataEntity = {
  untrackedVolumeUSD: float,
  token_id: id,
  priceUSD: float,
  openPrice: float,
  totalValueLockedUSD: float,
  volume: float,
  id: id,
  feesUSD: float,
  close: float,
  low: float,
  high: float,
  periodStartUnix: int,
  totalValueLocked: float,
  volumeUSD: float,
}

@spice @genType.as("TokenPoolWhitelistEntity")
type tokenPoolWhitelistEntity = {
  token_id: id,
  pool_id: id,
  id: id,
}

@spice @genType.as("TransactionEntity")
type transactionEntity = {
  blockNumber: Ethers.BigInt.t,
  id: id,
  timestamp: Ethers.BigInt.t,
  gasPrice: Ethers.BigInt.t,
  gasUsed: Ethers.BigInt.t,
}

@spice @genType.as("UniswapDayDataEntity")
type uniswapDayDataEntity = {
  volumeUSD: float,
  feesUSD: float,
  id: id,
  tvlUSD: float,
  txCount: Ethers.BigInt.t,
  volumeETH: float,
  volumeUSDUntracked: float,
  date: int,
}

type entity =
  | BundleEntity(bundleEntity)
  | BurnEntity(burnEntity)
  | CollectEntity(collectEntity)
  | FactoryEntity(factoryEntity)
  | FlashEntity(flashEntity)
  | MintEntity(mintEntity)
  | PoolEntity(poolEntity)
  | PoolDayDataEntity(poolDayDataEntity)
  | PoolHourDataEntity(poolHourDataEntity)
  | PositionEntity(positionEntity)
  | PositionSnapshotEntity(positionSnapshotEntity)
  | SwapEntity(swapEntity)
  | TickEntity(tickEntity)
  | TickDayDataEntity(tickDayDataEntity)
  | TickHourDataEntity(tickHourDataEntity)
  | TokenEntity(tokenEntity)
  | TokenDayDataEntity(tokenDayDataEntity)
  | TokenHourDataEntity(tokenHourDataEntity)
  | TokenPoolWhitelistEntity(tokenPoolWhitelistEntity)
  | TransactionEntity(transactionEntity)
  | UniswapDayDataEntity(uniswapDayDataEntity)

type dbOp = Read | Set | Delete

@genType
type inMemoryStoreRow<'a> = {
  dbOp: dbOp,
  entity: 'a,
}

//*************
//**CONTRACTS**
//*************

@genType.as("EventLog")
type eventLog<'a> = {
  params: 'a,
  chainId: int,
  txOrigin: option<Ethers.ethAddress>,
  blockNumber: int,
  blockTimestamp: int,
  blockHash: string,
  srcAddress: Ethers.ethAddress,
  transactionHash: string,
  transactionIndex: int,
  logIndex: int,
}

module FactoryContract = {
  module PoolCreatedEvent = {
    //Note: each parameter is using a binding of its index to help with binding in ethers
    //This handles both unamed params and also named params that clash with reserved keywords
    //eg. if an event param is called "values" it will clash since eventArgs will have a '.values()' iterator
    type ethersEventArgs = {
      @as("0") token0: Ethers.ethAddress,
      @as("1") token1: Ethers.ethAddress,
      @as("2") fee: Ethers.BigInt.t,
      @as("3") tickSpacing: Ethers.BigInt.t,
      @as("4") pool: Ethers.ethAddress,
    }

    @spice @genType
    type eventArgs = {
      token0: Ethers.ethAddress,
      token1: Ethers.ethAddress,
      fee: Ethers.BigInt.t,
      tickSpacing: Ethers.BigInt.t,
      pool: Ethers.ethAddress,
    }

    @genType.as("FactoryContract_PoolCreated_EventLog")
    type log = eventLog<eventArgs>

    // Entity: Bundle
    type bundleEntityHandlerContext = {
      set: bundleEntity => unit,
      delete: id => unit,
    }

    type bundleEntityHandlerContextAsync = {
      set: bundleEntity => unit,
      delete: id => unit,
    }

    // Entity: Burn
    type burnEntityHandlerContext = {
      getTransaction: burnEntity => transactionEntity,
      getToken0: burnEntity => tokenEntity,
      getPool: burnEntity => poolEntity,
      getToken1: burnEntity => tokenEntity,
      set: burnEntity => unit,
      delete: id => unit,
    }

    type burnEntityHandlerContextAsync = {
      getTransaction: burnEntity => promise<transactionEntity>,
      getToken0: burnEntity => promise<tokenEntity>,
      getPool: burnEntity => promise<poolEntity>,
      getToken1: burnEntity => promise<tokenEntity>,
      set: burnEntity => unit,
      delete: id => unit,
    }

    // Entity: Collect
    type collectEntityHandlerContext = {
      getTransaction: collectEntity => transactionEntity,
      getPool: collectEntity => poolEntity,
      set: collectEntity => unit,
      delete: id => unit,
    }

    type collectEntityHandlerContextAsync = {
      getTransaction: collectEntity => promise<transactionEntity>,
      getPool: collectEntity => promise<poolEntity>,
      set: collectEntity => unit,
      delete: id => unit,
    }

    // Entity: Factory
    type factoryEntityHandlerContext = {
      get: id => option<factoryEntity>,
      set: factoryEntity => unit,
      delete: id => unit,
    }

    type factoryEntityHandlerContextAsync = {
      get: id => promise<option<factoryEntity>>,
      set: factoryEntity => unit,
      delete: id => unit,
    }

    // Entity: Flash
    type flashEntityHandlerContext = {
      getPool: flashEntity => poolEntity,
      getTransaction: flashEntity => transactionEntity,
      set: flashEntity => unit,
      delete: id => unit,
    }

    type flashEntityHandlerContextAsync = {
      getPool: flashEntity => promise<poolEntity>,
      getTransaction: flashEntity => promise<transactionEntity>,
      set: flashEntity => unit,
      delete: id => unit,
    }

    // Entity: Mint
    type mintEntityHandlerContext = {
      getToken0: mintEntity => tokenEntity,
      getTransaction: mintEntity => transactionEntity,
      getPool: mintEntity => poolEntity,
      getToken1: mintEntity => tokenEntity,
      set: mintEntity => unit,
      delete: id => unit,
    }

    type mintEntityHandlerContextAsync = {
      getToken0: mintEntity => promise<tokenEntity>,
      getTransaction: mintEntity => promise<transactionEntity>,
      getPool: mintEntity => promise<poolEntity>,
      getToken1: mintEntity => promise<tokenEntity>,
      set: mintEntity => unit,
      delete: id => unit,
    }

    // Entity: Pool
    type poolEntityHandlerContext = {
      get: id => option<poolEntity>,
      getToken1: poolEntity => tokenEntity,
      getToken0: poolEntity => tokenEntity,
      set: poolEntity => unit,
      delete: id => unit,
    }

    type poolEntityHandlerContextAsync = {
      get: id => promise<option<poolEntity>>,
      getToken1: poolEntity => promise<tokenEntity>,
      getToken0: poolEntity => promise<tokenEntity>,
      set: poolEntity => unit,
      delete: id => unit,
    }

    // Entity: PoolDayData
    type poolDayDataEntityHandlerContext = {
      getPool: poolDayDataEntity => poolEntity,
      set: poolDayDataEntity => unit,
      delete: id => unit,
    }

    type poolDayDataEntityHandlerContextAsync = {
      getPool: poolDayDataEntity => promise<poolEntity>,
      set: poolDayDataEntity => unit,
      delete: id => unit,
    }

    // Entity: PoolHourData
    type poolHourDataEntityHandlerContext = {
      getPool: poolHourDataEntity => poolEntity,
      set: poolHourDataEntity => unit,
      delete: id => unit,
    }

    type poolHourDataEntityHandlerContextAsync = {
      getPool: poolHourDataEntity => promise<poolEntity>,
      set: poolHourDataEntity => unit,
      delete: id => unit,
    }

    // Entity: Position
    type positionEntityHandlerContext = {
      getToken1: positionEntity => tokenEntity,
      getToken0: positionEntity => tokenEntity,
      getTickLower: positionEntity => tickEntity,
      getTransaction: positionEntity => transactionEntity,
      getPool: positionEntity => poolEntity,
      getTickUpper: positionEntity => tickEntity,
      set: positionEntity => unit,
      delete: id => unit,
    }

    type positionEntityHandlerContextAsync = {
      getToken1: positionEntity => promise<tokenEntity>,
      getToken0: positionEntity => promise<tokenEntity>,
      getTickLower: positionEntity => promise<tickEntity>,
      getTransaction: positionEntity => promise<transactionEntity>,
      getPool: positionEntity => promise<poolEntity>,
      getTickUpper: positionEntity => promise<tickEntity>,
      set: positionEntity => unit,
      delete: id => unit,
    }

    // Entity: PositionSnapshot
    type positionSnapshotEntityHandlerContext = {
      getPool: positionSnapshotEntity => poolEntity,
      getPosition: positionSnapshotEntity => positionEntity,
      getTransaction: positionSnapshotEntity => transactionEntity,
      set: positionSnapshotEntity => unit,
      delete: id => unit,
    }

    type positionSnapshotEntityHandlerContextAsync = {
      getPool: positionSnapshotEntity => promise<poolEntity>,
      getPosition: positionSnapshotEntity => promise<positionEntity>,
      getTransaction: positionSnapshotEntity => promise<transactionEntity>,
      set: positionSnapshotEntity => unit,
      delete: id => unit,
    }

    // Entity: Swap
    type swapEntityHandlerContext = {
      getTick: swapEntity => tickEntity,
      getTransaction: swapEntity => transactionEntity,
      getToken1: swapEntity => tokenEntity,
      getToken0: swapEntity => tokenEntity,
      getPool: swapEntity => poolEntity,
      set: swapEntity => unit,
      delete: id => unit,
    }

    type swapEntityHandlerContextAsync = {
      getTick: swapEntity => promise<tickEntity>,
      getTransaction: swapEntity => promise<transactionEntity>,
      getToken1: swapEntity => promise<tokenEntity>,
      getToken0: swapEntity => promise<tokenEntity>,
      getPool: swapEntity => promise<poolEntity>,
      set: swapEntity => unit,
      delete: id => unit,
    }

    // Entity: Tick
    type tickEntityHandlerContext = {
      getPool: tickEntity => poolEntity,
      set: tickEntity => unit,
      delete: id => unit,
    }

    type tickEntityHandlerContextAsync = {
      getPool: tickEntity => promise<poolEntity>,
      set: tickEntity => unit,
      delete: id => unit,
    }

    // Entity: TickDayData
    type tickDayDataEntityHandlerContext = {
      getPool: tickDayDataEntity => poolEntity,
      getTick: tickDayDataEntity => tickEntity,
      set: tickDayDataEntity => unit,
      delete: id => unit,
    }

    type tickDayDataEntityHandlerContextAsync = {
      getPool: tickDayDataEntity => promise<poolEntity>,
      getTick: tickDayDataEntity => promise<tickEntity>,
      set: tickDayDataEntity => unit,
      delete: id => unit,
    }

    // Entity: TickHourData
    type tickHourDataEntityHandlerContext = {
      getTick: tickHourDataEntity => tickEntity,
      getPool: tickHourDataEntity => poolEntity,
      set: tickHourDataEntity => unit,
      delete: id => unit,
    }

    type tickHourDataEntityHandlerContextAsync = {
      getTick: tickHourDataEntity => promise<tickEntity>,
      getPool: tickHourDataEntity => promise<poolEntity>,
      set: tickHourDataEntity => unit,
      delete: id => unit,
    }

    // Entity: Token
    type tokenEntityHandlerContext = {
      get: id => option<tokenEntity>,
      set: tokenEntity => unit,
      delete: id => unit,
    }

    type tokenEntityHandlerContextAsync = {
      get: id => promise<option<tokenEntity>>,
      set: tokenEntity => unit,
      delete: id => unit,
    }

    // Entity: TokenDayData
    type tokenDayDataEntityHandlerContext = {
      getToken: tokenDayDataEntity => tokenEntity,
      set: tokenDayDataEntity => unit,
      delete: id => unit,
    }

    type tokenDayDataEntityHandlerContextAsync = {
      getToken: tokenDayDataEntity => promise<tokenEntity>,
      set: tokenDayDataEntity => unit,
      delete: id => unit,
    }

    // Entity: TokenHourData
    type tokenHourDataEntityHandlerContext = {
      getToken: tokenHourDataEntity => tokenEntity,
      set: tokenHourDataEntity => unit,
      delete: id => unit,
    }

    type tokenHourDataEntityHandlerContextAsync = {
      getToken: tokenHourDataEntity => promise<tokenEntity>,
      set: tokenHourDataEntity => unit,
      delete: id => unit,
    }

    // Entity: TokenPoolWhitelist
    type tokenPoolWhitelistEntityHandlerContext = {
      get: id => option<tokenPoolWhitelistEntity>,
      getToken: tokenPoolWhitelistEntity => tokenEntity,
      getPool: tokenPoolWhitelistEntity => poolEntity,
      set: tokenPoolWhitelistEntity => unit,
      delete: id => unit,
    }

    type tokenPoolWhitelistEntityHandlerContextAsync = {
      get: id => promise<option<tokenPoolWhitelistEntity>>,
      getToken: tokenPoolWhitelistEntity => promise<tokenEntity>,
      getPool: tokenPoolWhitelistEntity => promise<poolEntity>,
      set: tokenPoolWhitelistEntity => unit,
      delete: id => unit,
    }

    // Entity: Transaction
    type transactionEntityHandlerContext = {
      set: transactionEntity => unit,
      delete: id => unit,
    }

    type transactionEntityHandlerContextAsync = {
      set: transactionEntity => unit,
      delete: id => unit,
    }

    // Entity: UniswapDayData
    type uniswapDayDataEntityHandlerContext = {
      set: uniswapDayDataEntity => unit,
      delete: id => unit,
    }

    type uniswapDayDataEntityHandlerContextAsync = {
      set: uniswapDayDataEntity => unit,
      delete: id => unit,
    }

    @genType
    type handlerContext = {
      log: Logs.userLogger,
      @as("Bundle") bundle: bundleEntityHandlerContext,
      @as("Burn") burn: burnEntityHandlerContext,
      @as("Collect") collect: collectEntityHandlerContext,
      @as("Factory") factory: factoryEntityHandlerContext,
      @as("Flash") flash: flashEntityHandlerContext,
      @as("Mint") mint: mintEntityHandlerContext,
      @as("Pool") pool: poolEntityHandlerContext,
      @as("PoolDayData") poolDayData: poolDayDataEntityHandlerContext,
      @as("PoolHourData") poolHourData: poolHourDataEntityHandlerContext,
      @as("Position") position: positionEntityHandlerContext,
      @as("PositionSnapshot") positionSnapshot: positionSnapshotEntityHandlerContext,
      @as("Swap") swap: swapEntityHandlerContext,
      @as("Tick") tick: tickEntityHandlerContext,
      @as("TickDayData") tickDayData: tickDayDataEntityHandlerContext,
      @as("TickHourData") tickHourData: tickHourDataEntityHandlerContext,
      @as("Token") token: tokenEntityHandlerContext,
      @as("TokenDayData") tokenDayData: tokenDayDataEntityHandlerContext,
      @as("TokenHourData") tokenHourData: tokenHourDataEntityHandlerContext,
      @as("TokenPoolWhitelist") tokenPoolWhitelist: tokenPoolWhitelistEntityHandlerContext,
      @as("Transaction") transaction: transactionEntityHandlerContext,
      @as("UniswapDayData") uniswapDayData: uniswapDayDataEntityHandlerContext,
    }
    @genType
    type handlerContextAsync = {
      log: Logs.userLogger,
      @as("Bundle") bundle: bundleEntityHandlerContextAsync,
      @as("Burn") burn: burnEntityHandlerContextAsync,
      @as("Collect") collect: collectEntityHandlerContextAsync,
      @as("Factory") factory: factoryEntityHandlerContextAsync,
      @as("Flash") flash: flashEntityHandlerContextAsync,
      @as("Mint") mint: mintEntityHandlerContextAsync,
      @as("Pool") pool: poolEntityHandlerContextAsync,
      @as("PoolDayData") poolDayData: poolDayDataEntityHandlerContextAsync,
      @as("PoolHourData") poolHourData: poolHourDataEntityHandlerContextAsync,
      @as("Position") position: positionEntityHandlerContextAsync,
      @as("PositionSnapshot") positionSnapshot: positionSnapshotEntityHandlerContextAsync,
      @as("Swap") swap: swapEntityHandlerContextAsync,
      @as("Tick") tick: tickEntityHandlerContextAsync,
      @as("TickDayData") tickDayData: tickDayDataEntityHandlerContextAsync,
      @as("TickHourData") tickHourData: tickHourDataEntityHandlerContextAsync,
      @as("Token") token: tokenEntityHandlerContextAsync,
      @as("TokenDayData") tokenDayData: tokenDayDataEntityHandlerContextAsync,
      @as("TokenHourData") tokenHourData: tokenHourDataEntityHandlerContextAsync,
      @as("TokenPoolWhitelist") tokenPoolWhitelist: tokenPoolWhitelistEntityHandlerContextAsync,
      @as("Transaction") transaction: transactionEntityHandlerContextAsync,
      @as("UniswapDayData") uniswapDayData: uniswapDayDataEntityHandlerContextAsync,
    }

    @genType
    type poolEntityLoaderContext = {load: (id, ~loaders: poolLoaderConfig=?) => unit}
    @genType
    type factoryEntityLoaderContext = {load: id => unit}
    @genType
    type tokenEntityLoaderContext = {load: id => unit}
    @genType
    type tokenPoolWhitelistEntityLoaderContext = {
      load: (id, ~loaders: tokenPoolWhitelistLoaderConfig=?) => unit,
    }

    @genType
    type contractRegistrations = {
      //TODO only add contracts we've registered for the event in the config
      addFactory: Ethers.ethAddress => unit,
      //TODO only add contracts we've registered for the event in the config
      addNonfungiblePositionManager: Ethers.ethAddress => unit,
      //TODO only add contracts we've registered for the event in the config
      addPool: Ethers.ethAddress => unit,
    }
    @genType
    type loaderContext = {
      log: Logs.userLogger,
      contractRegistration: contractRegistrations,
      @as("Pool") pool: poolEntityLoaderContext,
      @as("Factory") factory: factoryEntityLoaderContext,
      @as("Token") token: tokenEntityLoaderContext,
      @as("TokenPoolWhitelist") tokenPoolWhitelist: tokenPoolWhitelistEntityLoaderContext,
    }
  }
}
module NonfungiblePositionManagerContract = {
  module IncreaseLiquidityEvent = {
    //Note: each parameter is using a binding of its index to help with binding in ethers
    //This handles both unamed params and also named params that clash with reserved keywords
    //eg. if an event param is called "values" it will clash since eventArgs will have a '.values()' iterator
    type ethersEventArgs = {
      @as("0") tokenId: Ethers.BigInt.t,
      @as("1") liquidity: Ethers.BigInt.t,
      @as("2") amount0: Ethers.BigInt.t,
      @as("3") amount1: Ethers.BigInt.t,
    }

    @spice @genType
    type eventArgs = {
      tokenId: Ethers.BigInt.t,
      liquidity: Ethers.BigInt.t,
      amount0: Ethers.BigInt.t,
      amount1: Ethers.BigInt.t,
    }

    @genType.as("NonfungiblePositionManagerContract_IncreaseLiquidity_EventLog")
    type log = eventLog<eventArgs>

    // Entity: Bundle
    type bundleEntityHandlerContext = {
      set: bundleEntity => unit,
      delete: id => unit,
    }

    type bundleEntityHandlerContextAsync = {
      set: bundleEntity => unit,
      delete: id => unit,
    }

    // Entity: Burn
    type burnEntityHandlerContext = {
      getTransaction: burnEntity => transactionEntity,
      getToken0: burnEntity => tokenEntity,
      getPool: burnEntity => poolEntity,
      getToken1: burnEntity => tokenEntity,
      set: burnEntity => unit,
      delete: id => unit,
    }

    type burnEntityHandlerContextAsync = {
      getTransaction: burnEntity => promise<transactionEntity>,
      getToken0: burnEntity => promise<tokenEntity>,
      getPool: burnEntity => promise<poolEntity>,
      getToken1: burnEntity => promise<tokenEntity>,
      set: burnEntity => unit,
      delete: id => unit,
    }

    // Entity: Collect
    type collectEntityHandlerContext = {
      getTransaction: collectEntity => transactionEntity,
      getPool: collectEntity => poolEntity,
      set: collectEntity => unit,
      delete: id => unit,
    }

    type collectEntityHandlerContextAsync = {
      getTransaction: collectEntity => promise<transactionEntity>,
      getPool: collectEntity => promise<poolEntity>,
      set: collectEntity => unit,
      delete: id => unit,
    }

    // Entity: Factory
    type factoryEntityHandlerContext = {
      set: factoryEntity => unit,
      delete: id => unit,
    }

    type factoryEntityHandlerContextAsync = {
      set: factoryEntity => unit,
      delete: id => unit,
    }

    // Entity: Flash
    type flashEntityHandlerContext = {
      getPool: flashEntity => poolEntity,
      getTransaction: flashEntity => transactionEntity,
      set: flashEntity => unit,
      delete: id => unit,
    }

    type flashEntityHandlerContextAsync = {
      getPool: flashEntity => promise<poolEntity>,
      getTransaction: flashEntity => promise<transactionEntity>,
      set: flashEntity => unit,
      delete: id => unit,
    }

    // Entity: Mint
    type mintEntityHandlerContext = {
      getToken0: mintEntity => tokenEntity,
      getTransaction: mintEntity => transactionEntity,
      getPool: mintEntity => poolEntity,
      getToken1: mintEntity => tokenEntity,
      set: mintEntity => unit,
      delete: id => unit,
    }

    type mintEntityHandlerContextAsync = {
      getToken0: mintEntity => promise<tokenEntity>,
      getTransaction: mintEntity => promise<transactionEntity>,
      getPool: mintEntity => promise<poolEntity>,
      getToken1: mintEntity => promise<tokenEntity>,
      set: mintEntity => unit,
      delete: id => unit,
    }

    // Entity: Pool
    type poolEntityHandlerContext = {
      getToken1: poolEntity => tokenEntity,
      getToken0: poolEntity => tokenEntity,
      set: poolEntity => unit,
      delete: id => unit,
    }

    type poolEntityHandlerContextAsync = {
      getToken1: poolEntity => promise<tokenEntity>,
      getToken0: poolEntity => promise<tokenEntity>,
      set: poolEntity => unit,
      delete: id => unit,
    }

    // Entity: PoolDayData
    type poolDayDataEntityHandlerContext = {
      getPool: poolDayDataEntity => poolEntity,
      set: poolDayDataEntity => unit,
      delete: id => unit,
    }

    type poolDayDataEntityHandlerContextAsync = {
      getPool: poolDayDataEntity => promise<poolEntity>,
      set: poolDayDataEntity => unit,
      delete: id => unit,
    }

    // Entity: PoolHourData
    type poolHourDataEntityHandlerContext = {
      getPool: poolHourDataEntity => poolEntity,
      set: poolHourDataEntity => unit,
      delete: id => unit,
    }

    type poolHourDataEntityHandlerContextAsync = {
      getPool: poolHourDataEntity => promise<poolEntity>,
      set: poolHourDataEntity => unit,
      delete: id => unit,
    }

    // Entity: Position
    type positionEntityHandlerContext = {
      get: id => option<positionEntity>,
      getToken1: positionEntity => tokenEntity,
      getToken0: positionEntity => tokenEntity,
      getTickLower: positionEntity => tickEntity,
      getTransaction: positionEntity => transactionEntity,
      getPool: positionEntity => poolEntity,
      getTickUpper: positionEntity => tickEntity,
      set: positionEntity => unit,
      delete: id => unit,
    }

    type positionEntityHandlerContextAsync = {
      get: id => promise<option<positionEntity>>,
      getToken1: positionEntity => promise<tokenEntity>,
      getToken0: positionEntity => promise<tokenEntity>,
      getTickLower: positionEntity => promise<tickEntity>,
      getTransaction: positionEntity => promise<transactionEntity>,
      getPool: positionEntity => promise<poolEntity>,
      getTickUpper: positionEntity => promise<tickEntity>,
      set: positionEntity => unit,
      delete: id => unit,
    }

    // Entity: PositionSnapshot
    type positionSnapshotEntityHandlerContext = {
      get: id => option<positionSnapshotEntity>,
      getPool: positionSnapshotEntity => poolEntity,
      getPosition: positionSnapshotEntity => positionEntity,
      getTransaction: positionSnapshotEntity => transactionEntity,
      set: positionSnapshotEntity => unit,
      delete: id => unit,
    }

    type positionSnapshotEntityHandlerContextAsync = {
      get: id => promise<option<positionSnapshotEntity>>,
      getPool: positionSnapshotEntity => promise<poolEntity>,
      getPosition: positionSnapshotEntity => promise<positionEntity>,
      getTransaction: positionSnapshotEntity => promise<transactionEntity>,
      set: positionSnapshotEntity => unit,
      delete: id => unit,
    }

    // Entity: Swap
    type swapEntityHandlerContext = {
      getTick: swapEntity => tickEntity,
      getTransaction: swapEntity => transactionEntity,
      getToken1: swapEntity => tokenEntity,
      getToken0: swapEntity => tokenEntity,
      getPool: swapEntity => poolEntity,
      set: swapEntity => unit,
      delete: id => unit,
    }

    type swapEntityHandlerContextAsync = {
      getTick: swapEntity => promise<tickEntity>,
      getTransaction: swapEntity => promise<transactionEntity>,
      getToken1: swapEntity => promise<tokenEntity>,
      getToken0: swapEntity => promise<tokenEntity>,
      getPool: swapEntity => promise<poolEntity>,
      set: swapEntity => unit,
      delete: id => unit,
    }

    // Entity: Tick
    type tickEntityHandlerContext = {
      getPool: tickEntity => poolEntity,
      set: tickEntity => unit,
      delete: id => unit,
    }

    type tickEntityHandlerContextAsync = {
      getPool: tickEntity => promise<poolEntity>,
      set: tickEntity => unit,
      delete: id => unit,
    }

    // Entity: TickDayData
    type tickDayDataEntityHandlerContext = {
      getPool: tickDayDataEntity => poolEntity,
      getTick: tickDayDataEntity => tickEntity,
      set: tickDayDataEntity => unit,
      delete: id => unit,
    }

    type tickDayDataEntityHandlerContextAsync = {
      getPool: tickDayDataEntity => promise<poolEntity>,
      getTick: tickDayDataEntity => promise<tickEntity>,
      set: tickDayDataEntity => unit,
      delete: id => unit,
    }

    // Entity: TickHourData
    type tickHourDataEntityHandlerContext = {
      getTick: tickHourDataEntity => tickEntity,
      getPool: tickHourDataEntity => poolEntity,
      set: tickHourDataEntity => unit,
      delete: id => unit,
    }

    type tickHourDataEntityHandlerContextAsync = {
      getTick: tickHourDataEntity => promise<tickEntity>,
      getPool: tickHourDataEntity => promise<poolEntity>,
      set: tickHourDataEntity => unit,
      delete: id => unit,
    }

    // Entity: Token
    type tokenEntityHandlerContext = {
      get: id => option<tokenEntity>,
      set: tokenEntity => unit,
      delete: id => unit,
    }

    type tokenEntityHandlerContextAsync = {
      get: id => promise<option<tokenEntity>>,
      set: tokenEntity => unit,
      delete: id => unit,
    }

    // Entity: TokenDayData
    type tokenDayDataEntityHandlerContext = {
      getToken: tokenDayDataEntity => tokenEntity,
      set: tokenDayDataEntity => unit,
      delete: id => unit,
    }

    type tokenDayDataEntityHandlerContextAsync = {
      getToken: tokenDayDataEntity => promise<tokenEntity>,
      set: tokenDayDataEntity => unit,
      delete: id => unit,
    }

    // Entity: TokenHourData
    type tokenHourDataEntityHandlerContext = {
      getToken: tokenHourDataEntity => tokenEntity,
      set: tokenHourDataEntity => unit,
      delete: id => unit,
    }

    type tokenHourDataEntityHandlerContextAsync = {
      getToken: tokenHourDataEntity => promise<tokenEntity>,
      set: tokenHourDataEntity => unit,
      delete: id => unit,
    }

    // Entity: TokenPoolWhitelist
    type tokenPoolWhitelistEntityHandlerContext = {
      getToken: tokenPoolWhitelistEntity => tokenEntity,
      getPool: tokenPoolWhitelistEntity => poolEntity,
      set: tokenPoolWhitelistEntity => unit,
      delete: id => unit,
    }

    type tokenPoolWhitelistEntityHandlerContextAsync = {
      getToken: tokenPoolWhitelistEntity => promise<tokenEntity>,
      getPool: tokenPoolWhitelistEntity => promise<poolEntity>,
      set: tokenPoolWhitelistEntity => unit,
      delete: id => unit,
    }

    // Entity: Transaction
    type transactionEntityHandlerContext = {
      set: transactionEntity => unit,
      delete: id => unit,
    }

    type transactionEntityHandlerContextAsync = {
      set: transactionEntity => unit,
      delete: id => unit,
    }

    // Entity: UniswapDayData
    type uniswapDayDataEntityHandlerContext = {
      set: uniswapDayDataEntity => unit,
      delete: id => unit,
    }

    type uniswapDayDataEntityHandlerContextAsync = {
      set: uniswapDayDataEntity => unit,
      delete: id => unit,
    }

    @genType
    type handlerContext = {
      log: Logs.userLogger,
      @as("Bundle") bundle: bundleEntityHandlerContext,
      @as("Burn") burn: burnEntityHandlerContext,
      @as("Collect") collect: collectEntityHandlerContext,
      @as("Factory") factory: factoryEntityHandlerContext,
      @as("Flash") flash: flashEntityHandlerContext,
      @as("Mint") mint: mintEntityHandlerContext,
      @as("Pool") pool: poolEntityHandlerContext,
      @as("PoolDayData") poolDayData: poolDayDataEntityHandlerContext,
      @as("PoolHourData") poolHourData: poolHourDataEntityHandlerContext,
      @as("Position") position: positionEntityHandlerContext,
      @as("PositionSnapshot") positionSnapshot: positionSnapshotEntityHandlerContext,
      @as("Swap") swap: swapEntityHandlerContext,
      @as("Tick") tick: tickEntityHandlerContext,
      @as("TickDayData") tickDayData: tickDayDataEntityHandlerContext,
      @as("TickHourData") tickHourData: tickHourDataEntityHandlerContext,
      @as("Token") token: tokenEntityHandlerContext,
      @as("TokenDayData") tokenDayData: tokenDayDataEntityHandlerContext,
      @as("TokenHourData") tokenHourData: tokenHourDataEntityHandlerContext,
      @as("TokenPoolWhitelist") tokenPoolWhitelist: tokenPoolWhitelistEntityHandlerContext,
      @as("Transaction") transaction: transactionEntityHandlerContext,
      @as("UniswapDayData") uniswapDayData: uniswapDayDataEntityHandlerContext,
    }
    @genType
    type handlerContextAsync = {
      log: Logs.userLogger,
      @as("Bundle") bundle: bundleEntityHandlerContextAsync,
      @as("Burn") burn: burnEntityHandlerContextAsync,
      @as("Collect") collect: collectEntityHandlerContextAsync,
      @as("Factory") factory: factoryEntityHandlerContextAsync,
      @as("Flash") flash: flashEntityHandlerContextAsync,
      @as("Mint") mint: mintEntityHandlerContextAsync,
      @as("Pool") pool: poolEntityHandlerContextAsync,
      @as("PoolDayData") poolDayData: poolDayDataEntityHandlerContextAsync,
      @as("PoolHourData") poolHourData: poolHourDataEntityHandlerContextAsync,
      @as("Position") position: positionEntityHandlerContextAsync,
      @as("PositionSnapshot") positionSnapshot: positionSnapshotEntityHandlerContextAsync,
      @as("Swap") swap: swapEntityHandlerContextAsync,
      @as("Tick") tick: tickEntityHandlerContextAsync,
      @as("TickDayData") tickDayData: tickDayDataEntityHandlerContextAsync,
      @as("TickHourData") tickHourData: tickHourDataEntityHandlerContextAsync,
      @as("Token") token: tokenEntityHandlerContextAsync,
      @as("TokenDayData") tokenDayData: tokenDayDataEntityHandlerContextAsync,
      @as("TokenHourData") tokenHourData: tokenHourDataEntityHandlerContextAsync,
      @as("TokenPoolWhitelist") tokenPoolWhitelist: tokenPoolWhitelistEntityHandlerContextAsync,
      @as("Transaction") transaction: transactionEntityHandlerContextAsync,
      @as("UniswapDayData") uniswapDayData: uniswapDayDataEntityHandlerContextAsync,
    }

    @genType
    type positionEntityLoaderContext = {load: (id, ~loaders: positionLoaderConfig=?) => unit}
    @genType
    type positionSnapshotEntityLoaderContext = {
      load: (id, ~loaders: positionSnapshotLoaderConfig=?) => unit,
    }
    @genType
    type tokenEntityLoaderContext = {load: id => unit}

    @genType
    type contractRegistrations = {
      //TODO only add contracts we've registered for the event in the config
      addFactory: Ethers.ethAddress => unit,
      //TODO only add contracts we've registered for the event in the config
      addNonfungiblePositionManager: Ethers.ethAddress => unit,
      //TODO only add contracts we've registered for the event in the config
      addPool: Ethers.ethAddress => unit,
    }
    @genType
    type loaderContext = {
      log: Logs.userLogger,
      contractRegistration: contractRegistrations,
      @as("Position") position: positionEntityLoaderContext,
      @as("PositionSnapshot") positionSnapshot: positionSnapshotEntityLoaderContext,
      @as("Token") token: tokenEntityLoaderContext,
    }
  }
  module DecreaseLiquidityEvent = {
    //Note: each parameter is using a binding of its index to help with binding in ethers
    //This handles both unamed params and also named params that clash with reserved keywords
    //eg. if an event param is called "values" it will clash since eventArgs will have a '.values()' iterator
    type ethersEventArgs = {
      @as("0") tokenId: Ethers.BigInt.t,
      @as("1") liquidity: Ethers.BigInt.t,
      @as("2") amount0: Ethers.BigInt.t,
      @as("3") amount1: Ethers.BigInt.t,
    }

    @spice @genType
    type eventArgs = {
      tokenId: Ethers.BigInt.t,
      liquidity: Ethers.BigInt.t,
      amount0: Ethers.BigInt.t,
      amount1: Ethers.BigInt.t,
    }

    @genType.as("NonfungiblePositionManagerContract_DecreaseLiquidity_EventLog")
    type log = eventLog<eventArgs>

    // Entity: Bundle
    type bundleEntityHandlerContext = {
      set: bundleEntity => unit,
      delete: id => unit,
    }

    type bundleEntityHandlerContextAsync = {
      set: bundleEntity => unit,
      delete: id => unit,
    }

    // Entity: Burn
    type burnEntityHandlerContext = {
      getTransaction: burnEntity => transactionEntity,
      getToken0: burnEntity => tokenEntity,
      getPool: burnEntity => poolEntity,
      getToken1: burnEntity => tokenEntity,
      set: burnEntity => unit,
      delete: id => unit,
    }

    type burnEntityHandlerContextAsync = {
      getTransaction: burnEntity => promise<transactionEntity>,
      getToken0: burnEntity => promise<tokenEntity>,
      getPool: burnEntity => promise<poolEntity>,
      getToken1: burnEntity => promise<tokenEntity>,
      set: burnEntity => unit,
      delete: id => unit,
    }

    // Entity: Collect
    type collectEntityHandlerContext = {
      getTransaction: collectEntity => transactionEntity,
      getPool: collectEntity => poolEntity,
      set: collectEntity => unit,
      delete: id => unit,
    }

    type collectEntityHandlerContextAsync = {
      getTransaction: collectEntity => promise<transactionEntity>,
      getPool: collectEntity => promise<poolEntity>,
      set: collectEntity => unit,
      delete: id => unit,
    }

    // Entity: Factory
    type factoryEntityHandlerContext = {
      set: factoryEntity => unit,
      delete: id => unit,
    }

    type factoryEntityHandlerContextAsync = {
      set: factoryEntity => unit,
      delete: id => unit,
    }

    // Entity: Flash
    type flashEntityHandlerContext = {
      getPool: flashEntity => poolEntity,
      getTransaction: flashEntity => transactionEntity,
      set: flashEntity => unit,
      delete: id => unit,
    }

    type flashEntityHandlerContextAsync = {
      getPool: flashEntity => promise<poolEntity>,
      getTransaction: flashEntity => promise<transactionEntity>,
      set: flashEntity => unit,
      delete: id => unit,
    }

    // Entity: Mint
    type mintEntityHandlerContext = {
      getToken0: mintEntity => tokenEntity,
      getTransaction: mintEntity => transactionEntity,
      getPool: mintEntity => poolEntity,
      getToken1: mintEntity => tokenEntity,
      set: mintEntity => unit,
      delete: id => unit,
    }

    type mintEntityHandlerContextAsync = {
      getToken0: mintEntity => promise<tokenEntity>,
      getTransaction: mintEntity => promise<transactionEntity>,
      getPool: mintEntity => promise<poolEntity>,
      getToken1: mintEntity => promise<tokenEntity>,
      set: mintEntity => unit,
      delete: id => unit,
    }

    // Entity: Pool
    type poolEntityHandlerContext = {
      getToken1: poolEntity => tokenEntity,
      getToken0: poolEntity => tokenEntity,
      set: poolEntity => unit,
      delete: id => unit,
    }

    type poolEntityHandlerContextAsync = {
      getToken1: poolEntity => promise<tokenEntity>,
      getToken0: poolEntity => promise<tokenEntity>,
      set: poolEntity => unit,
      delete: id => unit,
    }

    // Entity: PoolDayData
    type poolDayDataEntityHandlerContext = {
      getPool: poolDayDataEntity => poolEntity,
      set: poolDayDataEntity => unit,
      delete: id => unit,
    }

    type poolDayDataEntityHandlerContextAsync = {
      getPool: poolDayDataEntity => promise<poolEntity>,
      set: poolDayDataEntity => unit,
      delete: id => unit,
    }

    // Entity: PoolHourData
    type poolHourDataEntityHandlerContext = {
      getPool: poolHourDataEntity => poolEntity,
      set: poolHourDataEntity => unit,
      delete: id => unit,
    }

    type poolHourDataEntityHandlerContextAsync = {
      getPool: poolHourDataEntity => promise<poolEntity>,
      set: poolHourDataEntity => unit,
      delete: id => unit,
    }

    // Entity: Position
    type positionEntityHandlerContext = {
      get: id => option<positionEntity>,
      getToken1: positionEntity => tokenEntity,
      getToken0: positionEntity => tokenEntity,
      getTickLower: positionEntity => tickEntity,
      getTransaction: positionEntity => transactionEntity,
      getPool: positionEntity => poolEntity,
      getTickUpper: positionEntity => tickEntity,
      set: positionEntity => unit,
      delete: id => unit,
    }

    type positionEntityHandlerContextAsync = {
      get: id => promise<option<positionEntity>>,
      getToken1: positionEntity => promise<tokenEntity>,
      getToken0: positionEntity => promise<tokenEntity>,
      getTickLower: positionEntity => promise<tickEntity>,
      getTransaction: positionEntity => promise<transactionEntity>,
      getPool: positionEntity => promise<poolEntity>,
      getTickUpper: positionEntity => promise<tickEntity>,
      set: positionEntity => unit,
      delete: id => unit,
    }

    // Entity: PositionSnapshot
    type positionSnapshotEntityHandlerContext = {
      get: id => option<positionSnapshotEntity>,
      getPool: positionSnapshotEntity => poolEntity,
      getPosition: positionSnapshotEntity => positionEntity,
      getTransaction: positionSnapshotEntity => transactionEntity,
      set: positionSnapshotEntity => unit,
      delete: id => unit,
    }

    type positionSnapshotEntityHandlerContextAsync = {
      get: id => promise<option<positionSnapshotEntity>>,
      getPool: positionSnapshotEntity => promise<poolEntity>,
      getPosition: positionSnapshotEntity => promise<positionEntity>,
      getTransaction: positionSnapshotEntity => promise<transactionEntity>,
      set: positionSnapshotEntity => unit,
      delete: id => unit,
    }

    // Entity: Swap
    type swapEntityHandlerContext = {
      getTick: swapEntity => tickEntity,
      getTransaction: swapEntity => transactionEntity,
      getToken1: swapEntity => tokenEntity,
      getToken0: swapEntity => tokenEntity,
      getPool: swapEntity => poolEntity,
      set: swapEntity => unit,
      delete: id => unit,
    }

    type swapEntityHandlerContextAsync = {
      getTick: swapEntity => promise<tickEntity>,
      getTransaction: swapEntity => promise<transactionEntity>,
      getToken1: swapEntity => promise<tokenEntity>,
      getToken0: swapEntity => promise<tokenEntity>,
      getPool: swapEntity => promise<poolEntity>,
      set: swapEntity => unit,
      delete: id => unit,
    }

    // Entity: Tick
    type tickEntityHandlerContext = {
      getPool: tickEntity => poolEntity,
      set: tickEntity => unit,
      delete: id => unit,
    }

    type tickEntityHandlerContextAsync = {
      getPool: tickEntity => promise<poolEntity>,
      set: tickEntity => unit,
      delete: id => unit,
    }

    // Entity: TickDayData
    type tickDayDataEntityHandlerContext = {
      getPool: tickDayDataEntity => poolEntity,
      getTick: tickDayDataEntity => tickEntity,
      set: tickDayDataEntity => unit,
      delete: id => unit,
    }

    type tickDayDataEntityHandlerContextAsync = {
      getPool: tickDayDataEntity => promise<poolEntity>,
      getTick: tickDayDataEntity => promise<tickEntity>,
      set: tickDayDataEntity => unit,
      delete: id => unit,
    }

    // Entity: TickHourData
    type tickHourDataEntityHandlerContext = {
      getTick: tickHourDataEntity => tickEntity,
      getPool: tickHourDataEntity => poolEntity,
      set: tickHourDataEntity => unit,
      delete: id => unit,
    }

    type tickHourDataEntityHandlerContextAsync = {
      getTick: tickHourDataEntity => promise<tickEntity>,
      getPool: tickHourDataEntity => promise<poolEntity>,
      set: tickHourDataEntity => unit,
      delete: id => unit,
    }

    // Entity: Token
    type tokenEntityHandlerContext = {
      get: id => option<tokenEntity>,
      set: tokenEntity => unit,
      delete: id => unit,
    }

    type tokenEntityHandlerContextAsync = {
      get: id => promise<option<tokenEntity>>,
      set: tokenEntity => unit,
      delete: id => unit,
    }

    // Entity: TokenDayData
    type tokenDayDataEntityHandlerContext = {
      getToken: tokenDayDataEntity => tokenEntity,
      set: tokenDayDataEntity => unit,
      delete: id => unit,
    }

    type tokenDayDataEntityHandlerContextAsync = {
      getToken: tokenDayDataEntity => promise<tokenEntity>,
      set: tokenDayDataEntity => unit,
      delete: id => unit,
    }

    // Entity: TokenHourData
    type tokenHourDataEntityHandlerContext = {
      getToken: tokenHourDataEntity => tokenEntity,
      set: tokenHourDataEntity => unit,
      delete: id => unit,
    }

    type tokenHourDataEntityHandlerContextAsync = {
      getToken: tokenHourDataEntity => promise<tokenEntity>,
      set: tokenHourDataEntity => unit,
      delete: id => unit,
    }

    // Entity: TokenPoolWhitelist
    type tokenPoolWhitelistEntityHandlerContext = {
      getToken: tokenPoolWhitelistEntity => tokenEntity,
      getPool: tokenPoolWhitelistEntity => poolEntity,
      set: tokenPoolWhitelistEntity => unit,
      delete: id => unit,
    }

    type tokenPoolWhitelistEntityHandlerContextAsync = {
      getToken: tokenPoolWhitelistEntity => promise<tokenEntity>,
      getPool: tokenPoolWhitelistEntity => promise<poolEntity>,
      set: tokenPoolWhitelistEntity => unit,
      delete: id => unit,
    }

    // Entity: Transaction
    type transactionEntityHandlerContext = {
      set: transactionEntity => unit,
      delete: id => unit,
    }

    type transactionEntityHandlerContextAsync = {
      set: transactionEntity => unit,
      delete: id => unit,
    }

    // Entity: UniswapDayData
    type uniswapDayDataEntityHandlerContext = {
      set: uniswapDayDataEntity => unit,
      delete: id => unit,
    }

    type uniswapDayDataEntityHandlerContextAsync = {
      set: uniswapDayDataEntity => unit,
      delete: id => unit,
    }

    @genType
    type handlerContext = {
      log: Logs.userLogger,
      @as("Bundle") bundle: bundleEntityHandlerContext,
      @as("Burn") burn: burnEntityHandlerContext,
      @as("Collect") collect: collectEntityHandlerContext,
      @as("Factory") factory: factoryEntityHandlerContext,
      @as("Flash") flash: flashEntityHandlerContext,
      @as("Mint") mint: mintEntityHandlerContext,
      @as("Pool") pool: poolEntityHandlerContext,
      @as("PoolDayData") poolDayData: poolDayDataEntityHandlerContext,
      @as("PoolHourData") poolHourData: poolHourDataEntityHandlerContext,
      @as("Position") position: positionEntityHandlerContext,
      @as("PositionSnapshot") positionSnapshot: positionSnapshotEntityHandlerContext,
      @as("Swap") swap: swapEntityHandlerContext,
      @as("Tick") tick: tickEntityHandlerContext,
      @as("TickDayData") tickDayData: tickDayDataEntityHandlerContext,
      @as("TickHourData") tickHourData: tickHourDataEntityHandlerContext,
      @as("Token") token: tokenEntityHandlerContext,
      @as("TokenDayData") tokenDayData: tokenDayDataEntityHandlerContext,
      @as("TokenHourData") tokenHourData: tokenHourDataEntityHandlerContext,
      @as("TokenPoolWhitelist") tokenPoolWhitelist: tokenPoolWhitelistEntityHandlerContext,
      @as("Transaction") transaction: transactionEntityHandlerContext,
      @as("UniswapDayData") uniswapDayData: uniswapDayDataEntityHandlerContext,
    }
    @genType
    type handlerContextAsync = {
      log: Logs.userLogger,
      @as("Bundle") bundle: bundleEntityHandlerContextAsync,
      @as("Burn") burn: burnEntityHandlerContextAsync,
      @as("Collect") collect: collectEntityHandlerContextAsync,
      @as("Factory") factory: factoryEntityHandlerContextAsync,
      @as("Flash") flash: flashEntityHandlerContextAsync,
      @as("Mint") mint: mintEntityHandlerContextAsync,
      @as("Pool") pool: poolEntityHandlerContextAsync,
      @as("PoolDayData") poolDayData: poolDayDataEntityHandlerContextAsync,
      @as("PoolHourData") poolHourData: poolHourDataEntityHandlerContextAsync,
      @as("Position") position: positionEntityHandlerContextAsync,
      @as("PositionSnapshot") positionSnapshot: positionSnapshotEntityHandlerContextAsync,
      @as("Swap") swap: swapEntityHandlerContextAsync,
      @as("Tick") tick: tickEntityHandlerContextAsync,
      @as("TickDayData") tickDayData: tickDayDataEntityHandlerContextAsync,
      @as("TickHourData") tickHourData: tickHourDataEntityHandlerContextAsync,
      @as("Token") token: tokenEntityHandlerContextAsync,
      @as("TokenDayData") tokenDayData: tokenDayDataEntityHandlerContextAsync,
      @as("TokenHourData") tokenHourData: tokenHourDataEntityHandlerContextAsync,
      @as("TokenPoolWhitelist") tokenPoolWhitelist: tokenPoolWhitelistEntityHandlerContextAsync,
      @as("Transaction") transaction: transactionEntityHandlerContextAsync,
      @as("UniswapDayData") uniswapDayData: uniswapDayDataEntityHandlerContextAsync,
    }

    @genType
    type positionEntityLoaderContext = {load: (id, ~loaders: positionLoaderConfig=?) => unit}
    @genType
    type positionSnapshotEntityLoaderContext = {
      load: (id, ~loaders: positionSnapshotLoaderConfig=?) => unit,
    }
    @genType
    type tokenEntityLoaderContext = {load: id => unit}

    @genType
    type contractRegistrations = {
      //TODO only add contracts we've registered for the event in the config
      addFactory: Ethers.ethAddress => unit,
      //TODO only add contracts we've registered for the event in the config
      addNonfungiblePositionManager: Ethers.ethAddress => unit,
      //TODO only add contracts we've registered for the event in the config
      addPool: Ethers.ethAddress => unit,
    }
    @genType
    type loaderContext = {
      log: Logs.userLogger,
      contractRegistration: contractRegistrations,
      @as("Position") position: positionEntityLoaderContext,
      @as("PositionSnapshot") positionSnapshot: positionSnapshotEntityLoaderContext,
      @as("Token") token: tokenEntityLoaderContext,
    }
  }
  module TransferEvent = {
    //Note: each parameter is using a binding of its index to help with binding in ethers
    //This handles both unamed params and also named params that clash with reserved keywords
    //eg. if an event param is called "values" it will clash since eventArgs will have a '.values()' iterator
    type ethersEventArgs = {
      @as("0") from: Ethers.ethAddress,
      @as("1") to: Ethers.ethAddress,
      @as("2") tokenId: Ethers.BigInt.t,
    }

    @spice @genType
    type eventArgs = {
      from: Ethers.ethAddress,
      to: Ethers.ethAddress,
      tokenId: Ethers.BigInt.t,
    }

    @genType.as("NonfungiblePositionManagerContract_Transfer_EventLog")
    type log = eventLog<eventArgs>

    // Entity: Bundle
    type bundleEntityHandlerContext = {
      set: bundleEntity => unit,
      delete: id => unit,
    }

    type bundleEntityHandlerContextAsync = {
      set: bundleEntity => unit,
      delete: id => unit,
    }

    // Entity: Burn
    type burnEntityHandlerContext = {
      getTransaction: burnEntity => transactionEntity,
      getToken0: burnEntity => tokenEntity,
      getPool: burnEntity => poolEntity,
      getToken1: burnEntity => tokenEntity,
      set: burnEntity => unit,
      delete: id => unit,
    }

    type burnEntityHandlerContextAsync = {
      getTransaction: burnEntity => promise<transactionEntity>,
      getToken0: burnEntity => promise<tokenEntity>,
      getPool: burnEntity => promise<poolEntity>,
      getToken1: burnEntity => promise<tokenEntity>,
      set: burnEntity => unit,
      delete: id => unit,
    }

    // Entity: Collect
    type collectEntityHandlerContext = {
      getTransaction: collectEntity => transactionEntity,
      getPool: collectEntity => poolEntity,
      set: collectEntity => unit,
      delete: id => unit,
    }

    type collectEntityHandlerContextAsync = {
      getTransaction: collectEntity => promise<transactionEntity>,
      getPool: collectEntity => promise<poolEntity>,
      set: collectEntity => unit,
      delete: id => unit,
    }

    // Entity: Factory
    type factoryEntityHandlerContext = {
      set: factoryEntity => unit,
      delete: id => unit,
    }

    type factoryEntityHandlerContextAsync = {
      set: factoryEntity => unit,
      delete: id => unit,
    }

    // Entity: Flash
    type flashEntityHandlerContext = {
      getPool: flashEntity => poolEntity,
      getTransaction: flashEntity => transactionEntity,
      set: flashEntity => unit,
      delete: id => unit,
    }

    type flashEntityHandlerContextAsync = {
      getPool: flashEntity => promise<poolEntity>,
      getTransaction: flashEntity => promise<transactionEntity>,
      set: flashEntity => unit,
      delete: id => unit,
    }

    // Entity: Mint
    type mintEntityHandlerContext = {
      getToken0: mintEntity => tokenEntity,
      getTransaction: mintEntity => transactionEntity,
      getPool: mintEntity => poolEntity,
      getToken1: mintEntity => tokenEntity,
      set: mintEntity => unit,
      delete: id => unit,
    }

    type mintEntityHandlerContextAsync = {
      getToken0: mintEntity => promise<tokenEntity>,
      getTransaction: mintEntity => promise<transactionEntity>,
      getPool: mintEntity => promise<poolEntity>,
      getToken1: mintEntity => promise<tokenEntity>,
      set: mintEntity => unit,
      delete: id => unit,
    }

    // Entity: Pool
    type poolEntityHandlerContext = {
      getToken1: poolEntity => tokenEntity,
      getToken0: poolEntity => tokenEntity,
      set: poolEntity => unit,
      delete: id => unit,
    }

    type poolEntityHandlerContextAsync = {
      getToken1: poolEntity => promise<tokenEntity>,
      getToken0: poolEntity => promise<tokenEntity>,
      set: poolEntity => unit,
      delete: id => unit,
    }

    // Entity: PoolDayData
    type poolDayDataEntityHandlerContext = {
      getPool: poolDayDataEntity => poolEntity,
      set: poolDayDataEntity => unit,
      delete: id => unit,
    }

    type poolDayDataEntityHandlerContextAsync = {
      getPool: poolDayDataEntity => promise<poolEntity>,
      set: poolDayDataEntity => unit,
      delete: id => unit,
    }

    // Entity: PoolHourData
    type poolHourDataEntityHandlerContext = {
      getPool: poolHourDataEntity => poolEntity,
      set: poolHourDataEntity => unit,
      delete: id => unit,
    }

    type poolHourDataEntityHandlerContextAsync = {
      getPool: poolHourDataEntity => promise<poolEntity>,
      set: poolHourDataEntity => unit,
      delete: id => unit,
    }

    // Entity: Position
    type positionEntityHandlerContext = {
      get: id => option<positionEntity>,
      getToken1: positionEntity => tokenEntity,
      getToken0: positionEntity => tokenEntity,
      getTickLower: positionEntity => tickEntity,
      getTransaction: positionEntity => transactionEntity,
      getPool: positionEntity => poolEntity,
      getTickUpper: positionEntity => tickEntity,
      set: positionEntity => unit,
      delete: id => unit,
    }

    type positionEntityHandlerContextAsync = {
      get: id => promise<option<positionEntity>>,
      getToken1: positionEntity => promise<tokenEntity>,
      getToken0: positionEntity => promise<tokenEntity>,
      getTickLower: positionEntity => promise<tickEntity>,
      getTransaction: positionEntity => promise<transactionEntity>,
      getPool: positionEntity => promise<poolEntity>,
      getTickUpper: positionEntity => promise<tickEntity>,
      set: positionEntity => unit,
      delete: id => unit,
    }

    // Entity: PositionSnapshot
    type positionSnapshotEntityHandlerContext = {
      get: id => option<positionSnapshotEntity>,
      getPool: positionSnapshotEntity => poolEntity,
      getPosition: positionSnapshotEntity => positionEntity,
      getTransaction: positionSnapshotEntity => transactionEntity,
      set: positionSnapshotEntity => unit,
      delete: id => unit,
    }

    type positionSnapshotEntityHandlerContextAsync = {
      get: id => promise<option<positionSnapshotEntity>>,
      getPool: positionSnapshotEntity => promise<poolEntity>,
      getPosition: positionSnapshotEntity => promise<positionEntity>,
      getTransaction: positionSnapshotEntity => promise<transactionEntity>,
      set: positionSnapshotEntity => unit,
      delete: id => unit,
    }

    // Entity: Swap
    type swapEntityHandlerContext = {
      getTick: swapEntity => tickEntity,
      getTransaction: swapEntity => transactionEntity,
      getToken1: swapEntity => tokenEntity,
      getToken0: swapEntity => tokenEntity,
      getPool: swapEntity => poolEntity,
      set: swapEntity => unit,
      delete: id => unit,
    }

    type swapEntityHandlerContextAsync = {
      getTick: swapEntity => promise<tickEntity>,
      getTransaction: swapEntity => promise<transactionEntity>,
      getToken1: swapEntity => promise<tokenEntity>,
      getToken0: swapEntity => promise<tokenEntity>,
      getPool: swapEntity => promise<poolEntity>,
      set: swapEntity => unit,
      delete: id => unit,
    }

    // Entity: Tick
    type tickEntityHandlerContext = {
      getPool: tickEntity => poolEntity,
      set: tickEntity => unit,
      delete: id => unit,
    }

    type tickEntityHandlerContextAsync = {
      getPool: tickEntity => promise<poolEntity>,
      set: tickEntity => unit,
      delete: id => unit,
    }

    // Entity: TickDayData
    type tickDayDataEntityHandlerContext = {
      getPool: tickDayDataEntity => poolEntity,
      getTick: tickDayDataEntity => tickEntity,
      set: tickDayDataEntity => unit,
      delete: id => unit,
    }

    type tickDayDataEntityHandlerContextAsync = {
      getPool: tickDayDataEntity => promise<poolEntity>,
      getTick: tickDayDataEntity => promise<tickEntity>,
      set: tickDayDataEntity => unit,
      delete: id => unit,
    }

    // Entity: TickHourData
    type tickHourDataEntityHandlerContext = {
      getTick: tickHourDataEntity => tickEntity,
      getPool: tickHourDataEntity => poolEntity,
      set: tickHourDataEntity => unit,
      delete: id => unit,
    }

    type tickHourDataEntityHandlerContextAsync = {
      getTick: tickHourDataEntity => promise<tickEntity>,
      getPool: tickHourDataEntity => promise<poolEntity>,
      set: tickHourDataEntity => unit,
      delete: id => unit,
    }

    // Entity: Token
    type tokenEntityHandlerContext = {
      set: tokenEntity => unit,
      delete: id => unit,
    }

    type tokenEntityHandlerContextAsync = {
      set: tokenEntity => unit,
      delete: id => unit,
    }

    // Entity: TokenDayData
    type tokenDayDataEntityHandlerContext = {
      getToken: tokenDayDataEntity => tokenEntity,
      set: tokenDayDataEntity => unit,
      delete: id => unit,
    }

    type tokenDayDataEntityHandlerContextAsync = {
      getToken: tokenDayDataEntity => promise<tokenEntity>,
      set: tokenDayDataEntity => unit,
      delete: id => unit,
    }

    // Entity: TokenHourData
    type tokenHourDataEntityHandlerContext = {
      getToken: tokenHourDataEntity => tokenEntity,
      set: tokenHourDataEntity => unit,
      delete: id => unit,
    }

    type tokenHourDataEntityHandlerContextAsync = {
      getToken: tokenHourDataEntity => promise<tokenEntity>,
      set: tokenHourDataEntity => unit,
      delete: id => unit,
    }

    // Entity: TokenPoolWhitelist
    type tokenPoolWhitelistEntityHandlerContext = {
      getToken: tokenPoolWhitelistEntity => tokenEntity,
      getPool: tokenPoolWhitelistEntity => poolEntity,
      set: tokenPoolWhitelistEntity => unit,
      delete: id => unit,
    }

    type tokenPoolWhitelistEntityHandlerContextAsync = {
      getToken: tokenPoolWhitelistEntity => promise<tokenEntity>,
      getPool: tokenPoolWhitelistEntity => promise<poolEntity>,
      set: tokenPoolWhitelistEntity => unit,
      delete: id => unit,
    }

    // Entity: Transaction
    type transactionEntityHandlerContext = {
      set: transactionEntity => unit,
      delete: id => unit,
    }

    type transactionEntityHandlerContextAsync = {
      set: transactionEntity => unit,
      delete: id => unit,
    }

    // Entity: UniswapDayData
    type uniswapDayDataEntityHandlerContext = {
      set: uniswapDayDataEntity => unit,
      delete: id => unit,
    }

    type uniswapDayDataEntityHandlerContextAsync = {
      set: uniswapDayDataEntity => unit,
      delete: id => unit,
    }

    @genType
    type handlerContext = {
      log: Logs.userLogger,
      @as("Bundle") bundle: bundleEntityHandlerContext,
      @as("Burn") burn: burnEntityHandlerContext,
      @as("Collect") collect: collectEntityHandlerContext,
      @as("Factory") factory: factoryEntityHandlerContext,
      @as("Flash") flash: flashEntityHandlerContext,
      @as("Mint") mint: mintEntityHandlerContext,
      @as("Pool") pool: poolEntityHandlerContext,
      @as("PoolDayData") poolDayData: poolDayDataEntityHandlerContext,
      @as("PoolHourData") poolHourData: poolHourDataEntityHandlerContext,
      @as("Position") position: positionEntityHandlerContext,
      @as("PositionSnapshot") positionSnapshot: positionSnapshotEntityHandlerContext,
      @as("Swap") swap: swapEntityHandlerContext,
      @as("Tick") tick: tickEntityHandlerContext,
      @as("TickDayData") tickDayData: tickDayDataEntityHandlerContext,
      @as("TickHourData") tickHourData: tickHourDataEntityHandlerContext,
      @as("Token") token: tokenEntityHandlerContext,
      @as("TokenDayData") tokenDayData: tokenDayDataEntityHandlerContext,
      @as("TokenHourData") tokenHourData: tokenHourDataEntityHandlerContext,
      @as("TokenPoolWhitelist") tokenPoolWhitelist: tokenPoolWhitelistEntityHandlerContext,
      @as("Transaction") transaction: transactionEntityHandlerContext,
      @as("UniswapDayData") uniswapDayData: uniswapDayDataEntityHandlerContext,
    }
    @genType
    type handlerContextAsync = {
      log: Logs.userLogger,
      @as("Bundle") bundle: bundleEntityHandlerContextAsync,
      @as("Burn") burn: burnEntityHandlerContextAsync,
      @as("Collect") collect: collectEntityHandlerContextAsync,
      @as("Factory") factory: factoryEntityHandlerContextAsync,
      @as("Flash") flash: flashEntityHandlerContextAsync,
      @as("Mint") mint: mintEntityHandlerContextAsync,
      @as("Pool") pool: poolEntityHandlerContextAsync,
      @as("PoolDayData") poolDayData: poolDayDataEntityHandlerContextAsync,
      @as("PoolHourData") poolHourData: poolHourDataEntityHandlerContextAsync,
      @as("Position") position: positionEntityHandlerContextAsync,
      @as("PositionSnapshot") positionSnapshot: positionSnapshotEntityHandlerContextAsync,
      @as("Swap") swap: swapEntityHandlerContextAsync,
      @as("Tick") tick: tickEntityHandlerContextAsync,
      @as("TickDayData") tickDayData: tickDayDataEntityHandlerContextAsync,
      @as("TickHourData") tickHourData: tickHourDataEntityHandlerContextAsync,
      @as("Token") token: tokenEntityHandlerContextAsync,
      @as("TokenDayData") tokenDayData: tokenDayDataEntityHandlerContextAsync,
      @as("TokenHourData") tokenHourData: tokenHourDataEntityHandlerContextAsync,
      @as("TokenPoolWhitelist") tokenPoolWhitelist: tokenPoolWhitelistEntityHandlerContextAsync,
      @as("Transaction") transaction: transactionEntityHandlerContextAsync,
      @as("UniswapDayData") uniswapDayData: uniswapDayDataEntityHandlerContextAsync,
    }

    @genType
    type positionEntityLoaderContext = {load: (id, ~loaders: positionLoaderConfig=?) => unit}
    @genType
    type positionSnapshotEntityLoaderContext = {
      load: (id, ~loaders: positionSnapshotLoaderConfig=?) => unit,
    }

    @genType
    type contractRegistrations = {
      //TODO only add contracts we've registered for the event in the config
      addFactory: Ethers.ethAddress => unit,
      //TODO only add contracts we've registered for the event in the config
      addNonfungiblePositionManager: Ethers.ethAddress => unit,
      //TODO only add contracts we've registered for the event in the config
      addPool: Ethers.ethAddress => unit,
    }
    @genType
    type loaderContext = {
      log: Logs.userLogger,
      contractRegistration: contractRegistrations,
      @as("Position") position: positionEntityLoaderContext,
      @as("PositionSnapshot") positionSnapshot: positionSnapshotEntityLoaderContext,
    }
  }
}
module PoolContract = {
  module SwapEvent = {
    //Note: each parameter is using a binding of its index to help with binding in ethers
    //This handles both unamed params and also named params that clash with reserved keywords
    //eg. if an event param is called "values" it will clash since eventArgs will have a '.values()' iterator
    type ethersEventArgs = {
      @as("0") sender: Ethers.ethAddress,
      @as("1") recipient: Ethers.ethAddress,
      @as("2") amount0: Ethers.BigInt.t,
      @as("3") amount1: Ethers.BigInt.t,
      @as("4") sqrtPriceX96: Ethers.BigInt.t,
      @as("5") liquidity: Ethers.BigInt.t,
      @as("6") tick: Ethers.BigInt.t,
    }

    @spice @genType
    type eventArgs = {
      sender: Ethers.ethAddress,
      recipient: Ethers.ethAddress,
      amount0: Ethers.BigInt.t,
      amount1: Ethers.BigInt.t,
      sqrtPriceX96: Ethers.BigInt.t,
      liquidity: Ethers.BigInt.t,
      tick: Ethers.BigInt.t,
    }

    @genType.as("PoolContract_Swap_EventLog")
    type log = eventLog<eventArgs>

    // Entity: Bundle
    type bundleEntityHandlerContext = {
      set: bundleEntity => unit,
      delete: id => unit,
    }

    type bundleEntityHandlerContextAsync = {
      set: bundleEntity => unit,
      delete: id => unit,
    }

    // Entity: Burn
    type burnEntityHandlerContext = {
      getTransaction: burnEntity => transactionEntity,
      getToken0: burnEntity => tokenEntity,
      getPool: burnEntity => poolEntity,
      getToken1: burnEntity => tokenEntity,
      set: burnEntity => unit,
      delete: id => unit,
    }

    type burnEntityHandlerContextAsync = {
      getTransaction: burnEntity => promise<transactionEntity>,
      getToken0: burnEntity => promise<tokenEntity>,
      getPool: burnEntity => promise<poolEntity>,
      getToken1: burnEntity => promise<tokenEntity>,
      set: burnEntity => unit,
      delete: id => unit,
    }

    // Entity: Collect
    type collectEntityHandlerContext = {
      getTransaction: collectEntity => transactionEntity,
      getPool: collectEntity => poolEntity,
      set: collectEntity => unit,
      delete: id => unit,
    }

    type collectEntityHandlerContextAsync = {
      getTransaction: collectEntity => promise<transactionEntity>,
      getPool: collectEntity => promise<poolEntity>,
      set: collectEntity => unit,
      delete: id => unit,
    }

    // Entity: Factory
    type factoryEntityHandlerContext = {
      set: factoryEntity => unit,
      delete: id => unit,
    }

    type factoryEntityHandlerContextAsync = {
      set: factoryEntity => unit,
      delete: id => unit,
    }

    // Entity: Flash
    type flashEntityHandlerContext = {
      getPool: flashEntity => poolEntity,
      getTransaction: flashEntity => transactionEntity,
      set: flashEntity => unit,
      delete: id => unit,
    }

    type flashEntityHandlerContextAsync = {
      getPool: flashEntity => promise<poolEntity>,
      getTransaction: flashEntity => promise<transactionEntity>,
      set: flashEntity => unit,
      delete: id => unit,
    }

    // Entity: Mint
    type mintEntityHandlerContext = {
      getToken0: mintEntity => tokenEntity,
      getTransaction: mintEntity => transactionEntity,
      getPool: mintEntity => poolEntity,
      getToken1: mintEntity => tokenEntity,
      set: mintEntity => unit,
      delete: id => unit,
    }

    type mintEntityHandlerContextAsync = {
      getToken0: mintEntity => promise<tokenEntity>,
      getTransaction: mintEntity => promise<transactionEntity>,
      getPool: mintEntity => promise<poolEntity>,
      getToken1: mintEntity => promise<tokenEntity>,
      set: mintEntity => unit,
      delete: id => unit,
    }

    // Entity: Pool
    type poolEntityHandlerContext = {
      getToken1: poolEntity => tokenEntity,
      getToken0: poolEntity => tokenEntity,
      set: poolEntity => unit,
      delete: id => unit,
    }

    type poolEntityHandlerContextAsync = {
      getToken1: poolEntity => promise<tokenEntity>,
      getToken0: poolEntity => promise<tokenEntity>,
      set: poolEntity => unit,
      delete: id => unit,
    }

    // Entity: PoolDayData
    type poolDayDataEntityHandlerContext = {
      getPool: poolDayDataEntity => poolEntity,
      set: poolDayDataEntity => unit,
      delete: id => unit,
    }

    type poolDayDataEntityHandlerContextAsync = {
      getPool: poolDayDataEntity => promise<poolEntity>,
      set: poolDayDataEntity => unit,
      delete: id => unit,
    }

    // Entity: PoolHourData
    type poolHourDataEntityHandlerContext = {
      getPool: poolHourDataEntity => poolEntity,
      set: poolHourDataEntity => unit,
      delete: id => unit,
    }

    type poolHourDataEntityHandlerContextAsync = {
      getPool: poolHourDataEntity => promise<poolEntity>,
      set: poolHourDataEntity => unit,
      delete: id => unit,
    }

    // Entity: Position
    type positionEntityHandlerContext = {
      getToken1: positionEntity => tokenEntity,
      getToken0: positionEntity => tokenEntity,
      getTickLower: positionEntity => tickEntity,
      getTransaction: positionEntity => transactionEntity,
      getPool: positionEntity => poolEntity,
      getTickUpper: positionEntity => tickEntity,
      set: positionEntity => unit,
      delete: id => unit,
    }

    type positionEntityHandlerContextAsync = {
      getToken1: positionEntity => promise<tokenEntity>,
      getToken0: positionEntity => promise<tokenEntity>,
      getTickLower: positionEntity => promise<tickEntity>,
      getTransaction: positionEntity => promise<transactionEntity>,
      getPool: positionEntity => promise<poolEntity>,
      getTickUpper: positionEntity => promise<tickEntity>,
      set: positionEntity => unit,
      delete: id => unit,
    }

    // Entity: PositionSnapshot
    type positionSnapshotEntityHandlerContext = {
      getPool: positionSnapshotEntity => poolEntity,
      getPosition: positionSnapshotEntity => positionEntity,
      getTransaction: positionSnapshotEntity => transactionEntity,
      set: positionSnapshotEntity => unit,
      delete: id => unit,
    }

    type positionSnapshotEntityHandlerContextAsync = {
      getPool: positionSnapshotEntity => promise<poolEntity>,
      getPosition: positionSnapshotEntity => promise<positionEntity>,
      getTransaction: positionSnapshotEntity => promise<transactionEntity>,
      set: positionSnapshotEntity => unit,
      delete: id => unit,
    }

    // Entity: Swap
    type swapEntityHandlerContext = {
      get: id => option<swapEntity>,
      getTick: swapEntity => tickEntity,
      getTransaction: swapEntity => transactionEntity,
      getToken1: swapEntity => tokenEntity,
      getToken0: swapEntity => tokenEntity,
      getPool: swapEntity => poolEntity,
      set: swapEntity => unit,
      delete: id => unit,
    }

    type swapEntityHandlerContextAsync = {
      get: id => promise<option<swapEntity>>,
      getTick: swapEntity => promise<tickEntity>,
      getTransaction: swapEntity => promise<transactionEntity>,
      getToken1: swapEntity => promise<tokenEntity>,
      getToken0: swapEntity => promise<tokenEntity>,
      getPool: swapEntity => promise<poolEntity>,
      set: swapEntity => unit,
      delete: id => unit,
    }

    // Entity: Tick
    type tickEntityHandlerContext = {
      getPool: tickEntity => poolEntity,
      set: tickEntity => unit,
      delete: id => unit,
    }

    type tickEntityHandlerContextAsync = {
      getPool: tickEntity => promise<poolEntity>,
      set: tickEntity => unit,
      delete: id => unit,
    }

    // Entity: TickDayData
    type tickDayDataEntityHandlerContext = {
      getPool: tickDayDataEntity => poolEntity,
      getTick: tickDayDataEntity => tickEntity,
      set: tickDayDataEntity => unit,
      delete: id => unit,
    }

    type tickDayDataEntityHandlerContextAsync = {
      getPool: tickDayDataEntity => promise<poolEntity>,
      getTick: tickDayDataEntity => promise<tickEntity>,
      set: tickDayDataEntity => unit,
      delete: id => unit,
    }

    // Entity: TickHourData
    type tickHourDataEntityHandlerContext = {
      getTick: tickHourDataEntity => tickEntity,
      getPool: tickHourDataEntity => poolEntity,
      set: tickHourDataEntity => unit,
      delete: id => unit,
    }

    type tickHourDataEntityHandlerContextAsync = {
      getTick: tickHourDataEntity => promise<tickEntity>,
      getPool: tickHourDataEntity => promise<poolEntity>,
      set: tickHourDataEntity => unit,
      delete: id => unit,
    }

    // Entity: Token
    type tokenEntityHandlerContext = {
      get: id => option<tokenEntity>,
      set: tokenEntity => unit,
      delete: id => unit,
    }

    type tokenEntityHandlerContextAsync = {
      get: id => promise<option<tokenEntity>>,
      set: tokenEntity => unit,
      delete: id => unit,
    }

    // Entity: TokenDayData
    type tokenDayDataEntityHandlerContext = {
      getToken: tokenDayDataEntity => tokenEntity,
      set: tokenDayDataEntity => unit,
      delete: id => unit,
    }

    type tokenDayDataEntityHandlerContextAsync = {
      getToken: tokenDayDataEntity => promise<tokenEntity>,
      set: tokenDayDataEntity => unit,
      delete: id => unit,
    }

    // Entity: TokenHourData
    type tokenHourDataEntityHandlerContext = {
      getToken: tokenHourDataEntity => tokenEntity,
      set: tokenHourDataEntity => unit,
      delete: id => unit,
    }

    type tokenHourDataEntityHandlerContextAsync = {
      getToken: tokenHourDataEntity => promise<tokenEntity>,
      set: tokenHourDataEntity => unit,
      delete: id => unit,
    }

    // Entity: TokenPoolWhitelist
    type tokenPoolWhitelistEntityHandlerContext = {
      getToken: tokenPoolWhitelistEntity => tokenEntity,
      getPool: tokenPoolWhitelistEntity => poolEntity,
      set: tokenPoolWhitelistEntity => unit,
      delete: id => unit,
    }

    type tokenPoolWhitelistEntityHandlerContextAsync = {
      getToken: tokenPoolWhitelistEntity => promise<tokenEntity>,
      getPool: tokenPoolWhitelistEntity => promise<poolEntity>,
      set: tokenPoolWhitelistEntity => unit,
      delete: id => unit,
    }

    // Entity: Transaction
    type transactionEntityHandlerContext = {
      set: transactionEntity => unit,
      delete: id => unit,
    }

    type transactionEntityHandlerContextAsync = {
      set: transactionEntity => unit,
      delete: id => unit,
    }

    // Entity: UniswapDayData
    type uniswapDayDataEntityHandlerContext = {
      set: uniswapDayDataEntity => unit,
      delete: id => unit,
    }

    type uniswapDayDataEntityHandlerContextAsync = {
      set: uniswapDayDataEntity => unit,
      delete: id => unit,
    }

    @genType
    type handlerContext = {
      log: Logs.userLogger,
      @as("Bundle") bundle: bundleEntityHandlerContext,
      @as("Burn") burn: burnEntityHandlerContext,
      @as("Collect") collect: collectEntityHandlerContext,
      @as("Factory") factory: factoryEntityHandlerContext,
      @as("Flash") flash: flashEntityHandlerContext,
      @as("Mint") mint: mintEntityHandlerContext,
      @as("Pool") pool: poolEntityHandlerContext,
      @as("PoolDayData") poolDayData: poolDayDataEntityHandlerContext,
      @as("PoolHourData") poolHourData: poolHourDataEntityHandlerContext,
      @as("Position") position: positionEntityHandlerContext,
      @as("PositionSnapshot") positionSnapshot: positionSnapshotEntityHandlerContext,
      @as("Swap") swap: swapEntityHandlerContext,
      @as("Tick") tick: tickEntityHandlerContext,
      @as("TickDayData") tickDayData: tickDayDataEntityHandlerContext,
      @as("TickHourData") tickHourData: tickHourDataEntityHandlerContext,
      @as("Token") token: tokenEntityHandlerContext,
      @as("TokenDayData") tokenDayData: tokenDayDataEntityHandlerContext,
      @as("TokenHourData") tokenHourData: tokenHourDataEntityHandlerContext,
      @as("TokenPoolWhitelist") tokenPoolWhitelist: tokenPoolWhitelistEntityHandlerContext,
      @as("Transaction") transaction: transactionEntityHandlerContext,
      @as("UniswapDayData") uniswapDayData: uniswapDayDataEntityHandlerContext,
    }
    @genType
    type handlerContextAsync = {
      log: Logs.userLogger,
      @as("Bundle") bundle: bundleEntityHandlerContextAsync,
      @as("Burn") burn: burnEntityHandlerContextAsync,
      @as("Collect") collect: collectEntityHandlerContextAsync,
      @as("Factory") factory: factoryEntityHandlerContextAsync,
      @as("Flash") flash: flashEntityHandlerContextAsync,
      @as("Mint") mint: mintEntityHandlerContextAsync,
      @as("Pool") pool: poolEntityHandlerContextAsync,
      @as("PoolDayData") poolDayData: poolDayDataEntityHandlerContextAsync,
      @as("PoolHourData") poolHourData: poolHourDataEntityHandlerContextAsync,
      @as("Position") position: positionEntityHandlerContextAsync,
      @as("PositionSnapshot") positionSnapshot: positionSnapshotEntityHandlerContextAsync,
      @as("Swap") swap: swapEntityHandlerContextAsync,
      @as("Tick") tick: tickEntityHandlerContextAsync,
      @as("TickDayData") tickDayData: tickDayDataEntityHandlerContextAsync,
      @as("TickHourData") tickHourData: tickHourDataEntityHandlerContextAsync,
      @as("Token") token: tokenEntityHandlerContextAsync,
      @as("TokenDayData") tokenDayData: tokenDayDataEntityHandlerContextAsync,
      @as("TokenHourData") tokenHourData: tokenHourDataEntityHandlerContextAsync,
      @as("TokenPoolWhitelist") tokenPoolWhitelist: tokenPoolWhitelistEntityHandlerContextAsync,
      @as("Transaction") transaction: transactionEntityHandlerContextAsync,
      @as("UniswapDayData") uniswapDayData: uniswapDayDataEntityHandlerContextAsync,
    }

    @genType
    type swapEntityLoaderContext = {load: (id, ~loaders: swapLoaderConfig=?) => unit}
    @genType
    type tokenEntityLoaderContext = {load: id => unit}

    @genType
    type contractRegistrations = {
      //TODO only add contracts we've registered for the event in the config
      addFactory: Ethers.ethAddress => unit,
      //TODO only add contracts we've registered for the event in the config
      addNonfungiblePositionManager: Ethers.ethAddress => unit,
      //TODO only add contracts we've registered for the event in the config
      addPool: Ethers.ethAddress => unit,
    }
    @genType
    type loaderContext = {
      log: Logs.userLogger,
      contractRegistration: contractRegistrations,
      @as("Swap") swap: swapEntityLoaderContext,
      @as("Token") token: tokenEntityLoaderContext,
    }
  }
}

@deriving(accessors)
type event =
  | FactoryContract_PoolCreated(eventLog<FactoryContract.PoolCreatedEvent.eventArgs>)
  | NonfungiblePositionManagerContract_IncreaseLiquidity(
      eventLog<NonfungiblePositionManagerContract.IncreaseLiquidityEvent.eventArgs>,
    )
  | NonfungiblePositionManagerContract_DecreaseLiquidity(
      eventLog<NonfungiblePositionManagerContract.DecreaseLiquidityEvent.eventArgs>,
    )
  | NonfungiblePositionManagerContract_Transfer(
      eventLog<NonfungiblePositionManagerContract.TransferEvent.eventArgs>,
    )
  | PoolContract_Swap(eventLog<PoolContract.SwapEvent.eventArgs>)

@spice
type eventName =
  | @spice.as("Factory_PoolCreated") Factory_PoolCreated
  | @spice.as("NonfungiblePositionManager_IncreaseLiquidity")
  NonfungiblePositionManager_IncreaseLiquidity
  | @spice.as("NonfungiblePositionManager_DecreaseLiquidity")
  NonfungiblePositionManager_DecreaseLiquidity
  | @spice.as("NonfungiblePositionManager_Transfer") NonfungiblePositionManager_Transfer
  | @spice.as("Pool_Swap") Pool_Swap

let eventNameToString = (eventName: eventName) =>
  switch eventName {
  | Factory_PoolCreated => "PoolCreated"
  | NonfungiblePositionManager_IncreaseLiquidity => "IncreaseLiquidity"
  | NonfungiblePositionManager_DecreaseLiquidity => "DecreaseLiquidity"
  | NonfungiblePositionManager_Transfer => "Transfer"
  | Pool_Swap => "Swap"
  }

exception UnknownEvent(string, string)
let eventTopicToEventName = (contractName, topic0) =>
  switch (contractName, topic0) {
  | ("Factory", "0x783cca1c0412dd0d695e784568c96da2e9c22ff989357a2e8b1d9b2b4e6b7118") =>
    Factory_PoolCreated
  | (
      "NonfungiblePositionManager",
      "0x3067048beee31b25b2f1681f88dac838c8bba36af25bfb2b7cf7473a5847e35f",
    ) =>
    NonfungiblePositionManager_IncreaseLiquidity
  | (
      "NonfungiblePositionManager",
      "0x26f6a048ee9138f2c0ce266f322cb99228e8d619ae2bff30c67f8dcf9d2377b4",
    ) =>
    NonfungiblePositionManager_DecreaseLiquidity
  | (
      "NonfungiblePositionManager",
      "0xddf252ad1be2c89b69c2b068fc378daa952ba7f163c4a11628f55a4df523b3ef",
    ) =>
    NonfungiblePositionManager_Transfer
  | ("Pool", "0xc42079f94a6350d7e6235f29174924f928cc2ac818eb64fed8004e115fbcca67") => Pool_Swap
  | (contractName, topic0) => UnknownEvent(contractName, topic0)->raise
  }

@genType
type chainId = int

type eventBatchQueueItem = {
  timestamp: int,
  chain: ChainMap.Chain.t,
  blockNumber: int,
  logIndex: int,
  event: event,
  //Default to false, if an event needs to
  //be reprocessed after it has loaded dynamic contracts
  //This gets set to true and does not try and reload events
  hasRegisteredDynamicContracts?: bool,
}
