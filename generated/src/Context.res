type entityGetters = {
  getBundle: Types.id => promise<array<Types.bundleEntity>>,
  getBurn: Types.id => promise<array<Types.burnEntity>>,
  getCollect: Types.id => promise<array<Types.collectEntity>>,
  getFactory: Types.id => promise<array<Types.factoryEntity>>,
  getFlash: Types.id => promise<array<Types.flashEntity>>,
  getMint: Types.id => promise<array<Types.mintEntity>>,
  getPool: Types.id => promise<array<Types.poolEntity>>,
  getPoolDayData: Types.id => promise<array<Types.poolDayDataEntity>>,
  getPoolHourData: Types.id => promise<array<Types.poolHourDataEntity>>,
  getPosition: Types.id => promise<array<Types.positionEntity>>,
  getPositionSnapshot: Types.id => promise<array<Types.positionSnapshotEntity>>,
  getSwap: Types.id => promise<array<Types.swapEntity>>,
  getTick: Types.id => promise<array<Types.tickEntity>>,
  getTickDayData: Types.id => promise<array<Types.tickDayDataEntity>>,
  getTickHourData: Types.id => promise<array<Types.tickHourDataEntity>>,
  getToken: Types.id => promise<array<Types.tokenEntity>>,
  getTokenDayData: Types.id => promise<array<Types.tokenDayDataEntity>>,
  getTokenHourData: Types.id => promise<array<Types.tokenHourDataEntity>>,
  getTokenPoolWhitelist: Types.id => promise<array<Types.tokenPoolWhitelistEntity>>,
  getTransaction: Types.id => promise<array<Types.transactionEntity>>,
  getUniswapDayData: Types.id => promise<array<Types.uniswapDayDataEntity>>,
}

@genType
type genericContextCreatorFunctions<'loaderContext, 'handlerContextSync, 'handlerContextAsync> = {
  logger: Pino.t,
  log: Logs.userLogger,
  getLoaderContext: unit => 'loaderContext,
  getHandlerContextSync: unit => 'handlerContextSync,
  getHandlerContextAsync: unit => 'handlerContextAsync,
  getEntitiesToLoad: unit => array<Types.entityRead>,
  getAddedDynamicContractRegistrations: unit => array<Types.dynamicContractRegistryEntity>,
}

type contextCreator<'eventArgs, 'loaderContext, 'handlerContext, 'handlerContextAsync> = (
  ~inMemoryStore: IO.InMemoryStore.t,
  ~chainId: int,
  ~event: Types.eventLog<'eventArgs>,
  ~logger: Pino.t,
  ~asyncGetters: entityGetters,
) => genericContextCreatorFunctions<'loaderContext, 'handlerContext, 'handlerContextAsync>

exception UnableToLoadNonNullableLinkedEntity(string)
exception LinkedEntityNotAvailableInSyncHandler(string)

module FactoryContract = {
  module PoolCreatedEvent = {
    type loaderContext = Types.FactoryContract.PoolCreatedEvent.loaderContext
    type handlerContext = Types.FactoryContract.PoolCreatedEvent.handlerContext
    type handlerContextAsync = Types.FactoryContract.PoolCreatedEvent.handlerContextAsync
    type context = genericContextCreatorFunctions<
      loaderContext,
      handlerContext,
      handlerContextAsync,
    >

    let contextCreator: contextCreator<
      Types.FactoryContract.PoolCreatedEvent.eventArgs,
      loaderContext,
      handlerContext,
      handlerContextAsync,
    > = (~inMemoryStore, ~chainId, ~event, ~logger, ~asyncGetters) => {
      // NOTE: we could optimise this code to onle create a logger if there was a log called.
      let logger = logger->Logging.createChildFrom(
        ~logger=_,
        ~params={
          "context": "Factory.PoolCreated",
          "chainId": chainId,
          "block": event.blockNumber,
          "logIndex": event.logIndex,
          "txHash": event.transactionHash,
        },
      )

      let contextLogger: Logs.userLogger = {
        info: (message: string) => logger->Logging.uinfo(message),
        debug: (message: string) => logger->Logging.udebug(message),
        warn: (message: string) => logger->Logging.uwarn(message),
        error: (message: string) => logger->Logging.uerror(message),
        errorWithExn: (exn: option<Js.Exn.t>, message: string) =>
          logger->Logging.uerrorWithExn(exn, message),
      }

      let optSetOfIds_pool: Set.t<Types.id> = Set.make()
      let optSetOfIds_factory: Set.t<Types.id> = Set.make()
      let optSetOfIds_token: Set.t<Types.id> = Set.make()
      let optSetOfIds_tokenPoolWhitelist: Set.t<Types.id> = Set.make()

      let entitiesToLoad: array<Types.entityRead> = []

      let addedDynamicContractRegistrations: array<Types.dynamicContractRegistryEntity> = []

      //Loader context can be defined as a value and the getter can return that value

      @warning("-16")
      let loaderContext: loaderContext = {
        log: contextLogger,
        contractRegistration: {
          //TODO only add contracts we've registered for the event in the config
          addFactory: (contractAddress: Ethers.ethAddress) => {
            let eventId = EventUtils.packEventIndex(
              ~blockNumber=event.blockNumber,
              ~logIndex=event.logIndex,
            )
            let dynamicContractRegistration: Types.dynamicContractRegistryEntity = {
              chainId,
              eventId,
              contractAddress,
              contractType: "Factory",
            }

            addedDynamicContractRegistrations->Js.Array2.push(dynamicContractRegistration)->ignore

            inMemoryStore.dynamicContractRegistry->IO.InMemoryStore.DynamicContractRegistry.set(
              ~key={chainId, contractAddress},
              ~entity=dynamicContractRegistration,
              ~dbOp=Set,
            )
          },
          //TODO only add contracts we've registered for the event in the config
          addNonfungiblePositionManager: (contractAddress: Ethers.ethAddress) => {
            let eventId = EventUtils.packEventIndex(
              ~blockNumber=event.blockNumber,
              ~logIndex=event.logIndex,
            )
            let dynamicContractRegistration: Types.dynamicContractRegistryEntity = {
              chainId,
              eventId,
              contractAddress,
              contractType: "NonfungiblePositionManager",
            }

            addedDynamicContractRegistrations->Js.Array2.push(dynamicContractRegistration)->ignore

            inMemoryStore.dynamicContractRegistry->IO.InMemoryStore.DynamicContractRegistry.set(
              ~key={chainId, contractAddress},
              ~entity=dynamicContractRegistration,
              ~dbOp=Set,
            )
          },
          //TODO only add contracts we've registered for the event in the config
          addPool: (contractAddress: Ethers.ethAddress) => {
            let eventId = EventUtils.packEventIndex(
              ~blockNumber=event.blockNumber,
              ~logIndex=event.logIndex,
            )
            let dynamicContractRegistration: Types.dynamicContractRegistryEntity = {
              chainId,
              eventId,
              contractAddress,
              contractType: "Pool",
            }

            addedDynamicContractRegistrations->Js.Array2.push(dynamicContractRegistration)->ignore

            inMemoryStore.dynamicContractRegistry->IO.InMemoryStore.DynamicContractRegistry.set(
              ~key={chainId, contractAddress},
              ~entity=dynamicContractRegistration,
              ~dbOp=Set,
            )
          },
        },
        pool: {
          load: (id: Types.id, ~loaders={}) => {
            let _ = optSetOfIds_pool->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.PoolRead(id, loaders))
          },
        },
        factory: {
          load: (id: Types.id) => {
            let _ = optSetOfIds_factory->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.FactoryRead(id))
          },
        },
        token: {
          load: (id: Types.id) => {
            let _ = optSetOfIds_token->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.TokenRead(id))
          },
        },
        tokenPoolWhitelist: {
          load: (id: Types.id, ~loaders={}) => {
            let _ = optSetOfIds_tokenPoolWhitelist->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.TokenPoolWhitelistRead(id, loaders))
          },
        },
      }

      //handler context must be defined as a getter functoin so that it can construct the context
      //without stale values whenever it is used
      let getHandlerContextSync: unit => handlerContext = () => {
        {
          log: contextLogger,
          bundle: {
            set: entity => {
              inMemoryStore.bundle->IO.InMemoryStore.Bundle.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(bundle) with ID ${id}.`),
          },
          burn: {
            set: entity => {
              inMemoryStore.burn->IO.InMemoryStore.Burn.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(burn) with ID ${id}.`),
            getTransaction: burn => {
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(burn.transaction_id)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                Logging.warn(`Burn transaction data not found. Loading associated transaction from database.
Please consider loading the transaction in the UpdateBurn entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Burn is undefined.",
                  ),
                )
              }
            },
            getToken0: burn => {
              let optToken0 = inMemoryStore.token->IO.InMemoryStore.Token.get(burn.token0_id)
              switch optToken0 {
              | Some(token0) => token0
              | None =>
                Logging.warn(`Burn token0 data not found. Loading associated token from database.
Please consider loading the token in the UpdateBurn entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Burn is undefined.",
                  ),
                )
              }
            },
            getPool: burn => {
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(burn.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`Burn pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdateBurn entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Burn is undefined.",
                  ),
                )
              }
            },
            getToken1: burn => {
              let optToken1 = inMemoryStore.token->IO.InMemoryStore.Token.get(burn.token1_id)
              switch optToken1 {
              | Some(token1) => token1
              | None =>
                Logging.warn(`Burn token1 data not found. Loading associated token from database.
Please consider loading the token in the UpdateBurn entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Burn is undefined.",
                  ),
                )
              }
            },
          },
          collect: {
            set: entity => {
              inMemoryStore.collect->IO.InMemoryStore.Collect.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(collect) with ID ${id}.`),
            getTransaction: collect => {
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(collect.transaction_id)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                Logging.warn(`Collect transaction data not found. Loading associated transaction from database.
Please consider loading the transaction in the UpdateCollect entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Collect is undefined.",
                  ),
                )
              }
            },
            getPool: collect => {
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(collect.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`Collect pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdateCollect entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Collect is undefined.",
                  ),
                )
              }
            },
          },
          factory: {
            set: entity => {
              inMemoryStore.factory->IO.InMemoryStore.Factory.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(factory) with ID ${id}.`),
            get: (id: Types.id) => {
              if optSetOfIds_factory->Set.has(id) {
                inMemoryStore.factory->IO.InMemoryStore.Factory.get(id)
              } else {
                Logging.warn(
                  `The loader for a "Factory" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.factory.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.factory->IO.InMemoryStore.Factory.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
          },
          flash: {
            set: entity => {
              inMemoryStore.flash->IO.InMemoryStore.Flash.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(flash) with ID ${id}.`),
            getPool: flash => {
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(flash.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`Flash pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdateFlash entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Flash is undefined.",
                  ),
                )
              }
            },
            getTransaction: flash => {
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(flash.transaction_id)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                Logging.warn(`Flash transaction data not found. Loading associated transaction from database.
Please consider loading the transaction in the UpdateFlash entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Flash is undefined.",
                  ),
                )
              }
            },
          },
          mint: {
            set: entity => {
              inMemoryStore.mint->IO.InMemoryStore.Mint.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(mint) with ID ${id}.`),
            getToken0: mint => {
              let optToken0 = inMemoryStore.token->IO.InMemoryStore.Token.get(mint.token0_id)
              switch optToken0 {
              | Some(token0) => token0
              | None =>
                Logging.warn(`Mint token0 data not found. Loading associated token from database.
Please consider loading the token in the UpdateMint entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Mint is undefined.",
                  ),
                )
              }
            },
            getTransaction: mint => {
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(mint.transaction_id)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                Logging.warn(`Mint transaction data not found. Loading associated transaction from database.
Please consider loading the transaction in the UpdateMint entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Mint is undefined.",
                  ),
                )
              }
            },
            getPool: mint => {
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(mint.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`Mint pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdateMint entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Mint is undefined.",
                  ),
                )
              }
            },
            getToken1: mint => {
              let optToken1 = inMemoryStore.token->IO.InMemoryStore.Token.get(mint.token1_id)
              switch optToken1 {
              | Some(token1) => token1
              | None =>
                Logging.warn(`Mint token1 data not found. Loading associated token from database.
Please consider loading the token in the UpdateMint entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Mint is undefined.",
                  ),
                )
              }
            },
          },
          pool: {
            set: entity => {
              inMemoryStore.pool->IO.InMemoryStore.Pool.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(pool) with ID ${id}.`),
            get: (id: Types.id) => {
              if optSetOfIds_pool->Set.has(id) {
                inMemoryStore.pool->IO.InMemoryStore.Pool.get(id)
              } else {
                Logging.warn(
                  `The loader for a "Pool" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.pool.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.pool->IO.InMemoryStore.Pool.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
            getToken1: pool => {
              let optToken1 = inMemoryStore.token->IO.InMemoryStore.Token.get(pool.token1_id)
              switch optToken1 {
              | Some(token1) => token1
              | None =>
                Logging.warn(`Pool token1 data not found. Loading associated token from database.
Please consider loading the token in the UpdatePool entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Pool is undefined.",
                  ),
                )
              }
            },
            getToken0: pool => {
              let optToken0 = inMemoryStore.token->IO.InMemoryStore.Token.get(pool.token0_id)
              switch optToken0 {
              | Some(token0) => token0
              | None =>
                Logging.warn(`Pool token0 data not found. Loading associated token from database.
Please consider loading the token in the UpdatePool entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Pool is undefined.",
                  ),
                )
              }
            },
          },
          poolDayData: {
            set: entity => {
              inMemoryStore.poolDayData->IO.InMemoryStore.PoolDayData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(poolDayData) with ID ${id}.`,
              ),
            getPool: poolDayData => {
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(poolDayData.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`PoolDayData pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdatePoolDayData entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of PoolDayData is undefined.",
                  ),
                )
              }
            },
          },
          poolHourData: {
            set: entity => {
              inMemoryStore.poolHourData->IO.InMemoryStore.PoolHourData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(poolHourData) with ID ${id}.`,
              ),
            getPool: poolHourData => {
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(poolHourData.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`PoolHourData pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdatePoolHourData entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of PoolHourData is undefined.",
                  ),
                )
              }
            },
          },
          position: {
            set: entity => {
              inMemoryStore.position->IO.InMemoryStore.Position.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(position) with ID ${id}.`),
            getToken1: position => {
              let optToken1 = inMemoryStore.token->IO.InMemoryStore.Token.get(position.token1_id)
              switch optToken1 {
              | Some(token1) => token1
              | None =>
                Logging.warn(`Position token1 data not found. Loading associated token from database.
Please consider loading the token in the UpdatePosition entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Position is undefined.",
                  ),
                )
              }
            },
            getToken0: position => {
              let optToken0 = inMemoryStore.token->IO.InMemoryStore.Token.get(position.token0_id)
              switch optToken0 {
              | Some(token0) => token0
              | None =>
                Logging.warn(`Position token0 data not found. Loading associated token from database.
Please consider loading the token in the UpdatePosition entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Position is undefined.",
                  ),
                )
              }
            },
            getTickLower: position => {
              let optTickLower =
                inMemoryStore.tick->IO.InMemoryStore.Tick.get(position.tickLower_id)
              switch optTickLower {
              | Some(tickLower) => tickLower
              | None =>
                Logging.warn(`Position tickLower data not found. Loading associated tick from database.
Please consider loading the tick in the UpdatePosition entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Position is undefined.",
                  ),
                )
              }
            },
            getTransaction: position => {
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(position.transaction_id)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                Logging.warn(`Position transaction data not found. Loading associated transaction from database.
Please consider loading the transaction in the UpdatePosition entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Position is undefined.",
                  ),
                )
              }
            },
            getPool: position => {
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(position.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`Position pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdatePosition entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Position is undefined.",
                  ),
                )
              }
            },
            getTickUpper: position => {
              let optTickUpper =
                inMemoryStore.tick->IO.InMemoryStore.Tick.get(position.tickUpper_id)
              switch optTickUpper {
              | Some(tickUpper) => tickUpper
              | None =>
                Logging.warn(`Position tickUpper data not found. Loading associated tick from database.
Please consider loading the tick in the UpdatePosition entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Position is undefined.",
                  ),
                )
              }
            },
          },
          positionSnapshot: {
            set: entity => {
              inMemoryStore.positionSnapshot->IO.InMemoryStore.PositionSnapshot.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(positionSnapshot) with ID ${id}.`,
              ),
            getPool: positionSnapshot => {
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(positionSnapshot.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`PositionSnapshot pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdatePositionSnapshot entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of PositionSnapshot is undefined.",
                  ),
                )
              }
            },
            getPosition: positionSnapshot => {
              let optPosition =
                inMemoryStore.position->IO.InMemoryStore.Position.get(positionSnapshot.position_id)
              switch optPosition {
              | Some(position) => position
              | None =>
                Logging.warn(`PositionSnapshot position data not found. Loading associated position from database.
Please consider loading the position in the UpdatePositionSnapshot entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of PositionSnapshot is undefined.",
                  ),
                )
              }
            },
            getTransaction: positionSnapshot => {
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(
                  positionSnapshot.transaction_id,
                )
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                Logging.warn(`PositionSnapshot transaction data not found. Loading associated transaction from database.
Please consider loading the transaction in the UpdatePositionSnapshot entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of PositionSnapshot is undefined.",
                  ),
                )
              }
            },
          },
          swap: {
            set: entity => {
              inMemoryStore.swap->IO.InMemoryStore.Swap.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(swap) with ID ${id}.`),
            getTick: swap => {
              let optTick = inMemoryStore.tick->IO.InMemoryStore.Tick.get(swap.tick_id)
              switch optTick {
              | Some(tick) => tick
              | None =>
                Logging.warn(`Swap tick data not found. Loading associated tick from database.
Please consider loading the tick in the UpdateSwap entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Swap is undefined.",
                  ),
                )
              }
            },
            getTransaction: swap => {
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(swap.transaction_id)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                Logging.warn(`Swap transaction data not found. Loading associated transaction from database.
Please consider loading the transaction in the UpdateSwap entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Swap is undefined.",
                  ),
                )
              }
            },
            getToken1: swap => {
              let optToken1 = inMemoryStore.token->IO.InMemoryStore.Token.get(swap.token1_id)
              switch optToken1 {
              | Some(token1) => token1
              | None =>
                Logging.warn(`Swap token1 data not found. Loading associated token from database.
Please consider loading the token in the UpdateSwap entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Swap is undefined.",
                  ),
                )
              }
            },
            getToken0: swap => {
              let optToken0 = inMemoryStore.token->IO.InMemoryStore.Token.get(swap.token0_id)
              switch optToken0 {
              | Some(token0) => token0
              | None =>
                Logging.warn(`Swap token0 data not found. Loading associated token from database.
Please consider loading the token in the UpdateSwap entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Swap is undefined.",
                  ),
                )
              }
            },
            getPool: swap => {
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(swap.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`Swap pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdateSwap entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Swap is undefined.",
                  ),
                )
              }
            },
          },
          tick: {
            set: entity => {
              inMemoryStore.tick->IO.InMemoryStore.Tick.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(tick) with ID ${id}.`),
            getPool: tick => {
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(tick.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`Tick pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdateTick entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Tick is undefined.",
                  ),
                )
              }
            },
          },
          tickDayData: {
            set: entity => {
              inMemoryStore.tickDayData->IO.InMemoryStore.TickDayData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(tickDayData) with ID ${id}.`,
              ),
            getPool: tickDayData => {
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(tickDayData.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`TickDayData pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdateTickDayData entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of TickDayData is undefined.",
                  ),
                )
              }
            },
            getTick: tickDayData => {
              let optTick = inMemoryStore.tick->IO.InMemoryStore.Tick.get(tickDayData.tick_id)
              switch optTick {
              | Some(tick) => tick
              | None =>
                Logging.warn(`TickDayData tick data not found. Loading associated tick from database.
Please consider loading the tick in the UpdateTickDayData entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of TickDayData is undefined.",
                  ),
                )
              }
            },
          },
          tickHourData: {
            set: entity => {
              inMemoryStore.tickHourData->IO.InMemoryStore.TickHourData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(tickHourData) with ID ${id}.`,
              ),
            getTick: tickHourData => {
              let optTick = inMemoryStore.tick->IO.InMemoryStore.Tick.get(tickHourData.tick_id)
              switch optTick {
              | Some(tick) => tick
              | None =>
                Logging.warn(`TickHourData tick data not found. Loading associated tick from database.
Please consider loading the tick in the UpdateTickHourData entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of TickHourData is undefined.",
                  ),
                )
              }
            },
            getPool: tickHourData => {
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(tickHourData.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`TickHourData pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdateTickHourData entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of TickHourData is undefined.",
                  ),
                )
              }
            },
          },
          token: {
            set: entity => {
              inMemoryStore.token->IO.InMemoryStore.Token.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(token) with ID ${id}.`),
            get: (id: Types.id) => {
              if optSetOfIds_token->Set.has(id) {
                inMemoryStore.token->IO.InMemoryStore.Token.get(id)
              } else {
                Logging.warn(
                  `The loader for a "Token" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.token.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.token->IO.InMemoryStore.Token.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
          },
          tokenDayData: {
            set: entity => {
              inMemoryStore.tokenDayData->IO.InMemoryStore.TokenDayData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(tokenDayData) with ID ${id}.`,
              ),
            getToken: tokenDayData => {
              let optToken = inMemoryStore.token->IO.InMemoryStore.Token.get(tokenDayData.token_id)
              switch optToken {
              | Some(token) => token
              | None =>
                Logging.warn(`TokenDayData token data not found. Loading associated token from database.
Please consider loading the token in the UpdateTokenDayData entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of TokenDayData is undefined.",
                  ),
                )
              }
            },
          },
          tokenHourData: {
            set: entity => {
              inMemoryStore.tokenHourData->IO.InMemoryStore.TokenHourData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(tokenHourData) with ID ${id}.`,
              ),
            getToken: tokenHourData => {
              let optToken = inMemoryStore.token->IO.InMemoryStore.Token.get(tokenHourData.token_id)
              switch optToken {
              | Some(token) => token
              | None =>
                Logging.warn(`TokenHourData token data not found. Loading associated token from database.
Please consider loading the token in the UpdateTokenHourData entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of TokenHourData is undefined.",
                  ),
                )
              }
            },
          },
          tokenPoolWhitelist: {
            set: entity => {
              inMemoryStore.tokenPoolWhitelist->IO.InMemoryStore.TokenPoolWhitelist.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(tokenPoolWhitelist) with ID ${id}.`,
              ),
            get: (id: Types.id) => {
              if optSetOfIds_tokenPoolWhitelist->Set.has(id) {
                inMemoryStore.tokenPoolWhitelist->IO.InMemoryStore.TokenPoolWhitelist.get(id)
              } else {
                Logging.warn(
                  `The loader for a "TokenPoolWhitelist" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.tokenPoolWhitelist.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.tokenPoolWhitelist->IO.InMemoryStore.TokenPoolWhitelist.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
            getToken: tokenPoolWhitelist => {
              let optToken =
                inMemoryStore.token->IO.InMemoryStore.Token.get(tokenPoolWhitelist.token_id)
              switch optToken {
              | Some(token) => token
              | None =>
                Logging.warn(`TokenPoolWhitelist token data not found. Loading associated token from database.
Please consider loading the token in the UpdateTokenPoolWhitelist entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of TokenPoolWhitelist is undefined.",
                  ),
                )
              }
            },
            getPool: tokenPoolWhitelist => {
              let optPool =
                inMemoryStore.pool->IO.InMemoryStore.Pool.get(tokenPoolWhitelist.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`TokenPoolWhitelist pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdateTokenPoolWhitelist entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of TokenPoolWhitelist is undefined.",
                  ),
                )
              }
            },
          },
          transaction: {
            set: entity => {
              inMemoryStore.transaction->IO.InMemoryStore.Transaction.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(transaction) with ID ${id}.`,
              ),
          },
          uniswapDayData: {
            set: entity => {
              inMemoryStore.uniswapDayData->IO.InMemoryStore.UniswapDayData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(uniswapDayData) with ID ${id}.`,
              ),
          },
        }
      }

      let getHandlerContextAsync = (): handlerContextAsync => {
        {
          log: contextLogger,
          bundle: {
            set: entity => {
              inMemoryStore.bundle->IO.InMemoryStore.Bundle.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(bundle) with ID ${id}.`),
          },
          burn: {
            set: entity => {
              inMemoryStore.burn->IO.InMemoryStore.Burn.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(burn) with ID ${id}.`),
            getTransaction: async burn => {
              let transaction_field = burn.transaction_id
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(transaction_field)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                let entities = await asyncGetters.getTransaction(transaction_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Transaction.set(
                    inMemoryStore.transaction,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Burn transaction data not found. Loading associated transaction from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity transaction of Burn is undefined.",
                    ),
                  )
                }
              }
            },
            getToken0: async burn => {
              let token0_field = burn.token0_id
              let optToken0 = inMemoryStore.token->IO.InMemoryStore.Token.get(token0_field)
              switch optToken0 {
              | Some(token0) => token0
              | None =>
                let entities = await asyncGetters.getToken(token0_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Burn token0 data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token0 of Burn is undefined.",
                    ),
                  )
                }
              }
            },
            getPool: async burn => {
              let pool_field = burn.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Burn pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of Burn is undefined.",
                    ),
                  )
                }
              }
            },
            getToken1: async burn => {
              let token1_field = burn.token1_id
              let optToken1 = inMemoryStore.token->IO.InMemoryStore.Token.get(token1_field)
              switch optToken1 {
              | Some(token1) => token1
              | None =>
                let entities = await asyncGetters.getToken(token1_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Burn token1 data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token1 of Burn is undefined.",
                    ),
                  )
                }
              }
            },
          },
          collect: {
            set: entity => {
              inMemoryStore.collect->IO.InMemoryStore.Collect.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(collect) with ID ${id}.`),
            getTransaction: async collect => {
              let transaction_field = collect.transaction_id
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(transaction_field)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                let entities = await asyncGetters.getTransaction(transaction_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Transaction.set(
                    inMemoryStore.transaction,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Collect transaction data not found. Loading associated transaction from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity transaction of Collect is undefined.",
                    ),
                  )
                }
              }
            },
            getPool: async collect => {
              let pool_field = collect.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Collect pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of Collect is undefined.",
                    ),
                  )
                }
              }
            },
          },
          factory: {
            set: entity => {
              inMemoryStore.factory->IO.InMemoryStore.Factory.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(factory) with ID ${id}.`),
            get: async (id: Types.id) => {
              if optSetOfIds_factory->Set.has(id) {
                inMemoryStore.factory->IO.InMemoryStore.Factory.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.factory->IO.InMemoryStore.Factory.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getFactory(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Factory.set(
                      inMemoryStore.factory,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    Some(entity)
                  | None => None
                  }
                }
              }
            },
          },
          flash: {
            set: entity => {
              inMemoryStore.flash->IO.InMemoryStore.Flash.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(flash) with ID ${id}.`),
            getPool: async flash => {
              let pool_field = flash.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Flash pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of Flash is undefined.",
                    ),
                  )
                }
              }
            },
            getTransaction: async flash => {
              let transaction_field = flash.transaction_id
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(transaction_field)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                let entities = await asyncGetters.getTransaction(transaction_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Transaction.set(
                    inMemoryStore.transaction,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Flash transaction data not found. Loading associated transaction from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity transaction of Flash is undefined.",
                    ),
                  )
                }
              }
            },
          },
          mint: {
            set: entity => {
              inMemoryStore.mint->IO.InMemoryStore.Mint.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(mint) with ID ${id}.`),
            getToken0: async mint => {
              let token0_field = mint.token0_id
              let optToken0 = inMemoryStore.token->IO.InMemoryStore.Token.get(token0_field)
              switch optToken0 {
              | Some(token0) => token0
              | None =>
                let entities = await asyncGetters.getToken(token0_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Mint token0 data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token0 of Mint is undefined.",
                    ),
                  )
                }
              }
            },
            getTransaction: async mint => {
              let transaction_field = mint.transaction_id
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(transaction_field)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                let entities = await asyncGetters.getTransaction(transaction_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Transaction.set(
                    inMemoryStore.transaction,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Mint transaction data not found. Loading associated transaction from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity transaction of Mint is undefined.",
                    ),
                  )
                }
              }
            },
            getPool: async mint => {
              let pool_field = mint.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Mint pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of Mint is undefined.",
                    ),
                  )
                }
              }
            },
            getToken1: async mint => {
              let token1_field = mint.token1_id
              let optToken1 = inMemoryStore.token->IO.InMemoryStore.Token.get(token1_field)
              switch optToken1 {
              | Some(token1) => token1
              | None =>
                let entities = await asyncGetters.getToken(token1_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Mint token1 data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token1 of Mint is undefined.",
                    ),
                  )
                }
              }
            },
          },
          pool: {
            set: entity => {
              inMemoryStore.pool->IO.InMemoryStore.Pool.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(pool) with ID ${id}.`),
            get: async (id: Types.id) => {
              if optSetOfIds_pool->Set.has(id) {
                inMemoryStore.pool->IO.InMemoryStore.Pool.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.pool->IO.InMemoryStore.Pool.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getPool(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Pool.set(
                      inMemoryStore.pool,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    Some(entity)
                  | None => None
                  }
                }
              }
            },
            getToken1: async pool => {
              let token1_field = pool.token1_id
              let optToken1 = inMemoryStore.token->IO.InMemoryStore.Token.get(token1_field)
              switch optToken1 {
              | Some(token1) => token1
              | None =>
                let entities = await asyncGetters.getToken(token1_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Pool token1 data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token1 of Pool is undefined.",
                    ),
                  )
                }
              }
            },
            getToken0: async pool => {
              let token0_field = pool.token0_id
              let optToken0 = inMemoryStore.token->IO.InMemoryStore.Token.get(token0_field)
              switch optToken0 {
              | Some(token0) => token0
              | None =>
                let entities = await asyncGetters.getToken(token0_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Pool token0 data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token0 of Pool is undefined.",
                    ),
                  )
                }
              }
            },
          },
          poolDayData: {
            set: entity => {
              inMemoryStore.poolDayData->IO.InMemoryStore.PoolDayData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(poolDayData) with ID ${id}.`,
              ),
            getPool: async poolDayData => {
              let pool_field = poolDayData.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`PoolDayData pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of PoolDayData is undefined.",
                    ),
                  )
                }
              }
            },
          },
          poolHourData: {
            set: entity => {
              inMemoryStore.poolHourData->IO.InMemoryStore.PoolHourData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(poolHourData) with ID ${id}.`,
              ),
            getPool: async poolHourData => {
              let pool_field = poolHourData.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`PoolHourData pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of PoolHourData is undefined.",
                    ),
                  )
                }
              }
            },
          },
          position: {
            set: entity => {
              inMemoryStore.position->IO.InMemoryStore.Position.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(position) with ID ${id}.`),
            getToken1: async position => {
              let token1_field = position.token1_id
              let optToken1 = inMemoryStore.token->IO.InMemoryStore.Token.get(token1_field)
              switch optToken1 {
              | Some(token1) => token1
              | None =>
                let entities = await asyncGetters.getToken(token1_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Position token1 data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token1 of Position is undefined.",
                    ),
                  )
                }
              }
            },
            getToken0: async position => {
              let token0_field = position.token0_id
              let optToken0 = inMemoryStore.token->IO.InMemoryStore.Token.get(token0_field)
              switch optToken0 {
              | Some(token0) => token0
              | None =>
                let entities = await asyncGetters.getToken(token0_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Position token0 data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token0 of Position is undefined.",
                    ),
                  )
                }
              }
            },
            getTickLower: async position => {
              let tickLower_field = position.tickLower_id
              let optTickLower = inMemoryStore.tick->IO.InMemoryStore.Tick.get(tickLower_field)
              switch optTickLower {
              | Some(tickLower) => tickLower
              | None =>
                let entities = await asyncGetters.getTick(tickLower_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Tick.set(
                    inMemoryStore.tick,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Position tickLower data not found. Loading associated tick from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity tickLower of Position is undefined.",
                    ),
                  )
                }
              }
            },
            getTransaction: async position => {
              let transaction_field = position.transaction_id
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(transaction_field)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                let entities = await asyncGetters.getTransaction(transaction_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Transaction.set(
                    inMemoryStore.transaction,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Position transaction data not found. Loading associated transaction from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity transaction of Position is undefined.",
                    ),
                  )
                }
              }
            },
            getPool: async position => {
              let pool_field = position.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Position pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of Position is undefined.",
                    ),
                  )
                }
              }
            },
            getTickUpper: async position => {
              let tickUpper_field = position.tickUpper_id
              let optTickUpper = inMemoryStore.tick->IO.InMemoryStore.Tick.get(tickUpper_field)
              switch optTickUpper {
              | Some(tickUpper) => tickUpper
              | None =>
                let entities = await asyncGetters.getTick(tickUpper_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Tick.set(
                    inMemoryStore.tick,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Position tickUpper data not found. Loading associated tick from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity tickUpper of Position is undefined.",
                    ),
                  )
                }
              }
            },
          },
          positionSnapshot: {
            set: entity => {
              inMemoryStore.positionSnapshot->IO.InMemoryStore.PositionSnapshot.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(positionSnapshot) with ID ${id}.`,
              ),
            getPool: async positionSnapshot => {
              let pool_field = positionSnapshot.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`PositionSnapshot pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of PositionSnapshot is undefined.",
                    ),
                  )
                }
              }
            },
            getPosition: async positionSnapshot => {
              let position_field = positionSnapshot.position_id
              let optPosition =
                inMemoryStore.position->IO.InMemoryStore.Position.get(position_field)
              switch optPosition {
              | Some(position) => position
              | None =>
                let entities = await asyncGetters.getPosition(position_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Position.set(
                    inMemoryStore.position,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`PositionSnapshot position data not found. Loading associated position from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity position of PositionSnapshot is undefined.",
                    ),
                  )
                }
              }
            },
            getTransaction: async positionSnapshot => {
              let transaction_field = positionSnapshot.transaction_id
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(transaction_field)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                let entities = await asyncGetters.getTransaction(transaction_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Transaction.set(
                    inMemoryStore.transaction,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`PositionSnapshot transaction data not found. Loading associated transaction from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity transaction of PositionSnapshot is undefined.",
                    ),
                  )
                }
              }
            },
          },
          swap: {
            set: entity => {
              inMemoryStore.swap->IO.InMemoryStore.Swap.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(swap) with ID ${id}.`),
            getTick: async swap => {
              let tick_field = swap.tick_id
              let optTick = inMemoryStore.tick->IO.InMemoryStore.Tick.get(tick_field)
              switch optTick {
              | Some(tick) => tick
              | None =>
                let entities = await asyncGetters.getTick(tick_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Tick.set(
                    inMemoryStore.tick,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Swap tick data not found. Loading associated tick from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity tick of Swap is undefined.",
                    ),
                  )
                }
              }
            },
            getTransaction: async swap => {
              let transaction_field = swap.transaction_id
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(transaction_field)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                let entities = await asyncGetters.getTransaction(transaction_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Transaction.set(
                    inMemoryStore.transaction,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Swap transaction data not found. Loading associated transaction from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity transaction of Swap is undefined.",
                    ),
                  )
                }
              }
            },
            getToken1: async swap => {
              let token1_field = swap.token1_id
              let optToken1 = inMemoryStore.token->IO.InMemoryStore.Token.get(token1_field)
              switch optToken1 {
              | Some(token1) => token1
              | None =>
                let entities = await asyncGetters.getToken(token1_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Swap token1 data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token1 of Swap is undefined.",
                    ),
                  )
                }
              }
            },
            getToken0: async swap => {
              let token0_field = swap.token0_id
              let optToken0 = inMemoryStore.token->IO.InMemoryStore.Token.get(token0_field)
              switch optToken0 {
              | Some(token0) => token0
              | None =>
                let entities = await asyncGetters.getToken(token0_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Swap token0 data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token0 of Swap is undefined.",
                    ),
                  )
                }
              }
            },
            getPool: async swap => {
              let pool_field = swap.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Swap pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of Swap is undefined.",
                    ),
                  )
                }
              }
            },
          },
          tick: {
            set: entity => {
              inMemoryStore.tick->IO.InMemoryStore.Tick.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(tick) with ID ${id}.`),
            getPool: async tick => {
              let pool_field = tick.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Tick pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of Tick is undefined.",
                    ),
                  )
                }
              }
            },
          },
          tickDayData: {
            set: entity => {
              inMemoryStore.tickDayData->IO.InMemoryStore.TickDayData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(tickDayData) with ID ${id}.`,
              ),
            getPool: async tickDayData => {
              let pool_field = tickDayData.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`TickDayData pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of TickDayData is undefined.",
                    ),
                  )
                }
              }
            },
            getTick: async tickDayData => {
              let tick_field = tickDayData.tick_id
              let optTick = inMemoryStore.tick->IO.InMemoryStore.Tick.get(tick_field)
              switch optTick {
              | Some(tick) => tick
              | None =>
                let entities = await asyncGetters.getTick(tick_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Tick.set(
                    inMemoryStore.tick,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`TickDayData tick data not found. Loading associated tick from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity tick of TickDayData is undefined.",
                    ),
                  )
                }
              }
            },
          },
          tickHourData: {
            set: entity => {
              inMemoryStore.tickHourData->IO.InMemoryStore.TickHourData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(tickHourData) with ID ${id}.`,
              ),
            getTick: async tickHourData => {
              let tick_field = tickHourData.tick_id
              let optTick = inMemoryStore.tick->IO.InMemoryStore.Tick.get(tick_field)
              switch optTick {
              | Some(tick) => tick
              | None =>
                let entities = await asyncGetters.getTick(tick_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Tick.set(
                    inMemoryStore.tick,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`TickHourData tick data not found. Loading associated tick from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity tick of TickHourData is undefined.",
                    ),
                  )
                }
              }
            },
            getPool: async tickHourData => {
              let pool_field = tickHourData.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`TickHourData pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of TickHourData is undefined.",
                    ),
                  )
                }
              }
            },
          },
          token: {
            set: entity => {
              inMemoryStore.token->IO.InMemoryStore.Token.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(token) with ID ${id}.`),
            get: async (id: Types.id) => {
              if optSetOfIds_token->Set.has(id) {
                inMemoryStore.token->IO.InMemoryStore.Token.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.token->IO.InMemoryStore.Token.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getToken(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Token.set(
                      inMemoryStore.token,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    Some(entity)
                  | None => None
                  }
                }
              }
            },
          },
          tokenDayData: {
            set: entity => {
              inMemoryStore.tokenDayData->IO.InMemoryStore.TokenDayData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(tokenDayData) with ID ${id}.`,
              ),
            getToken: async tokenDayData => {
              let token_field = tokenDayData.token_id
              let optToken = inMemoryStore.token->IO.InMemoryStore.Token.get(token_field)
              switch optToken {
              | Some(token) => token
              | None =>
                let entities = await asyncGetters.getToken(token_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`TokenDayData token data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token of TokenDayData is undefined.",
                    ),
                  )
                }
              }
            },
          },
          tokenHourData: {
            set: entity => {
              inMemoryStore.tokenHourData->IO.InMemoryStore.TokenHourData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(tokenHourData) with ID ${id}.`,
              ),
            getToken: async tokenHourData => {
              let token_field = tokenHourData.token_id
              let optToken = inMemoryStore.token->IO.InMemoryStore.Token.get(token_field)
              switch optToken {
              | Some(token) => token
              | None =>
                let entities = await asyncGetters.getToken(token_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`TokenHourData token data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token of TokenHourData is undefined.",
                    ),
                  )
                }
              }
            },
          },
          tokenPoolWhitelist: {
            set: entity => {
              inMemoryStore.tokenPoolWhitelist->IO.InMemoryStore.TokenPoolWhitelist.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(tokenPoolWhitelist) with ID ${id}.`,
              ),
            get: async (id: Types.id) => {
              if optSetOfIds_tokenPoolWhitelist->Set.has(id) {
                inMemoryStore.tokenPoolWhitelist->IO.InMemoryStore.TokenPoolWhitelist.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.tokenPoolWhitelist->IO.InMemoryStore.TokenPoolWhitelist.get(
                  id,
                ) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getTokenPoolWhitelist(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.TokenPoolWhitelist.set(
                      inMemoryStore.tokenPoolWhitelist,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    Some(entity)
                  | None => None
                  }
                }
              }
            },
            getToken: async tokenPoolWhitelist => {
              let token_field = tokenPoolWhitelist.token_id
              let optToken = inMemoryStore.token->IO.InMemoryStore.Token.get(token_field)
              switch optToken {
              | Some(token) => token
              | None =>
                let entities = await asyncGetters.getToken(token_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`TokenPoolWhitelist token data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token of TokenPoolWhitelist is undefined.",
                    ),
                  )
                }
              }
            },
            getPool: async tokenPoolWhitelist => {
              let pool_field = tokenPoolWhitelist.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`TokenPoolWhitelist pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of TokenPoolWhitelist is undefined.",
                    ),
                  )
                }
              }
            },
          },
          transaction: {
            set: entity => {
              inMemoryStore.transaction->IO.InMemoryStore.Transaction.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(transaction) with ID ${id}.`,
              ),
          },
          uniswapDayData: {
            set: entity => {
              inMemoryStore.uniswapDayData->IO.InMemoryStore.UniswapDayData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(uniswapDayData) with ID ${id}.`,
              ),
          },
        }
      }

      {
        logger,
        log: contextLogger,
        getEntitiesToLoad: () => entitiesToLoad,
        getAddedDynamicContractRegistrations: () => addedDynamicContractRegistrations,
        getLoaderContext: () => loaderContext,
        getHandlerContextSync,
        getHandlerContextAsync,
      }
    }
  }
}

module NonfungiblePositionManagerContract = {
  module IncreaseLiquidityEvent = {
    type loaderContext = Types.NonfungiblePositionManagerContract.IncreaseLiquidityEvent.loaderContext
    type handlerContext = Types.NonfungiblePositionManagerContract.IncreaseLiquidityEvent.handlerContext
    type handlerContextAsync = Types.NonfungiblePositionManagerContract.IncreaseLiquidityEvent.handlerContextAsync
    type context = genericContextCreatorFunctions<
      loaderContext,
      handlerContext,
      handlerContextAsync,
    >

    let contextCreator: contextCreator<
      Types.NonfungiblePositionManagerContract.IncreaseLiquidityEvent.eventArgs,
      loaderContext,
      handlerContext,
      handlerContextAsync,
    > = (~inMemoryStore, ~chainId, ~event, ~logger, ~asyncGetters) => {
      // NOTE: we could optimise this code to onle create a logger if there was a log called.
      let logger = logger->Logging.createChildFrom(
        ~logger=_,
        ~params={
          "context": "NonfungiblePositionManager.IncreaseLiquidity",
          "chainId": chainId,
          "block": event.blockNumber,
          "logIndex": event.logIndex,
          "txHash": event.transactionHash,
        },
      )

      let contextLogger: Logs.userLogger = {
        info: (message: string) => logger->Logging.uinfo(message),
        debug: (message: string) => logger->Logging.udebug(message),
        warn: (message: string) => logger->Logging.uwarn(message),
        error: (message: string) => logger->Logging.uerror(message),
        errorWithExn: (exn: option<Js.Exn.t>, message: string) =>
          logger->Logging.uerrorWithExn(exn, message),
      }

      let optSetOfIds_position: Set.t<Types.id> = Set.make()
      let optSetOfIds_positionSnapshot: Set.t<Types.id> = Set.make()
      let optSetOfIds_token: Set.t<Types.id> = Set.make()

      let entitiesToLoad: array<Types.entityRead> = []

      let addedDynamicContractRegistrations: array<Types.dynamicContractRegistryEntity> = []

      //Loader context can be defined as a value and the getter can return that value

      @warning("-16")
      let loaderContext: loaderContext = {
        log: contextLogger,
        contractRegistration: {
          //TODO only add contracts we've registered for the event in the config
          addFactory: (contractAddress: Ethers.ethAddress) => {
            let eventId = EventUtils.packEventIndex(
              ~blockNumber=event.blockNumber,
              ~logIndex=event.logIndex,
            )
            let dynamicContractRegistration: Types.dynamicContractRegistryEntity = {
              chainId,
              eventId,
              contractAddress,
              contractType: "Factory",
            }

            addedDynamicContractRegistrations->Js.Array2.push(dynamicContractRegistration)->ignore

            inMemoryStore.dynamicContractRegistry->IO.InMemoryStore.DynamicContractRegistry.set(
              ~key={chainId, contractAddress},
              ~entity=dynamicContractRegistration,
              ~dbOp=Set,
            )
          },
          //TODO only add contracts we've registered for the event in the config
          addNonfungiblePositionManager: (contractAddress: Ethers.ethAddress) => {
            let eventId = EventUtils.packEventIndex(
              ~blockNumber=event.blockNumber,
              ~logIndex=event.logIndex,
            )
            let dynamicContractRegistration: Types.dynamicContractRegistryEntity = {
              chainId,
              eventId,
              contractAddress,
              contractType: "NonfungiblePositionManager",
            }

            addedDynamicContractRegistrations->Js.Array2.push(dynamicContractRegistration)->ignore

            inMemoryStore.dynamicContractRegistry->IO.InMemoryStore.DynamicContractRegistry.set(
              ~key={chainId, contractAddress},
              ~entity=dynamicContractRegistration,
              ~dbOp=Set,
            )
          },
          //TODO only add contracts we've registered for the event in the config
          addPool: (contractAddress: Ethers.ethAddress) => {
            let eventId = EventUtils.packEventIndex(
              ~blockNumber=event.blockNumber,
              ~logIndex=event.logIndex,
            )
            let dynamicContractRegistration: Types.dynamicContractRegistryEntity = {
              chainId,
              eventId,
              contractAddress,
              contractType: "Pool",
            }

            addedDynamicContractRegistrations->Js.Array2.push(dynamicContractRegistration)->ignore

            inMemoryStore.dynamicContractRegistry->IO.InMemoryStore.DynamicContractRegistry.set(
              ~key={chainId, contractAddress},
              ~entity=dynamicContractRegistration,
              ~dbOp=Set,
            )
          },
        },
        position: {
          load: (id: Types.id, ~loaders={}) => {
            let _ = optSetOfIds_position->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.PositionRead(id, loaders))
          },
        },
        positionSnapshot: {
          load: (id: Types.id, ~loaders={}) => {
            let _ = optSetOfIds_positionSnapshot->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.PositionSnapshotRead(id, loaders))
          },
        },
        token: {
          load: (id: Types.id) => {
            let _ = optSetOfIds_token->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.TokenRead(id))
          },
        },
      }

      //handler context must be defined as a getter functoin so that it can construct the context
      //without stale values whenever it is used
      let getHandlerContextSync: unit => handlerContext = () => {
        {
          log: contextLogger,
          bundle: {
            set: entity => {
              inMemoryStore.bundle->IO.InMemoryStore.Bundle.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(bundle) with ID ${id}.`),
          },
          burn: {
            set: entity => {
              inMemoryStore.burn->IO.InMemoryStore.Burn.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(burn) with ID ${id}.`),
            getTransaction: burn => {
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(burn.transaction_id)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                Logging.warn(`Burn transaction data not found. Loading associated transaction from database.
Please consider loading the transaction in the UpdateBurn entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Burn is undefined.",
                  ),
                )
              }
            },
            getToken0: burn => {
              let optToken0 = inMemoryStore.token->IO.InMemoryStore.Token.get(burn.token0_id)
              switch optToken0 {
              | Some(token0) => token0
              | None =>
                Logging.warn(`Burn token0 data not found. Loading associated token from database.
Please consider loading the token in the UpdateBurn entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Burn is undefined.",
                  ),
                )
              }
            },
            getPool: burn => {
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(burn.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`Burn pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdateBurn entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Burn is undefined.",
                  ),
                )
              }
            },
            getToken1: burn => {
              let optToken1 = inMemoryStore.token->IO.InMemoryStore.Token.get(burn.token1_id)
              switch optToken1 {
              | Some(token1) => token1
              | None =>
                Logging.warn(`Burn token1 data not found. Loading associated token from database.
Please consider loading the token in the UpdateBurn entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Burn is undefined.",
                  ),
                )
              }
            },
          },
          collect: {
            set: entity => {
              inMemoryStore.collect->IO.InMemoryStore.Collect.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(collect) with ID ${id}.`),
            getTransaction: collect => {
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(collect.transaction_id)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                Logging.warn(`Collect transaction data not found. Loading associated transaction from database.
Please consider loading the transaction in the UpdateCollect entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Collect is undefined.",
                  ),
                )
              }
            },
            getPool: collect => {
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(collect.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`Collect pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdateCollect entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Collect is undefined.",
                  ),
                )
              }
            },
          },
          factory: {
            set: entity => {
              inMemoryStore.factory->IO.InMemoryStore.Factory.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(factory) with ID ${id}.`),
          },
          flash: {
            set: entity => {
              inMemoryStore.flash->IO.InMemoryStore.Flash.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(flash) with ID ${id}.`),
            getPool: flash => {
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(flash.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`Flash pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdateFlash entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Flash is undefined.",
                  ),
                )
              }
            },
            getTransaction: flash => {
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(flash.transaction_id)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                Logging.warn(`Flash transaction data not found. Loading associated transaction from database.
Please consider loading the transaction in the UpdateFlash entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Flash is undefined.",
                  ),
                )
              }
            },
          },
          mint: {
            set: entity => {
              inMemoryStore.mint->IO.InMemoryStore.Mint.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(mint) with ID ${id}.`),
            getToken0: mint => {
              let optToken0 = inMemoryStore.token->IO.InMemoryStore.Token.get(mint.token0_id)
              switch optToken0 {
              | Some(token0) => token0
              | None =>
                Logging.warn(`Mint token0 data not found. Loading associated token from database.
Please consider loading the token in the UpdateMint entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Mint is undefined.",
                  ),
                )
              }
            },
            getTransaction: mint => {
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(mint.transaction_id)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                Logging.warn(`Mint transaction data not found. Loading associated transaction from database.
Please consider loading the transaction in the UpdateMint entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Mint is undefined.",
                  ),
                )
              }
            },
            getPool: mint => {
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(mint.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`Mint pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdateMint entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Mint is undefined.",
                  ),
                )
              }
            },
            getToken1: mint => {
              let optToken1 = inMemoryStore.token->IO.InMemoryStore.Token.get(mint.token1_id)
              switch optToken1 {
              | Some(token1) => token1
              | None =>
                Logging.warn(`Mint token1 data not found. Loading associated token from database.
Please consider loading the token in the UpdateMint entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Mint is undefined.",
                  ),
                )
              }
            },
          },
          pool: {
            set: entity => {
              inMemoryStore.pool->IO.InMemoryStore.Pool.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(pool) with ID ${id}.`),
            getToken1: pool => {
              let optToken1 = inMemoryStore.token->IO.InMemoryStore.Token.get(pool.token1_id)
              switch optToken1 {
              | Some(token1) => token1
              | None =>
                Logging.warn(`Pool token1 data not found. Loading associated token from database.
Please consider loading the token in the UpdatePool entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Pool is undefined.",
                  ),
                )
              }
            },
            getToken0: pool => {
              let optToken0 = inMemoryStore.token->IO.InMemoryStore.Token.get(pool.token0_id)
              switch optToken0 {
              | Some(token0) => token0
              | None =>
                Logging.warn(`Pool token0 data not found. Loading associated token from database.
Please consider loading the token in the UpdatePool entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Pool is undefined.",
                  ),
                )
              }
            },
          },
          poolDayData: {
            set: entity => {
              inMemoryStore.poolDayData->IO.InMemoryStore.PoolDayData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(poolDayData) with ID ${id}.`,
              ),
            getPool: poolDayData => {
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(poolDayData.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`PoolDayData pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdatePoolDayData entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of PoolDayData is undefined.",
                  ),
                )
              }
            },
          },
          poolHourData: {
            set: entity => {
              inMemoryStore.poolHourData->IO.InMemoryStore.PoolHourData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(poolHourData) with ID ${id}.`,
              ),
            getPool: poolHourData => {
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(poolHourData.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`PoolHourData pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdatePoolHourData entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of PoolHourData is undefined.",
                  ),
                )
              }
            },
          },
          position: {
            set: entity => {
              inMemoryStore.position->IO.InMemoryStore.Position.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(position) with ID ${id}.`),
            get: (id: Types.id) => {
              if optSetOfIds_position->Set.has(id) {
                inMemoryStore.position->IO.InMemoryStore.Position.get(id)
              } else {
                Logging.warn(
                  `The loader for a "Position" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.position.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.position->IO.InMemoryStore.Position.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
            getToken1: position => {
              let optToken1 = inMemoryStore.token->IO.InMemoryStore.Token.get(position.token1_id)
              switch optToken1 {
              | Some(token1) => token1
              | None =>
                Logging.warn(`Position token1 data not found. Loading associated token from database.
Please consider loading the token in the UpdatePosition entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Position is undefined.",
                  ),
                )
              }
            },
            getToken0: position => {
              let optToken0 = inMemoryStore.token->IO.InMemoryStore.Token.get(position.token0_id)
              switch optToken0 {
              | Some(token0) => token0
              | None =>
                Logging.warn(`Position token0 data not found. Loading associated token from database.
Please consider loading the token in the UpdatePosition entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Position is undefined.",
                  ),
                )
              }
            },
            getTickLower: position => {
              let optTickLower =
                inMemoryStore.tick->IO.InMemoryStore.Tick.get(position.tickLower_id)
              switch optTickLower {
              | Some(tickLower) => tickLower
              | None =>
                Logging.warn(`Position tickLower data not found. Loading associated tick from database.
Please consider loading the tick in the UpdatePosition entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Position is undefined.",
                  ),
                )
              }
            },
            getTransaction: position => {
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(position.transaction_id)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                Logging.warn(`Position transaction data not found. Loading associated transaction from database.
Please consider loading the transaction in the UpdatePosition entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Position is undefined.",
                  ),
                )
              }
            },
            getPool: position => {
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(position.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`Position pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdatePosition entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Position is undefined.",
                  ),
                )
              }
            },
            getTickUpper: position => {
              let optTickUpper =
                inMemoryStore.tick->IO.InMemoryStore.Tick.get(position.tickUpper_id)
              switch optTickUpper {
              | Some(tickUpper) => tickUpper
              | None =>
                Logging.warn(`Position tickUpper data not found. Loading associated tick from database.
Please consider loading the tick in the UpdatePosition entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Position is undefined.",
                  ),
                )
              }
            },
          },
          positionSnapshot: {
            set: entity => {
              inMemoryStore.positionSnapshot->IO.InMemoryStore.PositionSnapshot.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(positionSnapshot) with ID ${id}.`,
              ),
            get: (id: Types.id) => {
              if optSetOfIds_positionSnapshot->Set.has(id) {
                inMemoryStore.positionSnapshot->IO.InMemoryStore.PositionSnapshot.get(id)
              } else {
                Logging.warn(
                  `The loader for a "PositionSnapshot" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.positionSnapshot.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.positionSnapshot->IO.InMemoryStore.PositionSnapshot.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
            getPool: positionSnapshot => {
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(positionSnapshot.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`PositionSnapshot pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdatePositionSnapshot entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of PositionSnapshot is undefined.",
                  ),
                )
              }
            },
            getPosition: positionSnapshot => {
              let optPosition =
                inMemoryStore.position->IO.InMemoryStore.Position.get(positionSnapshot.position_id)
              switch optPosition {
              | Some(position) => position
              | None =>
                Logging.warn(`PositionSnapshot position data not found. Loading associated position from database.
Please consider loading the position in the UpdatePositionSnapshot entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of PositionSnapshot is undefined.",
                  ),
                )
              }
            },
            getTransaction: positionSnapshot => {
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(
                  positionSnapshot.transaction_id,
                )
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                Logging.warn(`PositionSnapshot transaction data not found. Loading associated transaction from database.
Please consider loading the transaction in the UpdatePositionSnapshot entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of PositionSnapshot is undefined.",
                  ),
                )
              }
            },
          },
          swap: {
            set: entity => {
              inMemoryStore.swap->IO.InMemoryStore.Swap.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(swap) with ID ${id}.`),
            getTick: swap => {
              let optTick = inMemoryStore.tick->IO.InMemoryStore.Tick.get(swap.tick_id)
              switch optTick {
              | Some(tick) => tick
              | None =>
                Logging.warn(`Swap tick data not found. Loading associated tick from database.
Please consider loading the tick in the UpdateSwap entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Swap is undefined.",
                  ),
                )
              }
            },
            getTransaction: swap => {
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(swap.transaction_id)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                Logging.warn(`Swap transaction data not found. Loading associated transaction from database.
Please consider loading the transaction in the UpdateSwap entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Swap is undefined.",
                  ),
                )
              }
            },
            getToken1: swap => {
              let optToken1 = inMemoryStore.token->IO.InMemoryStore.Token.get(swap.token1_id)
              switch optToken1 {
              | Some(token1) => token1
              | None =>
                Logging.warn(`Swap token1 data not found. Loading associated token from database.
Please consider loading the token in the UpdateSwap entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Swap is undefined.",
                  ),
                )
              }
            },
            getToken0: swap => {
              let optToken0 = inMemoryStore.token->IO.InMemoryStore.Token.get(swap.token0_id)
              switch optToken0 {
              | Some(token0) => token0
              | None =>
                Logging.warn(`Swap token0 data not found. Loading associated token from database.
Please consider loading the token in the UpdateSwap entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Swap is undefined.",
                  ),
                )
              }
            },
            getPool: swap => {
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(swap.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`Swap pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdateSwap entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Swap is undefined.",
                  ),
                )
              }
            },
          },
          tick: {
            set: entity => {
              inMemoryStore.tick->IO.InMemoryStore.Tick.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(tick) with ID ${id}.`),
            getPool: tick => {
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(tick.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`Tick pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdateTick entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Tick is undefined.",
                  ),
                )
              }
            },
          },
          tickDayData: {
            set: entity => {
              inMemoryStore.tickDayData->IO.InMemoryStore.TickDayData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(tickDayData) with ID ${id}.`,
              ),
            getPool: tickDayData => {
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(tickDayData.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`TickDayData pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdateTickDayData entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of TickDayData is undefined.",
                  ),
                )
              }
            },
            getTick: tickDayData => {
              let optTick = inMemoryStore.tick->IO.InMemoryStore.Tick.get(tickDayData.tick_id)
              switch optTick {
              | Some(tick) => tick
              | None =>
                Logging.warn(`TickDayData tick data not found. Loading associated tick from database.
Please consider loading the tick in the UpdateTickDayData entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of TickDayData is undefined.",
                  ),
                )
              }
            },
          },
          tickHourData: {
            set: entity => {
              inMemoryStore.tickHourData->IO.InMemoryStore.TickHourData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(tickHourData) with ID ${id}.`,
              ),
            getTick: tickHourData => {
              let optTick = inMemoryStore.tick->IO.InMemoryStore.Tick.get(tickHourData.tick_id)
              switch optTick {
              | Some(tick) => tick
              | None =>
                Logging.warn(`TickHourData tick data not found. Loading associated tick from database.
Please consider loading the tick in the UpdateTickHourData entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of TickHourData is undefined.",
                  ),
                )
              }
            },
            getPool: tickHourData => {
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(tickHourData.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`TickHourData pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdateTickHourData entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of TickHourData is undefined.",
                  ),
                )
              }
            },
          },
          token: {
            set: entity => {
              inMemoryStore.token->IO.InMemoryStore.Token.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(token) with ID ${id}.`),
            get: (id: Types.id) => {
              if optSetOfIds_token->Set.has(id) {
                inMemoryStore.token->IO.InMemoryStore.Token.get(id)
              } else {
                Logging.warn(
                  `The loader for a "Token" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.token.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.token->IO.InMemoryStore.Token.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
          },
          tokenDayData: {
            set: entity => {
              inMemoryStore.tokenDayData->IO.InMemoryStore.TokenDayData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(tokenDayData) with ID ${id}.`,
              ),
            getToken: tokenDayData => {
              let optToken = inMemoryStore.token->IO.InMemoryStore.Token.get(tokenDayData.token_id)
              switch optToken {
              | Some(token) => token
              | None =>
                Logging.warn(`TokenDayData token data not found. Loading associated token from database.
Please consider loading the token in the UpdateTokenDayData entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of TokenDayData is undefined.",
                  ),
                )
              }
            },
          },
          tokenHourData: {
            set: entity => {
              inMemoryStore.tokenHourData->IO.InMemoryStore.TokenHourData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(tokenHourData) with ID ${id}.`,
              ),
            getToken: tokenHourData => {
              let optToken = inMemoryStore.token->IO.InMemoryStore.Token.get(tokenHourData.token_id)
              switch optToken {
              | Some(token) => token
              | None =>
                Logging.warn(`TokenHourData token data not found. Loading associated token from database.
Please consider loading the token in the UpdateTokenHourData entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of TokenHourData is undefined.",
                  ),
                )
              }
            },
          },
          tokenPoolWhitelist: {
            set: entity => {
              inMemoryStore.tokenPoolWhitelist->IO.InMemoryStore.TokenPoolWhitelist.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(tokenPoolWhitelist) with ID ${id}.`,
              ),
            getToken: tokenPoolWhitelist => {
              let optToken =
                inMemoryStore.token->IO.InMemoryStore.Token.get(tokenPoolWhitelist.token_id)
              switch optToken {
              | Some(token) => token
              | None =>
                Logging.warn(`TokenPoolWhitelist token data not found. Loading associated token from database.
Please consider loading the token in the UpdateTokenPoolWhitelist entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of TokenPoolWhitelist is undefined.",
                  ),
                )
              }
            },
            getPool: tokenPoolWhitelist => {
              let optPool =
                inMemoryStore.pool->IO.InMemoryStore.Pool.get(tokenPoolWhitelist.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`TokenPoolWhitelist pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdateTokenPoolWhitelist entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of TokenPoolWhitelist is undefined.",
                  ),
                )
              }
            },
          },
          transaction: {
            set: entity => {
              inMemoryStore.transaction->IO.InMemoryStore.Transaction.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(transaction) with ID ${id}.`,
              ),
          },
          uniswapDayData: {
            set: entity => {
              inMemoryStore.uniswapDayData->IO.InMemoryStore.UniswapDayData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(uniswapDayData) with ID ${id}.`,
              ),
          },
        }
      }

      let getHandlerContextAsync = (): handlerContextAsync => {
        {
          log: contextLogger,
          bundle: {
            set: entity => {
              inMemoryStore.bundle->IO.InMemoryStore.Bundle.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(bundle) with ID ${id}.`),
          },
          burn: {
            set: entity => {
              inMemoryStore.burn->IO.InMemoryStore.Burn.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(burn) with ID ${id}.`),
            getTransaction: async burn => {
              let transaction_field = burn.transaction_id
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(transaction_field)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                let entities = await asyncGetters.getTransaction(transaction_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Transaction.set(
                    inMemoryStore.transaction,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Burn transaction data not found. Loading associated transaction from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity transaction of Burn is undefined.",
                    ),
                  )
                }
              }
            },
            getToken0: async burn => {
              let token0_field = burn.token0_id
              let optToken0 = inMemoryStore.token->IO.InMemoryStore.Token.get(token0_field)
              switch optToken0 {
              | Some(token0) => token0
              | None =>
                let entities = await asyncGetters.getToken(token0_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Burn token0 data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token0 of Burn is undefined.",
                    ),
                  )
                }
              }
            },
            getPool: async burn => {
              let pool_field = burn.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Burn pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of Burn is undefined.",
                    ),
                  )
                }
              }
            },
            getToken1: async burn => {
              let token1_field = burn.token1_id
              let optToken1 = inMemoryStore.token->IO.InMemoryStore.Token.get(token1_field)
              switch optToken1 {
              | Some(token1) => token1
              | None =>
                let entities = await asyncGetters.getToken(token1_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Burn token1 data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token1 of Burn is undefined.",
                    ),
                  )
                }
              }
            },
          },
          collect: {
            set: entity => {
              inMemoryStore.collect->IO.InMemoryStore.Collect.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(collect) with ID ${id}.`),
            getTransaction: async collect => {
              let transaction_field = collect.transaction_id
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(transaction_field)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                let entities = await asyncGetters.getTransaction(transaction_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Transaction.set(
                    inMemoryStore.transaction,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Collect transaction data not found. Loading associated transaction from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity transaction of Collect is undefined.",
                    ),
                  )
                }
              }
            },
            getPool: async collect => {
              let pool_field = collect.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Collect pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of Collect is undefined.",
                    ),
                  )
                }
              }
            },
          },
          factory: {
            set: entity => {
              inMemoryStore.factory->IO.InMemoryStore.Factory.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(factory) with ID ${id}.`),
          },
          flash: {
            set: entity => {
              inMemoryStore.flash->IO.InMemoryStore.Flash.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(flash) with ID ${id}.`),
            getPool: async flash => {
              let pool_field = flash.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Flash pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of Flash is undefined.",
                    ),
                  )
                }
              }
            },
            getTransaction: async flash => {
              let transaction_field = flash.transaction_id
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(transaction_field)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                let entities = await asyncGetters.getTransaction(transaction_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Transaction.set(
                    inMemoryStore.transaction,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Flash transaction data not found. Loading associated transaction from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity transaction of Flash is undefined.",
                    ),
                  )
                }
              }
            },
          },
          mint: {
            set: entity => {
              inMemoryStore.mint->IO.InMemoryStore.Mint.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(mint) with ID ${id}.`),
            getToken0: async mint => {
              let token0_field = mint.token0_id
              let optToken0 = inMemoryStore.token->IO.InMemoryStore.Token.get(token0_field)
              switch optToken0 {
              | Some(token0) => token0
              | None =>
                let entities = await asyncGetters.getToken(token0_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Mint token0 data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token0 of Mint is undefined.",
                    ),
                  )
                }
              }
            },
            getTransaction: async mint => {
              let transaction_field = mint.transaction_id
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(transaction_field)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                let entities = await asyncGetters.getTransaction(transaction_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Transaction.set(
                    inMemoryStore.transaction,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Mint transaction data not found. Loading associated transaction from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity transaction of Mint is undefined.",
                    ),
                  )
                }
              }
            },
            getPool: async mint => {
              let pool_field = mint.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Mint pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of Mint is undefined.",
                    ),
                  )
                }
              }
            },
            getToken1: async mint => {
              let token1_field = mint.token1_id
              let optToken1 = inMemoryStore.token->IO.InMemoryStore.Token.get(token1_field)
              switch optToken1 {
              | Some(token1) => token1
              | None =>
                let entities = await asyncGetters.getToken(token1_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Mint token1 data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token1 of Mint is undefined.",
                    ),
                  )
                }
              }
            },
          },
          pool: {
            set: entity => {
              inMemoryStore.pool->IO.InMemoryStore.Pool.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(pool) with ID ${id}.`),
            getToken1: async pool => {
              let token1_field = pool.token1_id
              let optToken1 = inMemoryStore.token->IO.InMemoryStore.Token.get(token1_field)
              switch optToken1 {
              | Some(token1) => token1
              | None =>
                let entities = await asyncGetters.getToken(token1_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Pool token1 data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token1 of Pool is undefined.",
                    ),
                  )
                }
              }
            },
            getToken0: async pool => {
              let token0_field = pool.token0_id
              let optToken0 = inMemoryStore.token->IO.InMemoryStore.Token.get(token0_field)
              switch optToken0 {
              | Some(token0) => token0
              | None =>
                let entities = await asyncGetters.getToken(token0_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Pool token0 data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token0 of Pool is undefined.",
                    ),
                  )
                }
              }
            },
          },
          poolDayData: {
            set: entity => {
              inMemoryStore.poolDayData->IO.InMemoryStore.PoolDayData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(poolDayData) with ID ${id}.`,
              ),
            getPool: async poolDayData => {
              let pool_field = poolDayData.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`PoolDayData pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of PoolDayData is undefined.",
                    ),
                  )
                }
              }
            },
          },
          poolHourData: {
            set: entity => {
              inMemoryStore.poolHourData->IO.InMemoryStore.PoolHourData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(poolHourData) with ID ${id}.`,
              ),
            getPool: async poolHourData => {
              let pool_field = poolHourData.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`PoolHourData pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of PoolHourData is undefined.",
                    ),
                  )
                }
              }
            },
          },
          position: {
            set: entity => {
              inMemoryStore.position->IO.InMemoryStore.Position.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(position) with ID ${id}.`),
            get: async (id: Types.id) => {
              if optSetOfIds_position->Set.has(id) {
                inMemoryStore.position->IO.InMemoryStore.Position.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.position->IO.InMemoryStore.Position.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getPosition(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Position.set(
                      inMemoryStore.position,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    Some(entity)
                  | None => None
                  }
                }
              }
            },
            getToken1: async position => {
              let token1_field = position.token1_id
              let optToken1 = inMemoryStore.token->IO.InMemoryStore.Token.get(token1_field)
              switch optToken1 {
              | Some(token1) => token1
              | None =>
                let entities = await asyncGetters.getToken(token1_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Position token1 data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token1 of Position is undefined.",
                    ),
                  )
                }
              }
            },
            getToken0: async position => {
              let token0_field = position.token0_id
              let optToken0 = inMemoryStore.token->IO.InMemoryStore.Token.get(token0_field)
              switch optToken0 {
              | Some(token0) => token0
              | None =>
                let entities = await asyncGetters.getToken(token0_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Position token0 data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token0 of Position is undefined.",
                    ),
                  )
                }
              }
            },
            getTickLower: async position => {
              let tickLower_field = position.tickLower_id
              let optTickLower = inMemoryStore.tick->IO.InMemoryStore.Tick.get(tickLower_field)
              switch optTickLower {
              | Some(tickLower) => tickLower
              | None =>
                let entities = await asyncGetters.getTick(tickLower_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Tick.set(
                    inMemoryStore.tick,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Position tickLower data not found. Loading associated tick from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity tickLower of Position is undefined.",
                    ),
                  )
                }
              }
            },
            getTransaction: async position => {
              let transaction_field = position.transaction_id
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(transaction_field)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                let entities = await asyncGetters.getTransaction(transaction_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Transaction.set(
                    inMemoryStore.transaction,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Position transaction data not found. Loading associated transaction from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity transaction of Position is undefined.",
                    ),
                  )
                }
              }
            },
            getPool: async position => {
              let pool_field = position.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Position pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of Position is undefined.",
                    ),
                  )
                }
              }
            },
            getTickUpper: async position => {
              let tickUpper_field = position.tickUpper_id
              let optTickUpper = inMemoryStore.tick->IO.InMemoryStore.Tick.get(tickUpper_field)
              switch optTickUpper {
              | Some(tickUpper) => tickUpper
              | None =>
                let entities = await asyncGetters.getTick(tickUpper_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Tick.set(
                    inMemoryStore.tick,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Position tickUpper data not found. Loading associated tick from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity tickUpper of Position is undefined.",
                    ),
                  )
                }
              }
            },
          },
          positionSnapshot: {
            set: entity => {
              inMemoryStore.positionSnapshot->IO.InMemoryStore.PositionSnapshot.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(positionSnapshot) with ID ${id}.`,
              ),
            get: async (id: Types.id) => {
              if optSetOfIds_positionSnapshot->Set.has(id) {
                inMemoryStore.positionSnapshot->IO.InMemoryStore.PositionSnapshot.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.positionSnapshot->IO.InMemoryStore.PositionSnapshot.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getPositionSnapshot(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.PositionSnapshot.set(
                      inMemoryStore.positionSnapshot,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    Some(entity)
                  | None => None
                  }
                }
              }
            },
            getPool: async positionSnapshot => {
              let pool_field = positionSnapshot.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`PositionSnapshot pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of PositionSnapshot is undefined.",
                    ),
                  )
                }
              }
            },
            getPosition: async positionSnapshot => {
              let position_field = positionSnapshot.position_id
              let optPosition =
                inMemoryStore.position->IO.InMemoryStore.Position.get(position_field)
              switch optPosition {
              | Some(position) => position
              | None =>
                let entities = await asyncGetters.getPosition(position_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Position.set(
                    inMemoryStore.position,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`PositionSnapshot position data not found. Loading associated position from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity position of PositionSnapshot is undefined.",
                    ),
                  )
                }
              }
            },
            getTransaction: async positionSnapshot => {
              let transaction_field = positionSnapshot.transaction_id
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(transaction_field)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                let entities = await asyncGetters.getTransaction(transaction_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Transaction.set(
                    inMemoryStore.transaction,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`PositionSnapshot transaction data not found. Loading associated transaction from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity transaction of PositionSnapshot is undefined.",
                    ),
                  )
                }
              }
            },
          },
          swap: {
            set: entity => {
              inMemoryStore.swap->IO.InMemoryStore.Swap.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(swap) with ID ${id}.`),
            getTick: async swap => {
              let tick_field = swap.tick_id
              let optTick = inMemoryStore.tick->IO.InMemoryStore.Tick.get(tick_field)
              switch optTick {
              | Some(tick) => tick
              | None =>
                let entities = await asyncGetters.getTick(tick_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Tick.set(
                    inMemoryStore.tick,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Swap tick data not found. Loading associated tick from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity tick of Swap is undefined.",
                    ),
                  )
                }
              }
            },
            getTransaction: async swap => {
              let transaction_field = swap.transaction_id
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(transaction_field)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                let entities = await asyncGetters.getTransaction(transaction_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Transaction.set(
                    inMemoryStore.transaction,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Swap transaction data not found. Loading associated transaction from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity transaction of Swap is undefined.",
                    ),
                  )
                }
              }
            },
            getToken1: async swap => {
              let token1_field = swap.token1_id
              let optToken1 = inMemoryStore.token->IO.InMemoryStore.Token.get(token1_field)
              switch optToken1 {
              | Some(token1) => token1
              | None =>
                let entities = await asyncGetters.getToken(token1_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Swap token1 data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token1 of Swap is undefined.",
                    ),
                  )
                }
              }
            },
            getToken0: async swap => {
              let token0_field = swap.token0_id
              let optToken0 = inMemoryStore.token->IO.InMemoryStore.Token.get(token0_field)
              switch optToken0 {
              | Some(token0) => token0
              | None =>
                let entities = await asyncGetters.getToken(token0_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Swap token0 data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token0 of Swap is undefined.",
                    ),
                  )
                }
              }
            },
            getPool: async swap => {
              let pool_field = swap.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Swap pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of Swap is undefined.",
                    ),
                  )
                }
              }
            },
          },
          tick: {
            set: entity => {
              inMemoryStore.tick->IO.InMemoryStore.Tick.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(tick) with ID ${id}.`),
            getPool: async tick => {
              let pool_field = tick.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Tick pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of Tick is undefined.",
                    ),
                  )
                }
              }
            },
          },
          tickDayData: {
            set: entity => {
              inMemoryStore.tickDayData->IO.InMemoryStore.TickDayData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(tickDayData) with ID ${id}.`,
              ),
            getPool: async tickDayData => {
              let pool_field = tickDayData.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`TickDayData pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of TickDayData is undefined.",
                    ),
                  )
                }
              }
            },
            getTick: async tickDayData => {
              let tick_field = tickDayData.tick_id
              let optTick = inMemoryStore.tick->IO.InMemoryStore.Tick.get(tick_field)
              switch optTick {
              | Some(tick) => tick
              | None =>
                let entities = await asyncGetters.getTick(tick_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Tick.set(
                    inMemoryStore.tick,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`TickDayData tick data not found. Loading associated tick from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity tick of TickDayData is undefined.",
                    ),
                  )
                }
              }
            },
          },
          tickHourData: {
            set: entity => {
              inMemoryStore.tickHourData->IO.InMemoryStore.TickHourData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(tickHourData) with ID ${id}.`,
              ),
            getTick: async tickHourData => {
              let tick_field = tickHourData.tick_id
              let optTick = inMemoryStore.tick->IO.InMemoryStore.Tick.get(tick_field)
              switch optTick {
              | Some(tick) => tick
              | None =>
                let entities = await asyncGetters.getTick(tick_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Tick.set(
                    inMemoryStore.tick,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`TickHourData tick data not found. Loading associated tick from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity tick of TickHourData is undefined.",
                    ),
                  )
                }
              }
            },
            getPool: async tickHourData => {
              let pool_field = tickHourData.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`TickHourData pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of TickHourData is undefined.",
                    ),
                  )
                }
              }
            },
          },
          token: {
            set: entity => {
              inMemoryStore.token->IO.InMemoryStore.Token.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(token) with ID ${id}.`),
            get: async (id: Types.id) => {
              if optSetOfIds_token->Set.has(id) {
                inMemoryStore.token->IO.InMemoryStore.Token.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.token->IO.InMemoryStore.Token.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getToken(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Token.set(
                      inMemoryStore.token,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    Some(entity)
                  | None => None
                  }
                }
              }
            },
          },
          tokenDayData: {
            set: entity => {
              inMemoryStore.tokenDayData->IO.InMemoryStore.TokenDayData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(tokenDayData) with ID ${id}.`,
              ),
            getToken: async tokenDayData => {
              let token_field = tokenDayData.token_id
              let optToken = inMemoryStore.token->IO.InMemoryStore.Token.get(token_field)
              switch optToken {
              | Some(token) => token
              | None =>
                let entities = await asyncGetters.getToken(token_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`TokenDayData token data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token of TokenDayData is undefined.",
                    ),
                  )
                }
              }
            },
          },
          tokenHourData: {
            set: entity => {
              inMemoryStore.tokenHourData->IO.InMemoryStore.TokenHourData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(tokenHourData) with ID ${id}.`,
              ),
            getToken: async tokenHourData => {
              let token_field = tokenHourData.token_id
              let optToken = inMemoryStore.token->IO.InMemoryStore.Token.get(token_field)
              switch optToken {
              | Some(token) => token
              | None =>
                let entities = await asyncGetters.getToken(token_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`TokenHourData token data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token of TokenHourData is undefined.",
                    ),
                  )
                }
              }
            },
          },
          tokenPoolWhitelist: {
            set: entity => {
              inMemoryStore.tokenPoolWhitelist->IO.InMemoryStore.TokenPoolWhitelist.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(tokenPoolWhitelist) with ID ${id}.`,
              ),
            getToken: async tokenPoolWhitelist => {
              let token_field = tokenPoolWhitelist.token_id
              let optToken = inMemoryStore.token->IO.InMemoryStore.Token.get(token_field)
              switch optToken {
              | Some(token) => token
              | None =>
                let entities = await asyncGetters.getToken(token_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`TokenPoolWhitelist token data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token of TokenPoolWhitelist is undefined.",
                    ),
                  )
                }
              }
            },
            getPool: async tokenPoolWhitelist => {
              let pool_field = tokenPoolWhitelist.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`TokenPoolWhitelist pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of TokenPoolWhitelist is undefined.",
                    ),
                  )
                }
              }
            },
          },
          transaction: {
            set: entity => {
              inMemoryStore.transaction->IO.InMemoryStore.Transaction.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(transaction) with ID ${id}.`,
              ),
          },
          uniswapDayData: {
            set: entity => {
              inMemoryStore.uniswapDayData->IO.InMemoryStore.UniswapDayData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(uniswapDayData) with ID ${id}.`,
              ),
          },
        }
      }

      {
        logger,
        log: contextLogger,
        getEntitiesToLoad: () => entitiesToLoad,
        getAddedDynamicContractRegistrations: () => addedDynamicContractRegistrations,
        getLoaderContext: () => loaderContext,
        getHandlerContextSync,
        getHandlerContextAsync,
      }
    }
  }

  module DecreaseLiquidityEvent = {
    type loaderContext = Types.NonfungiblePositionManagerContract.DecreaseLiquidityEvent.loaderContext
    type handlerContext = Types.NonfungiblePositionManagerContract.DecreaseLiquidityEvent.handlerContext
    type handlerContextAsync = Types.NonfungiblePositionManagerContract.DecreaseLiquidityEvent.handlerContextAsync
    type context = genericContextCreatorFunctions<
      loaderContext,
      handlerContext,
      handlerContextAsync,
    >

    let contextCreator: contextCreator<
      Types.NonfungiblePositionManagerContract.DecreaseLiquidityEvent.eventArgs,
      loaderContext,
      handlerContext,
      handlerContextAsync,
    > = (~inMemoryStore, ~chainId, ~event, ~logger, ~asyncGetters) => {
      // NOTE: we could optimise this code to onle create a logger if there was a log called.
      let logger = logger->Logging.createChildFrom(
        ~logger=_,
        ~params={
          "context": "NonfungiblePositionManager.DecreaseLiquidity",
          "chainId": chainId,
          "block": event.blockNumber,
          "logIndex": event.logIndex,
          "txHash": event.transactionHash,
        },
      )

      let contextLogger: Logs.userLogger = {
        info: (message: string) => logger->Logging.uinfo(message),
        debug: (message: string) => logger->Logging.udebug(message),
        warn: (message: string) => logger->Logging.uwarn(message),
        error: (message: string) => logger->Logging.uerror(message),
        errorWithExn: (exn: option<Js.Exn.t>, message: string) =>
          logger->Logging.uerrorWithExn(exn, message),
      }

      let optSetOfIds_position: Set.t<Types.id> = Set.make()
      let optSetOfIds_positionSnapshot: Set.t<Types.id> = Set.make()
      let optSetOfIds_token: Set.t<Types.id> = Set.make()

      let entitiesToLoad: array<Types.entityRead> = []

      let addedDynamicContractRegistrations: array<Types.dynamicContractRegistryEntity> = []

      //Loader context can be defined as a value and the getter can return that value

      @warning("-16")
      let loaderContext: loaderContext = {
        log: contextLogger,
        contractRegistration: {
          //TODO only add contracts we've registered for the event in the config
          addFactory: (contractAddress: Ethers.ethAddress) => {
            let eventId = EventUtils.packEventIndex(
              ~blockNumber=event.blockNumber,
              ~logIndex=event.logIndex,
            )
            let dynamicContractRegistration: Types.dynamicContractRegistryEntity = {
              chainId,
              eventId,
              contractAddress,
              contractType: "Factory",
            }

            addedDynamicContractRegistrations->Js.Array2.push(dynamicContractRegistration)->ignore

            inMemoryStore.dynamicContractRegistry->IO.InMemoryStore.DynamicContractRegistry.set(
              ~key={chainId, contractAddress},
              ~entity=dynamicContractRegistration,
              ~dbOp=Set,
            )
          },
          //TODO only add contracts we've registered for the event in the config
          addNonfungiblePositionManager: (contractAddress: Ethers.ethAddress) => {
            let eventId = EventUtils.packEventIndex(
              ~blockNumber=event.blockNumber,
              ~logIndex=event.logIndex,
            )
            let dynamicContractRegistration: Types.dynamicContractRegistryEntity = {
              chainId,
              eventId,
              contractAddress,
              contractType: "NonfungiblePositionManager",
            }

            addedDynamicContractRegistrations->Js.Array2.push(dynamicContractRegistration)->ignore

            inMemoryStore.dynamicContractRegistry->IO.InMemoryStore.DynamicContractRegistry.set(
              ~key={chainId, contractAddress},
              ~entity=dynamicContractRegistration,
              ~dbOp=Set,
            )
          },
          //TODO only add contracts we've registered for the event in the config
          addPool: (contractAddress: Ethers.ethAddress) => {
            let eventId = EventUtils.packEventIndex(
              ~blockNumber=event.blockNumber,
              ~logIndex=event.logIndex,
            )
            let dynamicContractRegistration: Types.dynamicContractRegistryEntity = {
              chainId,
              eventId,
              contractAddress,
              contractType: "Pool",
            }

            addedDynamicContractRegistrations->Js.Array2.push(dynamicContractRegistration)->ignore

            inMemoryStore.dynamicContractRegistry->IO.InMemoryStore.DynamicContractRegistry.set(
              ~key={chainId, contractAddress},
              ~entity=dynamicContractRegistration,
              ~dbOp=Set,
            )
          },
        },
        position: {
          load: (id: Types.id, ~loaders={}) => {
            let _ = optSetOfIds_position->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.PositionRead(id, loaders))
          },
        },
        positionSnapshot: {
          load: (id: Types.id, ~loaders={}) => {
            let _ = optSetOfIds_positionSnapshot->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.PositionSnapshotRead(id, loaders))
          },
        },
        token: {
          load: (id: Types.id) => {
            let _ = optSetOfIds_token->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.TokenRead(id))
          },
        },
      }

      //handler context must be defined as a getter functoin so that it can construct the context
      //without stale values whenever it is used
      let getHandlerContextSync: unit => handlerContext = () => {
        {
          log: contextLogger,
          bundle: {
            set: entity => {
              inMemoryStore.bundle->IO.InMemoryStore.Bundle.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(bundle) with ID ${id}.`),
          },
          burn: {
            set: entity => {
              inMemoryStore.burn->IO.InMemoryStore.Burn.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(burn) with ID ${id}.`),
            getTransaction: burn => {
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(burn.transaction_id)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                Logging.warn(`Burn transaction data not found. Loading associated transaction from database.
Please consider loading the transaction in the UpdateBurn entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Burn is undefined.",
                  ),
                )
              }
            },
            getToken0: burn => {
              let optToken0 = inMemoryStore.token->IO.InMemoryStore.Token.get(burn.token0_id)
              switch optToken0 {
              | Some(token0) => token0
              | None =>
                Logging.warn(`Burn token0 data not found. Loading associated token from database.
Please consider loading the token in the UpdateBurn entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Burn is undefined.",
                  ),
                )
              }
            },
            getPool: burn => {
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(burn.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`Burn pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdateBurn entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Burn is undefined.",
                  ),
                )
              }
            },
            getToken1: burn => {
              let optToken1 = inMemoryStore.token->IO.InMemoryStore.Token.get(burn.token1_id)
              switch optToken1 {
              | Some(token1) => token1
              | None =>
                Logging.warn(`Burn token1 data not found. Loading associated token from database.
Please consider loading the token in the UpdateBurn entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Burn is undefined.",
                  ),
                )
              }
            },
          },
          collect: {
            set: entity => {
              inMemoryStore.collect->IO.InMemoryStore.Collect.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(collect) with ID ${id}.`),
            getTransaction: collect => {
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(collect.transaction_id)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                Logging.warn(`Collect transaction data not found. Loading associated transaction from database.
Please consider loading the transaction in the UpdateCollect entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Collect is undefined.",
                  ),
                )
              }
            },
            getPool: collect => {
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(collect.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`Collect pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdateCollect entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Collect is undefined.",
                  ),
                )
              }
            },
          },
          factory: {
            set: entity => {
              inMemoryStore.factory->IO.InMemoryStore.Factory.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(factory) with ID ${id}.`),
          },
          flash: {
            set: entity => {
              inMemoryStore.flash->IO.InMemoryStore.Flash.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(flash) with ID ${id}.`),
            getPool: flash => {
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(flash.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`Flash pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdateFlash entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Flash is undefined.",
                  ),
                )
              }
            },
            getTransaction: flash => {
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(flash.transaction_id)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                Logging.warn(`Flash transaction data not found. Loading associated transaction from database.
Please consider loading the transaction in the UpdateFlash entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Flash is undefined.",
                  ),
                )
              }
            },
          },
          mint: {
            set: entity => {
              inMemoryStore.mint->IO.InMemoryStore.Mint.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(mint) with ID ${id}.`),
            getToken0: mint => {
              let optToken0 = inMemoryStore.token->IO.InMemoryStore.Token.get(mint.token0_id)
              switch optToken0 {
              | Some(token0) => token0
              | None =>
                Logging.warn(`Mint token0 data not found. Loading associated token from database.
Please consider loading the token in the UpdateMint entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Mint is undefined.",
                  ),
                )
              }
            },
            getTransaction: mint => {
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(mint.transaction_id)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                Logging.warn(`Mint transaction data not found. Loading associated transaction from database.
Please consider loading the transaction in the UpdateMint entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Mint is undefined.",
                  ),
                )
              }
            },
            getPool: mint => {
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(mint.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`Mint pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdateMint entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Mint is undefined.",
                  ),
                )
              }
            },
            getToken1: mint => {
              let optToken1 = inMemoryStore.token->IO.InMemoryStore.Token.get(mint.token1_id)
              switch optToken1 {
              | Some(token1) => token1
              | None =>
                Logging.warn(`Mint token1 data not found. Loading associated token from database.
Please consider loading the token in the UpdateMint entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Mint is undefined.",
                  ),
                )
              }
            },
          },
          pool: {
            set: entity => {
              inMemoryStore.pool->IO.InMemoryStore.Pool.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(pool) with ID ${id}.`),
            getToken1: pool => {
              let optToken1 = inMemoryStore.token->IO.InMemoryStore.Token.get(pool.token1_id)
              switch optToken1 {
              | Some(token1) => token1
              | None =>
                Logging.warn(`Pool token1 data not found. Loading associated token from database.
Please consider loading the token in the UpdatePool entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Pool is undefined.",
                  ),
                )
              }
            },
            getToken0: pool => {
              let optToken0 = inMemoryStore.token->IO.InMemoryStore.Token.get(pool.token0_id)
              switch optToken0 {
              | Some(token0) => token0
              | None =>
                Logging.warn(`Pool token0 data not found. Loading associated token from database.
Please consider loading the token in the UpdatePool entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Pool is undefined.",
                  ),
                )
              }
            },
          },
          poolDayData: {
            set: entity => {
              inMemoryStore.poolDayData->IO.InMemoryStore.PoolDayData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(poolDayData) with ID ${id}.`,
              ),
            getPool: poolDayData => {
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(poolDayData.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`PoolDayData pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdatePoolDayData entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of PoolDayData is undefined.",
                  ),
                )
              }
            },
          },
          poolHourData: {
            set: entity => {
              inMemoryStore.poolHourData->IO.InMemoryStore.PoolHourData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(poolHourData) with ID ${id}.`,
              ),
            getPool: poolHourData => {
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(poolHourData.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`PoolHourData pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdatePoolHourData entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of PoolHourData is undefined.",
                  ),
                )
              }
            },
          },
          position: {
            set: entity => {
              inMemoryStore.position->IO.InMemoryStore.Position.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(position) with ID ${id}.`),
            get: (id: Types.id) => {
              if optSetOfIds_position->Set.has(id) {
                inMemoryStore.position->IO.InMemoryStore.Position.get(id)
              } else {
                Logging.warn(
                  `The loader for a "Position" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.position.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.position->IO.InMemoryStore.Position.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
            getToken1: position => {
              let optToken1 = inMemoryStore.token->IO.InMemoryStore.Token.get(position.token1_id)
              switch optToken1 {
              | Some(token1) => token1
              | None =>
                Logging.warn(`Position token1 data not found. Loading associated token from database.
Please consider loading the token in the UpdatePosition entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Position is undefined.",
                  ),
                )
              }
            },
            getToken0: position => {
              let optToken0 = inMemoryStore.token->IO.InMemoryStore.Token.get(position.token0_id)
              switch optToken0 {
              | Some(token0) => token0
              | None =>
                Logging.warn(`Position token0 data not found. Loading associated token from database.
Please consider loading the token in the UpdatePosition entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Position is undefined.",
                  ),
                )
              }
            },
            getTickLower: position => {
              let optTickLower =
                inMemoryStore.tick->IO.InMemoryStore.Tick.get(position.tickLower_id)
              switch optTickLower {
              | Some(tickLower) => tickLower
              | None =>
                Logging.warn(`Position tickLower data not found. Loading associated tick from database.
Please consider loading the tick in the UpdatePosition entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Position is undefined.",
                  ),
                )
              }
            },
            getTransaction: position => {
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(position.transaction_id)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                Logging.warn(`Position transaction data not found. Loading associated transaction from database.
Please consider loading the transaction in the UpdatePosition entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Position is undefined.",
                  ),
                )
              }
            },
            getPool: position => {
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(position.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`Position pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdatePosition entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Position is undefined.",
                  ),
                )
              }
            },
            getTickUpper: position => {
              let optTickUpper =
                inMemoryStore.tick->IO.InMemoryStore.Tick.get(position.tickUpper_id)
              switch optTickUpper {
              | Some(tickUpper) => tickUpper
              | None =>
                Logging.warn(`Position tickUpper data not found. Loading associated tick from database.
Please consider loading the tick in the UpdatePosition entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Position is undefined.",
                  ),
                )
              }
            },
          },
          positionSnapshot: {
            set: entity => {
              inMemoryStore.positionSnapshot->IO.InMemoryStore.PositionSnapshot.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(positionSnapshot) with ID ${id}.`,
              ),
            get: (id: Types.id) => {
              if optSetOfIds_positionSnapshot->Set.has(id) {
                inMemoryStore.positionSnapshot->IO.InMemoryStore.PositionSnapshot.get(id)
              } else {
                Logging.warn(
                  `The loader for a "PositionSnapshot" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.positionSnapshot.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.positionSnapshot->IO.InMemoryStore.PositionSnapshot.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
            getPool: positionSnapshot => {
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(positionSnapshot.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`PositionSnapshot pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdatePositionSnapshot entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of PositionSnapshot is undefined.",
                  ),
                )
              }
            },
            getPosition: positionSnapshot => {
              let optPosition =
                inMemoryStore.position->IO.InMemoryStore.Position.get(positionSnapshot.position_id)
              switch optPosition {
              | Some(position) => position
              | None =>
                Logging.warn(`PositionSnapshot position data not found. Loading associated position from database.
Please consider loading the position in the UpdatePositionSnapshot entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of PositionSnapshot is undefined.",
                  ),
                )
              }
            },
            getTransaction: positionSnapshot => {
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(
                  positionSnapshot.transaction_id,
                )
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                Logging.warn(`PositionSnapshot transaction data not found. Loading associated transaction from database.
Please consider loading the transaction in the UpdatePositionSnapshot entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of PositionSnapshot is undefined.",
                  ),
                )
              }
            },
          },
          swap: {
            set: entity => {
              inMemoryStore.swap->IO.InMemoryStore.Swap.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(swap) with ID ${id}.`),
            getTick: swap => {
              let optTick = inMemoryStore.tick->IO.InMemoryStore.Tick.get(swap.tick_id)
              switch optTick {
              | Some(tick) => tick
              | None =>
                Logging.warn(`Swap tick data not found. Loading associated tick from database.
Please consider loading the tick in the UpdateSwap entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Swap is undefined.",
                  ),
                )
              }
            },
            getTransaction: swap => {
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(swap.transaction_id)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                Logging.warn(`Swap transaction data not found. Loading associated transaction from database.
Please consider loading the transaction in the UpdateSwap entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Swap is undefined.",
                  ),
                )
              }
            },
            getToken1: swap => {
              let optToken1 = inMemoryStore.token->IO.InMemoryStore.Token.get(swap.token1_id)
              switch optToken1 {
              | Some(token1) => token1
              | None =>
                Logging.warn(`Swap token1 data not found. Loading associated token from database.
Please consider loading the token in the UpdateSwap entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Swap is undefined.",
                  ),
                )
              }
            },
            getToken0: swap => {
              let optToken0 = inMemoryStore.token->IO.InMemoryStore.Token.get(swap.token0_id)
              switch optToken0 {
              | Some(token0) => token0
              | None =>
                Logging.warn(`Swap token0 data not found. Loading associated token from database.
Please consider loading the token in the UpdateSwap entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Swap is undefined.",
                  ),
                )
              }
            },
            getPool: swap => {
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(swap.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`Swap pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdateSwap entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Swap is undefined.",
                  ),
                )
              }
            },
          },
          tick: {
            set: entity => {
              inMemoryStore.tick->IO.InMemoryStore.Tick.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(tick) with ID ${id}.`),
            getPool: tick => {
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(tick.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`Tick pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdateTick entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Tick is undefined.",
                  ),
                )
              }
            },
          },
          tickDayData: {
            set: entity => {
              inMemoryStore.tickDayData->IO.InMemoryStore.TickDayData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(tickDayData) with ID ${id}.`,
              ),
            getPool: tickDayData => {
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(tickDayData.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`TickDayData pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdateTickDayData entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of TickDayData is undefined.",
                  ),
                )
              }
            },
            getTick: tickDayData => {
              let optTick = inMemoryStore.tick->IO.InMemoryStore.Tick.get(tickDayData.tick_id)
              switch optTick {
              | Some(tick) => tick
              | None =>
                Logging.warn(`TickDayData tick data not found. Loading associated tick from database.
Please consider loading the tick in the UpdateTickDayData entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of TickDayData is undefined.",
                  ),
                )
              }
            },
          },
          tickHourData: {
            set: entity => {
              inMemoryStore.tickHourData->IO.InMemoryStore.TickHourData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(tickHourData) with ID ${id}.`,
              ),
            getTick: tickHourData => {
              let optTick = inMemoryStore.tick->IO.InMemoryStore.Tick.get(tickHourData.tick_id)
              switch optTick {
              | Some(tick) => tick
              | None =>
                Logging.warn(`TickHourData tick data not found. Loading associated tick from database.
Please consider loading the tick in the UpdateTickHourData entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of TickHourData is undefined.",
                  ),
                )
              }
            },
            getPool: tickHourData => {
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(tickHourData.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`TickHourData pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdateTickHourData entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of TickHourData is undefined.",
                  ),
                )
              }
            },
          },
          token: {
            set: entity => {
              inMemoryStore.token->IO.InMemoryStore.Token.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(token) with ID ${id}.`),
            get: (id: Types.id) => {
              if optSetOfIds_token->Set.has(id) {
                inMemoryStore.token->IO.InMemoryStore.Token.get(id)
              } else {
                Logging.warn(
                  `The loader for a "Token" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.token.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.token->IO.InMemoryStore.Token.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
          },
          tokenDayData: {
            set: entity => {
              inMemoryStore.tokenDayData->IO.InMemoryStore.TokenDayData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(tokenDayData) with ID ${id}.`,
              ),
            getToken: tokenDayData => {
              let optToken = inMemoryStore.token->IO.InMemoryStore.Token.get(tokenDayData.token_id)
              switch optToken {
              | Some(token) => token
              | None =>
                Logging.warn(`TokenDayData token data not found. Loading associated token from database.
Please consider loading the token in the UpdateTokenDayData entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of TokenDayData is undefined.",
                  ),
                )
              }
            },
          },
          tokenHourData: {
            set: entity => {
              inMemoryStore.tokenHourData->IO.InMemoryStore.TokenHourData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(tokenHourData) with ID ${id}.`,
              ),
            getToken: tokenHourData => {
              let optToken = inMemoryStore.token->IO.InMemoryStore.Token.get(tokenHourData.token_id)
              switch optToken {
              | Some(token) => token
              | None =>
                Logging.warn(`TokenHourData token data not found. Loading associated token from database.
Please consider loading the token in the UpdateTokenHourData entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of TokenHourData is undefined.",
                  ),
                )
              }
            },
          },
          tokenPoolWhitelist: {
            set: entity => {
              inMemoryStore.tokenPoolWhitelist->IO.InMemoryStore.TokenPoolWhitelist.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(tokenPoolWhitelist) with ID ${id}.`,
              ),
            getToken: tokenPoolWhitelist => {
              let optToken =
                inMemoryStore.token->IO.InMemoryStore.Token.get(tokenPoolWhitelist.token_id)
              switch optToken {
              | Some(token) => token
              | None =>
                Logging.warn(`TokenPoolWhitelist token data not found. Loading associated token from database.
Please consider loading the token in the UpdateTokenPoolWhitelist entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of TokenPoolWhitelist is undefined.",
                  ),
                )
              }
            },
            getPool: tokenPoolWhitelist => {
              let optPool =
                inMemoryStore.pool->IO.InMemoryStore.Pool.get(tokenPoolWhitelist.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`TokenPoolWhitelist pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdateTokenPoolWhitelist entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of TokenPoolWhitelist is undefined.",
                  ),
                )
              }
            },
          },
          transaction: {
            set: entity => {
              inMemoryStore.transaction->IO.InMemoryStore.Transaction.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(transaction) with ID ${id}.`,
              ),
          },
          uniswapDayData: {
            set: entity => {
              inMemoryStore.uniswapDayData->IO.InMemoryStore.UniswapDayData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(uniswapDayData) with ID ${id}.`,
              ),
          },
        }
      }

      let getHandlerContextAsync = (): handlerContextAsync => {
        {
          log: contextLogger,
          bundle: {
            set: entity => {
              inMemoryStore.bundle->IO.InMemoryStore.Bundle.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(bundle) with ID ${id}.`),
          },
          burn: {
            set: entity => {
              inMemoryStore.burn->IO.InMemoryStore.Burn.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(burn) with ID ${id}.`),
            getTransaction: async burn => {
              let transaction_field = burn.transaction_id
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(transaction_field)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                let entities = await asyncGetters.getTransaction(transaction_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Transaction.set(
                    inMemoryStore.transaction,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Burn transaction data not found. Loading associated transaction from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity transaction of Burn is undefined.",
                    ),
                  )
                }
              }
            },
            getToken0: async burn => {
              let token0_field = burn.token0_id
              let optToken0 = inMemoryStore.token->IO.InMemoryStore.Token.get(token0_field)
              switch optToken0 {
              | Some(token0) => token0
              | None =>
                let entities = await asyncGetters.getToken(token0_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Burn token0 data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token0 of Burn is undefined.",
                    ),
                  )
                }
              }
            },
            getPool: async burn => {
              let pool_field = burn.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Burn pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of Burn is undefined.",
                    ),
                  )
                }
              }
            },
            getToken1: async burn => {
              let token1_field = burn.token1_id
              let optToken1 = inMemoryStore.token->IO.InMemoryStore.Token.get(token1_field)
              switch optToken1 {
              | Some(token1) => token1
              | None =>
                let entities = await asyncGetters.getToken(token1_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Burn token1 data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token1 of Burn is undefined.",
                    ),
                  )
                }
              }
            },
          },
          collect: {
            set: entity => {
              inMemoryStore.collect->IO.InMemoryStore.Collect.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(collect) with ID ${id}.`),
            getTransaction: async collect => {
              let transaction_field = collect.transaction_id
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(transaction_field)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                let entities = await asyncGetters.getTransaction(transaction_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Transaction.set(
                    inMemoryStore.transaction,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Collect transaction data not found. Loading associated transaction from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity transaction of Collect is undefined.",
                    ),
                  )
                }
              }
            },
            getPool: async collect => {
              let pool_field = collect.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Collect pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of Collect is undefined.",
                    ),
                  )
                }
              }
            },
          },
          factory: {
            set: entity => {
              inMemoryStore.factory->IO.InMemoryStore.Factory.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(factory) with ID ${id}.`),
          },
          flash: {
            set: entity => {
              inMemoryStore.flash->IO.InMemoryStore.Flash.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(flash) with ID ${id}.`),
            getPool: async flash => {
              let pool_field = flash.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Flash pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of Flash is undefined.",
                    ),
                  )
                }
              }
            },
            getTransaction: async flash => {
              let transaction_field = flash.transaction_id
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(transaction_field)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                let entities = await asyncGetters.getTransaction(transaction_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Transaction.set(
                    inMemoryStore.transaction,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Flash transaction data not found. Loading associated transaction from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity transaction of Flash is undefined.",
                    ),
                  )
                }
              }
            },
          },
          mint: {
            set: entity => {
              inMemoryStore.mint->IO.InMemoryStore.Mint.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(mint) with ID ${id}.`),
            getToken0: async mint => {
              let token0_field = mint.token0_id
              let optToken0 = inMemoryStore.token->IO.InMemoryStore.Token.get(token0_field)
              switch optToken0 {
              | Some(token0) => token0
              | None =>
                let entities = await asyncGetters.getToken(token0_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Mint token0 data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token0 of Mint is undefined.",
                    ),
                  )
                }
              }
            },
            getTransaction: async mint => {
              let transaction_field = mint.transaction_id
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(transaction_field)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                let entities = await asyncGetters.getTransaction(transaction_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Transaction.set(
                    inMemoryStore.transaction,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Mint transaction data not found. Loading associated transaction from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity transaction of Mint is undefined.",
                    ),
                  )
                }
              }
            },
            getPool: async mint => {
              let pool_field = mint.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Mint pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of Mint is undefined.",
                    ),
                  )
                }
              }
            },
            getToken1: async mint => {
              let token1_field = mint.token1_id
              let optToken1 = inMemoryStore.token->IO.InMemoryStore.Token.get(token1_field)
              switch optToken1 {
              | Some(token1) => token1
              | None =>
                let entities = await asyncGetters.getToken(token1_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Mint token1 data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token1 of Mint is undefined.",
                    ),
                  )
                }
              }
            },
          },
          pool: {
            set: entity => {
              inMemoryStore.pool->IO.InMemoryStore.Pool.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(pool) with ID ${id}.`),
            getToken1: async pool => {
              let token1_field = pool.token1_id
              let optToken1 = inMemoryStore.token->IO.InMemoryStore.Token.get(token1_field)
              switch optToken1 {
              | Some(token1) => token1
              | None =>
                let entities = await asyncGetters.getToken(token1_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Pool token1 data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token1 of Pool is undefined.",
                    ),
                  )
                }
              }
            },
            getToken0: async pool => {
              let token0_field = pool.token0_id
              let optToken0 = inMemoryStore.token->IO.InMemoryStore.Token.get(token0_field)
              switch optToken0 {
              | Some(token0) => token0
              | None =>
                let entities = await asyncGetters.getToken(token0_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Pool token0 data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token0 of Pool is undefined.",
                    ),
                  )
                }
              }
            },
          },
          poolDayData: {
            set: entity => {
              inMemoryStore.poolDayData->IO.InMemoryStore.PoolDayData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(poolDayData) with ID ${id}.`,
              ),
            getPool: async poolDayData => {
              let pool_field = poolDayData.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`PoolDayData pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of PoolDayData is undefined.",
                    ),
                  )
                }
              }
            },
          },
          poolHourData: {
            set: entity => {
              inMemoryStore.poolHourData->IO.InMemoryStore.PoolHourData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(poolHourData) with ID ${id}.`,
              ),
            getPool: async poolHourData => {
              let pool_field = poolHourData.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`PoolHourData pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of PoolHourData is undefined.",
                    ),
                  )
                }
              }
            },
          },
          position: {
            set: entity => {
              inMemoryStore.position->IO.InMemoryStore.Position.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(position) with ID ${id}.`),
            get: async (id: Types.id) => {
              if optSetOfIds_position->Set.has(id) {
                inMemoryStore.position->IO.InMemoryStore.Position.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.position->IO.InMemoryStore.Position.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getPosition(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Position.set(
                      inMemoryStore.position,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    Some(entity)
                  | None => None
                  }
                }
              }
            },
            getToken1: async position => {
              let token1_field = position.token1_id
              let optToken1 = inMemoryStore.token->IO.InMemoryStore.Token.get(token1_field)
              switch optToken1 {
              | Some(token1) => token1
              | None =>
                let entities = await asyncGetters.getToken(token1_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Position token1 data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token1 of Position is undefined.",
                    ),
                  )
                }
              }
            },
            getToken0: async position => {
              let token0_field = position.token0_id
              let optToken0 = inMemoryStore.token->IO.InMemoryStore.Token.get(token0_field)
              switch optToken0 {
              | Some(token0) => token0
              | None =>
                let entities = await asyncGetters.getToken(token0_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Position token0 data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token0 of Position is undefined.",
                    ),
                  )
                }
              }
            },
            getTickLower: async position => {
              let tickLower_field = position.tickLower_id
              let optTickLower = inMemoryStore.tick->IO.InMemoryStore.Tick.get(tickLower_field)
              switch optTickLower {
              | Some(tickLower) => tickLower
              | None =>
                let entities = await asyncGetters.getTick(tickLower_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Tick.set(
                    inMemoryStore.tick,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Position tickLower data not found. Loading associated tick from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity tickLower of Position is undefined.",
                    ),
                  )
                }
              }
            },
            getTransaction: async position => {
              let transaction_field = position.transaction_id
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(transaction_field)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                let entities = await asyncGetters.getTransaction(transaction_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Transaction.set(
                    inMemoryStore.transaction,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Position transaction data not found. Loading associated transaction from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity transaction of Position is undefined.",
                    ),
                  )
                }
              }
            },
            getPool: async position => {
              let pool_field = position.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Position pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of Position is undefined.",
                    ),
                  )
                }
              }
            },
            getTickUpper: async position => {
              let tickUpper_field = position.tickUpper_id
              let optTickUpper = inMemoryStore.tick->IO.InMemoryStore.Tick.get(tickUpper_field)
              switch optTickUpper {
              | Some(tickUpper) => tickUpper
              | None =>
                let entities = await asyncGetters.getTick(tickUpper_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Tick.set(
                    inMemoryStore.tick,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Position tickUpper data not found. Loading associated tick from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity tickUpper of Position is undefined.",
                    ),
                  )
                }
              }
            },
          },
          positionSnapshot: {
            set: entity => {
              inMemoryStore.positionSnapshot->IO.InMemoryStore.PositionSnapshot.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(positionSnapshot) with ID ${id}.`,
              ),
            get: async (id: Types.id) => {
              if optSetOfIds_positionSnapshot->Set.has(id) {
                inMemoryStore.positionSnapshot->IO.InMemoryStore.PositionSnapshot.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.positionSnapshot->IO.InMemoryStore.PositionSnapshot.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getPositionSnapshot(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.PositionSnapshot.set(
                      inMemoryStore.positionSnapshot,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    Some(entity)
                  | None => None
                  }
                }
              }
            },
            getPool: async positionSnapshot => {
              let pool_field = positionSnapshot.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`PositionSnapshot pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of PositionSnapshot is undefined.",
                    ),
                  )
                }
              }
            },
            getPosition: async positionSnapshot => {
              let position_field = positionSnapshot.position_id
              let optPosition =
                inMemoryStore.position->IO.InMemoryStore.Position.get(position_field)
              switch optPosition {
              | Some(position) => position
              | None =>
                let entities = await asyncGetters.getPosition(position_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Position.set(
                    inMemoryStore.position,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`PositionSnapshot position data not found. Loading associated position from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity position of PositionSnapshot is undefined.",
                    ),
                  )
                }
              }
            },
            getTransaction: async positionSnapshot => {
              let transaction_field = positionSnapshot.transaction_id
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(transaction_field)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                let entities = await asyncGetters.getTransaction(transaction_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Transaction.set(
                    inMemoryStore.transaction,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`PositionSnapshot transaction data not found. Loading associated transaction from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity transaction of PositionSnapshot is undefined.",
                    ),
                  )
                }
              }
            },
          },
          swap: {
            set: entity => {
              inMemoryStore.swap->IO.InMemoryStore.Swap.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(swap) with ID ${id}.`),
            getTick: async swap => {
              let tick_field = swap.tick_id
              let optTick = inMemoryStore.tick->IO.InMemoryStore.Tick.get(tick_field)
              switch optTick {
              | Some(tick) => tick
              | None =>
                let entities = await asyncGetters.getTick(tick_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Tick.set(
                    inMemoryStore.tick,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Swap tick data not found. Loading associated tick from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity tick of Swap is undefined.",
                    ),
                  )
                }
              }
            },
            getTransaction: async swap => {
              let transaction_field = swap.transaction_id
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(transaction_field)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                let entities = await asyncGetters.getTransaction(transaction_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Transaction.set(
                    inMemoryStore.transaction,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Swap transaction data not found. Loading associated transaction from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity transaction of Swap is undefined.",
                    ),
                  )
                }
              }
            },
            getToken1: async swap => {
              let token1_field = swap.token1_id
              let optToken1 = inMemoryStore.token->IO.InMemoryStore.Token.get(token1_field)
              switch optToken1 {
              | Some(token1) => token1
              | None =>
                let entities = await asyncGetters.getToken(token1_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Swap token1 data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token1 of Swap is undefined.",
                    ),
                  )
                }
              }
            },
            getToken0: async swap => {
              let token0_field = swap.token0_id
              let optToken0 = inMemoryStore.token->IO.InMemoryStore.Token.get(token0_field)
              switch optToken0 {
              | Some(token0) => token0
              | None =>
                let entities = await asyncGetters.getToken(token0_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Swap token0 data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token0 of Swap is undefined.",
                    ),
                  )
                }
              }
            },
            getPool: async swap => {
              let pool_field = swap.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Swap pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of Swap is undefined.",
                    ),
                  )
                }
              }
            },
          },
          tick: {
            set: entity => {
              inMemoryStore.tick->IO.InMemoryStore.Tick.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(tick) with ID ${id}.`),
            getPool: async tick => {
              let pool_field = tick.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Tick pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of Tick is undefined.",
                    ),
                  )
                }
              }
            },
          },
          tickDayData: {
            set: entity => {
              inMemoryStore.tickDayData->IO.InMemoryStore.TickDayData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(tickDayData) with ID ${id}.`,
              ),
            getPool: async tickDayData => {
              let pool_field = tickDayData.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`TickDayData pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of TickDayData is undefined.",
                    ),
                  )
                }
              }
            },
            getTick: async tickDayData => {
              let tick_field = tickDayData.tick_id
              let optTick = inMemoryStore.tick->IO.InMemoryStore.Tick.get(tick_field)
              switch optTick {
              | Some(tick) => tick
              | None =>
                let entities = await asyncGetters.getTick(tick_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Tick.set(
                    inMemoryStore.tick,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`TickDayData tick data not found. Loading associated tick from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity tick of TickDayData is undefined.",
                    ),
                  )
                }
              }
            },
          },
          tickHourData: {
            set: entity => {
              inMemoryStore.tickHourData->IO.InMemoryStore.TickHourData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(tickHourData) with ID ${id}.`,
              ),
            getTick: async tickHourData => {
              let tick_field = tickHourData.tick_id
              let optTick = inMemoryStore.tick->IO.InMemoryStore.Tick.get(tick_field)
              switch optTick {
              | Some(tick) => tick
              | None =>
                let entities = await asyncGetters.getTick(tick_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Tick.set(
                    inMemoryStore.tick,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`TickHourData tick data not found. Loading associated tick from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity tick of TickHourData is undefined.",
                    ),
                  )
                }
              }
            },
            getPool: async tickHourData => {
              let pool_field = tickHourData.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`TickHourData pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of TickHourData is undefined.",
                    ),
                  )
                }
              }
            },
          },
          token: {
            set: entity => {
              inMemoryStore.token->IO.InMemoryStore.Token.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(token) with ID ${id}.`),
            get: async (id: Types.id) => {
              if optSetOfIds_token->Set.has(id) {
                inMemoryStore.token->IO.InMemoryStore.Token.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.token->IO.InMemoryStore.Token.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getToken(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Token.set(
                      inMemoryStore.token,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    Some(entity)
                  | None => None
                  }
                }
              }
            },
          },
          tokenDayData: {
            set: entity => {
              inMemoryStore.tokenDayData->IO.InMemoryStore.TokenDayData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(tokenDayData) with ID ${id}.`,
              ),
            getToken: async tokenDayData => {
              let token_field = tokenDayData.token_id
              let optToken = inMemoryStore.token->IO.InMemoryStore.Token.get(token_field)
              switch optToken {
              | Some(token) => token
              | None =>
                let entities = await asyncGetters.getToken(token_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`TokenDayData token data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token of TokenDayData is undefined.",
                    ),
                  )
                }
              }
            },
          },
          tokenHourData: {
            set: entity => {
              inMemoryStore.tokenHourData->IO.InMemoryStore.TokenHourData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(tokenHourData) with ID ${id}.`,
              ),
            getToken: async tokenHourData => {
              let token_field = tokenHourData.token_id
              let optToken = inMemoryStore.token->IO.InMemoryStore.Token.get(token_field)
              switch optToken {
              | Some(token) => token
              | None =>
                let entities = await asyncGetters.getToken(token_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`TokenHourData token data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token of TokenHourData is undefined.",
                    ),
                  )
                }
              }
            },
          },
          tokenPoolWhitelist: {
            set: entity => {
              inMemoryStore.tokenPoolWhitelist->IO.InMemoryStore.TokenPoolWhitelist.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(tokenPoolWhitelist) with ID ${id}.`,
              ),
            getToken: async tokenPoolWhitelist => {
              let token_field = tokenPoolWhitelist.token_id
              let optToken = inMemoryStore.token->IO.InMemoryStore.Token.get(token_field)
              switch optToken {
              | Some(token) => token
              | None =>
                let entities = await asyncGetters.getToken(token_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`TokenPoolWhitelist token data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token of TokenPoolWhitelist is undefined.",
                    ),
                  )
                }
              }
            },
            getPool: async tokenPoolWhitelist => {
              let pool_field = tokenPoolWhitelist.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`TokenPoolWhitelist pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of TokenPoolWhitelist is undefined.",
                    ),
                  )
                }
              }
            },
          },
          transaction: {
            set: entity => {
              inMemoryStore.transaction->IO.InMemoryStore.Transaction.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(transaction) with ID ${id}.`,
              ),
          },
          uniswapDayData: {
            set: entity => {
              inMemoryStore.uniswapDayData->IO.InMemoryStore.UniswapDayData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(uniswapDayData) with ID ${id}.`,
              ),
          },
        }
      }

      {
        logger,
        log: contextLogger,
        getEntitiesToLoad: () => entitiesToLoad,
        getAddedDynamicContractRegistrations: () => addedDynamicContractRegistrations,
        getLoaderContext: () => loaderContext,
        getHandlerContextSync,
        getHandlerContextAsync,
      }
    }
  }

  module TransferEvent = {
    type loaderContext = Types.NonfungiblePositionManagerContract.TransferEvent.loaderContext
    type handlerContext = Types.NonfungiblePositionManagerContract.TransferEvent.handlerContext
    type handlerContextAsync = Types.NonfungiblePositionManagerContract.TransferEvent.handlerContextAsync
    type context = genericContextCreatorFunctions<
      loaderContext,
      handlerContext,
      handlerContextAsync,
    >

    let contextCreator: contextCreator<
      Types.NonfungiblePositionManagerContract.TransferEvent.eventArgs,
      loaderContext,
      handlerContext,
      handlerContextAsync,
    > = (~inMemoryStore, ~chainId, ~event, ~logger, ~asyncGetters) => {
      // NOTE: we could optimise this code to onle create a logger if there was a log called.
      let logger = logger->Logging.createChildFrom(
        ~logger=_,
        ~params={
          "context": "NonfungiblePositionManager.Transfer",
          "chainId": chainId,
          "block": event.blockNumber,
          "logIndex": event.logIndex,
          "txHash": event.transactionHash,
        },
      )

      let contextLogger: Logs.userLogger = {
        info: (message: string) => logger->Logging.uinfo(message),
        debug: (message: string) => logger->Logging.udebug(message),
        warn: (message: string) => logger->Logging.uwarn(message),
        error: (message: string) => logger->Logging.uerror(message),
        errorWithExn: (exn: option<Js.Exn.t>, message: string) =>
          logger->Logging.uerrorWithExn(exn, message),
      }

      let optSetOfIds_position: Set.t<Types.id> = Set.make()
      let optSetOfIds_positionSnapshot: Set.t<Types.id> = Set.make()

      let entitiesToLoad: array<Types.entityRead> = []

      let addedDynamicContractRegistrations: array<Types.dynamicContractRegistryEntity> = []

      //Loader context can be defined as a value and the getter can return that value

      @warning("-16")
      let loaderContext: loaderContext = {
        log: contextLogger,
        contractRegistration: {
          //TODO only add contracts we've registered for the event in the config
          addFactory: (contractAddress: Ethers.ethAddress) => {
            let eventId = EventUtils.packEventIndex(
              ~blockNumber=event.blockNumber,
              ~logIndex=event.logIndex,
            )
            let dynamicContractRegistration: Types.dynamicContractRegistryEntity = {
              chainId,
              eventId,
              contractAddress,
              contractType: "Factory",
            }

            addedDynamicContractRegistrations->Js.Array2.push(dynamicContractRegistration)->ignore

            inMemoryStore.dynamicContractRegistry->IO.InMemoryStore.DynamicContractRegistry.set(
              ~key={chainId, contractAddress},
              ~entity=dynamicContractRegistration,
              ~dbOp=Set,
            )
          },
          //TODO only add contracts we've registered for the event in the config
          addNonfungiblePositionManager: (contractAddress: Ethers.ethAddress) => {
            let eventId = EventUtils.packEventIndex(
              ~blockNumber=event.blockNumber,
              ~logIndex=event.logIndex,
            )
            let dynamicContractRegistration: Types.dynamicContractRegistryEntity = {
              chainId,
              eventId,
              contractAddress,
              contractType: "NonfungiblePositionManager",
            }

            addedDynamicContractRegistrations->Js.Array2.push(dynamicContractRegistration)->ignore

            inMemoryStore.dynamicContractRegistry->IO.InMemoryStore.DynamicContractRegistry.set(
              ~key={chainId, contractAddress},
              ~entity=dynamicContractRegistration,
              ~dbOp=Set,
            )
          },
          //TODO only add contracts we've registered for the event in the config
          addPool: (contractAddress: Ethers.ethAddress) => {
            let eventId = EventUtils.packEventIndex(
              ~blockNumber=event.blockNumber,
              ~logIndex=event.logIndex,
            )
            let dynamicContractRegistration: Types.dynamicContractRegistryEntity = {
              chainId,
              eventId,
              contractAddress,
              contractType: "Pool",
            }

            addedDynamicContractRegistrations->Js.Array2.push(dynamicContractRegistration)->ignore

            inMemoryStore.dynamicContractRegistry->IO.InMemoryStore.DynamicContractRegistry.set(
              ~key={chainId, contractAddress},
              ~entity=dynamicContractRegistration,
              ~dbOp=Set,
            )
          },
        },
        position: {
          load: (id: Types.id, ~loaders={}) => {
            let _ = optSetOfIds_position->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.PositionRead(id, loaders))
          },
        },
        positionSnapshot: {
          load: (id: Types.id, ~loaders={}) => {
            let _ = optSetOfIds_positionSnapshot->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.PositionSnapshotRead(id, loaders))
          },
        },
      }

      //handler context must be defined as a getter functoin so that it can construct the context
      //without stale values whenever it is used
      let getHandlerContextSync: unit => handlerContext = () => {
        {
          log: contextLogger,
          bundle: {
            set: entity => {
              inMemoryStore.bundle->IO.InMemoryStore.Bundle.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(bundle) with ID ${id}.`),
          },
          burn: {
            set: entity => {
              inMemoryStore.burn->IO.InMemoryStore.Burn.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(burn) with ID ${id}.`),
            getTransaction: burn => {
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(burn.transaction_id)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                Logging.warn(`Burn transaction data not found. Loading associated transaction from database.
Please consider loading the transaction in the UpdateBurn entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Burn is undefined.",
                  ),
                )
              }
            },
            getToken0: burn => {
              let optToken0 = inMemoryStore.token->IO.InMemoryStore.Token.get(burn.token0_id)
              switch optToken0 {
              | Some(token0) => token0
              | None =>
                Logging.warn(`Burn token0 data not found. Loading associated token from database.
Please consider loading the token in the UpdateBurn entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Burn is undefined.",
                  ),
                )
              }
            },
            getPool: burn => {
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(burn.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`Burn pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdateBurn entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Burn is undefined.",
                  ),
                )
              }
            },
            getToken1: burn => {
              let optToken1 = inMemoryStore.token->IO.InMemoryStore.Token.get(burn.token1_id)
              switch optToken1 {
              | Some(token1) => token1
              | None =>
                Logging.warn(`Burn token1 data not found. Loading associated token from database.
Please consider loading the token in the UpdateBurn entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Burn is undefined.",
                  ),
                )
              }
            },
          },
          collect: {
            set: entity => {
              inMemoryStore.collect->IO.InMemoryStore.Collect.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(collect) with ID ${id}.`),
            getTransaction: collect => {
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(collect.transaction_id)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                Logging.warn(`Collect transaction data not found. Loading associated transaction from database.
Please consider loading the transaction in the UpdateCollect entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Collect is undefined.",
                  ),
                )
              }
            },
            getPool: collect => {
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(collect.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`Collect pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdateCollect entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Collect is undefined.",
                  ),
                )
              }
            },
          },
          factory: {
            set: entity => {
              inMemoryStore.factory->IO.InMemoryStore.Factory.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(factory) with ID ${id}.`),
          },
          flash: {
            set: entity => {
              inMemoryStore.flash->IO.InMemoryStore.Flash.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(flash) with ID ${id}.`),
            getPool: flash => {
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(flash.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`Flash pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdateFlash entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Flash is undefined.",
                  ),
                )
              }
            },
            getTransaction: flash => {
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(flash.transaction_id)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                Logging.warn(`Flash transaction data not found. Loading associated transaction from database.
Please consider loading the transaction in the UpdateFlash entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Flash is undefined.",
                  ),
                )
              }
            },
          },
          mint: {
            set: entity => {
              inMemoryStore.mint->IO.InMemoryStore.Mint.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(mint) with ID ${id}.`),
            getToken0: mint => {
              let optToken0 = inMemoryStore.token->IO.InMemoryStore.Token.get(mint.token0_id)
              switch optToken0 {
              | Some(token0) => token0
              | None =>
                Logging.warn(`Mint token0 data not found. Loading associated token from database.
Please consider loading the token in the UpdateMint entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Mint is undefined.",
                  ),
                )
              }
            },
            getTransaction: mint => {
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(mint.transaction_id)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                Logging.warn(`Mint transaction data not found. Loading associated transaction from database.
Please consider loading the transaction in the UpdateMint entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Mint is undefined.",
                  ),
                )
              }
            },
            getPool: mint => {
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(mint.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`Mint pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdateMint entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Mint is undefined.",
                  ),
                )
              }
            },
            getToken1: mint => {
              let optToken1 = inMemoryStore.token->IO.InMemoryStore.Token.get(mint.token1_id)
              switch optToken1 {
              | Some(token1) => token1
              | None =>
                Logging.warn(`Mint token1 data not found. Loading associated token from database.
Please consider loading the token in the UpdateMint entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Mint is undefined.",
                  ),
                )
              }
            },
          },
          pool: {
            set: entity => {
              inMemoryStore.pool->IO.InMemoryStore.Pool.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(pool) with ID ${id}.`),
            getToken1: pool => {
              let optToken1 = inMemoryStore.token->IO.InMemoryStore.Token.get(pool.token1_id)
              switch optToken1 {
              | Some(token1) => token1
              | None =>
                Logging.warn(`Pool token1 data not found. Loading associated token from database.
Please consider loading the token in the UpdatePool entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Pool is undefined.",
                  ),
                )
              }
            },
            getToken0: pool => {
              let optToken0 = inMemoryStore.token->IO.InMemoryStore.Token.get(pool.token0_id)
              switch optToken0 {
              | Some(token0) => token0
              | None =>
                Logging.warn(`Pool token0 data not found. Loading associated token from database.
Please consider loading the token in the UpdatePool entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Pool is undefined.",
                  ),
                )
              }
            },
          },
          poolDayData: {
            set: entity => {
              inMemoryStore.poolDayData->IO.InMemoryStore.PoolDayData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(poolDayData) with ID ${id}.`,
              ),
            getPool: poolDayData => {
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(poolDayData.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`PoolDayData pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdatePoolDayData entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of PoolDayData is undefined.",
                  ),
                )
              }
            },
          },
          poolHourData: {
            set: entity => {
              inMemoryStore.poolHourData->IO.InMemoryStore.PoolHourData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(poolHourData) with ID ${id}.`,
              ),
            getPool: poolHourData => {
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(poolHourData.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`PoolHourData pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdatePoolHourData entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of PoolHourData is undefined.",
                  ),
                )
              }
            },
          },
          position: {
            set: entity => {
              inMemoryStore.position->IO.InMemoryStore.Position.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(position) with ID ${id}.`),
            get: (id: Types.id) => {
              if optSetOfIds_position->Set.has(id) {
                inMemoryStore.position->IO.InMemoryStore.Position.get(id)
              } else {
                Logging.warn(
                  `The loader for a "Position" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.position.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.position->IO.InMemoryStore.Position.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
            getToken1: position => {
              let optToken1 = inMemoryStore.token->IO.InMemoryStore.Token.get(position.token1_id)
              switch optToken1 {
              | Some(token1) => token1
              | None =>
                Logging.warn(`Position token1 data not found. Loading associated token from database.
Please consider loading the token in the UpdatePosition entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Position is undefined.",
                  ),
                )
              }
            },
            getToken0: position => {
              let optToken0 = inMemoryStore.token->IO.InMemoryStore.Token.get(position.token0_id)
              switch optToken0 {
              | Some(token0) => token0
              | None =>
                Logging.warn(`Position token0 data not found. Loading associated token from database.
Please consider loading the token in the UpdatePosition entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Position is undefined.",
                  ),
                )
              }
            },
            getTickLower: position => {
              let optTickLower =
                inMemoryStore.tick->IO.InMemoryStore.Tick.get(position.tickLower_id)
              switch optTickLower {
              | Some(tickLower) => tickLower
              | None =>
                Logging.warn(`Position tickLower data not found. Loading associated tick from database.
Please consider loading the tick in the UpdatePosition entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Position is undefined.",
                  ),
                )
              }
            },
            getTransaction: position => {
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(position.transaction_id)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                Logging.warn(`Position transaction data not found. Loading associated transaction from database.
Please consider loading the transaction in the UpdatePosition entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Position is undefined.",
                  ),
                )
              }
            },
            getPool: position => {
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(position.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`Position pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdatePosition entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Position is undefined.",
                  ),
                )
              }
            },
            getTickUpper: position => {
              let optTickUpper =
                inMemoryStore.tick->IO.InMemoryStore.Tick.get(position.tickUpper_id)
              switch optTickUpper {
              | Some(tickUpper) => tickUpper
              | None =>
                Logging.warn(`Position tickUpper data not found. Loading associated tick from database.
Please consider loading the tick in the UpdatePosition entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Position is undefined.",
                  ),
                )
              }
            },
          },
          positionSnapshot: {
            set: entity => {
              inMemoryStore.positionSnapshot->IO.InMemoryStore.PositionSnapshot.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(positionSnapshot) with ID ${id}.`,
              ),
            get: (id: Types.id) => {
              if optSetOfIds_positionSnapshot->Set.has(id) {
                inMemoryStore.positionSnapshot->IO.InMemoryStore.PositionSnapshot.get(id)
              } else {
                Logging.warn(
                  `The loader for a "PositionSnapshot" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.positionSnapshot.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.positionSnapshot->IO.InMemoryStore.PositionSnapshot.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
            getPool: positionSnapshot => {
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(positionSnapshot.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`PositionSnapshot pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdatePositionSnapshot entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of PositionSnapshot is undefined.",
                  ),
                )
              }
            },
            getPosition: positionSnapshot => {
              let optPosition =
                inMemoryStore.position->IO.InMemoryStore.Position.get(positionSnapshot.position_id)
              switch optPosition {
              | Some(position) => position
              | None =>
                Logging.warn(`PositionSnapshot position data not found. Loading associated position from database.
Please consider loading the position in the UpdatePositionSnapshot entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of PositionSnapshot is undefined.",
                  ),
                )
              }
            },
            getTransaction: positionSnapshot => {
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(
                  positionSnapshot.transaction_id,
                )
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                Logging.warn(`PositionSnapshot transaction data not found. Loading associated transaction from database.
Please consider loading the transaction in the UpdatePositionSnapshot entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of PositionSnapshot is undefined.",
                  ),
                )
              }
            },
          },
          swap: {
            set: entity => {
              inMemoryStore.swap->IO.InMemoryStore.Swap.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(swap) with ID ${id}.`),
            getTick: swap => {
              let optTick = inMemoryStore.tick->IO.InMemoryStore.Tick.get(swap.tick_id)
              switch optTick {
              | Some(tick) => tick
              | None =>
                Logging.warn(`Swap tick data not found. Loading associated tick from database.
Please consider loading the tick in the UpdateSwap entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Swap is undefined.",
                  ),
                )
              }
            },
            getTransaction: swap => {
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(swap.transaction_id)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                Logging.warn(`Swap transaction data not found. Loading associated transaction from database.
Please consider loading the transaction in the UpdateSwap entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Swap is undefined.",
                  ),
                )
              }
            },
            getToken1: swap => {
              let optToken1 = inMemoryStore.token->IO.InMemoryStore.Token.get(swap.token1_id)
              switch optToken1 {
              | Some(token1) => token1
              | None =>
                Logging.warn(`Swap token1 data not found. Loading associated token from database.
Please consider loading the token in the UpdateSwap entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Swap is undefined.",
                  ),
                )
              }
            },
            getToken0: swap => {
              let optToken0 = inMemoryStore.token->IO.InMemoryStore.Token.get(swap.token0_id)
              switch optToken0 {
              | Some(token0) => token0
              | None =>
                Logging.warn(`Swap token0 data not found. Loading associated token from database.
Please consider loading the token in the UpdateSwap entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Swap is undefined.",
                  ),
                )
              }
            },
            getPool: swap => {
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(swap.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`Swap pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdateSwap entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Swap is undefined.",
                  ),
                )
              }
            },
          },
          tick: {
            set: entity => {
              inMemoryStore.tick->IO.InMemoryStore.Tick.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(tick) with ID ${id}.`),
            getPool: tick => {
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(tick.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`Tick pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdateTick entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Tick is undefined.",
                  ),
                )
              }
            },
          },
          tickDayData: {
            set: entity => {
              inMemoryStore.tickDayData->IO.InMemoryStore.TickDayData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(tickDayData) with ID ${id}.`,
              ),
            getPool: tickDayData => {
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(tickDayData.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`TickDayData pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdateTickDayData entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of TickDayData is undefined.",
                  ),
                )
              }
            },
            getTick: tickDayData => {
              let optTick = inMemoryStore.tick->IO.InMemoryStore.Tick.get(tickDayData.tick_id)
              switch optTick {
              | Some(tick) => tick
              | None =>
                Logging.warn(`TickDayData tick data not found. Loading associated tick from database.
Please consider loading the tick in the UpdateTickDayData entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of TickDayData is undefined.",
                  ),
                )
              }
            },
          },
          tickHourData: {
            set: entity => {
              inMemoryStore.tickHourData->IO.InMemoryStore.TickHourData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(tickHourData) with ID ${id}.`,
              ),
            getTick: tickHourData => {
              let optTick = inMemoryStore.tick->IO.InMemoryStore.Tick.get(tickHourData.tick_id)
              switch optTick {
              | Some(tick) => tick
              | None =>
                Logging.warn(`TickHourData tick data not found. Loading associated tick from database.
Please consider loading the tick in the UpdateTickHourData entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of TickHourData is undefined.",
                  ),
                )
              }
            },
            getPool: tickHourData => {
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(tickHourData.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`TickHourData pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdateTickHourData entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of TickHourData is undefined.",
                  ),
                )
              }
            },
          },
          token: {
            set: entity => {
              inMemoryStore.token->IO.InMemoryStore.Token.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(token) with ID ${id}.`),
          },
          tokenDayData: {
            set: entity => {
              inMemoryStore.tokenDayData->IO.InMemoryStore.TokenDayData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(tokenDayData) with ID ${id}.`,
              ),
            getToken: tokenDayData => {
              let optToken = inMemoryStore.token->IO.InMemoryStore.Token.get(tokenDayData.token_id)
              switch optToken {
              | Some(token) => token
              | None =>
                Logging.warn(`TokenDayData token data not found. Loading associated token from database.
Please consider loading the token in the UpdateTokenDayData entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of TokenDayData is undefined.",
                  ),
                )
              }
            },
          },
          tokenHourData: {
            set: entity => {
              inMemoryStore.tokenHourData->IO.InMemoryStore.TokenHourData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(tokenHourData) with ID ${id}.`,
              ),
            getToken: tokenHourData => {
              let optToken = inMemoryStore.token->IO.InMemoryStore.Token.get(tokenHourData.token_id)
              switch optToken {
              | Some(token) => token
              | None =>
                Logging.warn(`TokenHourData token data not found. Loading associated token from database.
Please consider loading the token in the UpdateTokenHourData entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of TokenHourData is undefined.",
                  ),
                )
              }
            },
          },
          tokenPoolWhitelist: {
            set: entity => {
              inMemoryStore.tokenPoolWhitelist->IO.InMemoryStore.TokenPoolWhitelist.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(tokenPoolWhitelist) with ID ${id}.`,
              ),
            getToken: tokenPoolWhitelist => {
              let optToken =
                inMemoryStore.token->IO.InMemoryStore.Token.get(tokenPoolWhitelist.token_id)
              switch optToken {
              | Some(token) => token
              | None =>
                Logging.warn(`TokenPoolWhitelist token data not found. Loading associated token from database.
Please consider loading the token in the UpdateTokenPoolWhitelist entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of TokenPoolWhitelist is undefined.",
                  ),
                )
              }
            },
            getPool: tokenPoolWhitelist => {
              let optPool =
                inMemoryStore.pool->IO.InMemoryStore.Pool.get(tokenPoolWhitelist.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`TokenPoolWhitelist pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdateTokenPoolWhitelist entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of TokenPoolWhitelist is undefined.",
                  ),
                )
              }
            },
          },
          transaction: {
            set: entity => {
              inMemoryStore.transaction->IO.InMemoryStore.Transaction.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(transaction) with ID ${id}.`,
              ),
          },
          uniswapDayData: {
            set: entity => {
              inMemoryStore.uniswapDayData->IO.InMemoryStore.UniswapDayData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(uniswapDayData) with ID ${id}.`,
              ),
          },
        }
      }

      let getHandlerContextAsync = (): handlerContextAsync => {
        {
          log: contextLogger,
          bundle: {
            set: entity => {
              inMemoryStore.bundle->IO.InMemoryStore.Bundle.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(bundle) with ID ${id}.`),
          },
          burn: {
            set: entity => {
              inMemoryStore.burn->IO.InMemoryStore.Burn.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(burn) with ID ${id}.`),
            getTransaction: async burn => {
              let transaction_field = burn.transaction_id
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(transaction_field)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                let entities = await asyncGetters.getTransaction(transaction_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Transaction.set(
                    inMemoryStore.transaction,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Burn transaction data not found. Loading associated transaction from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity transaction of Burn is undefined.",
                    ),
                  )
                }
              }
            },
            getToken0: async burn => {
              let token0_field = burn.token0_id
              let optToken0 = inMemoryStore.token->IO.InMemoryStore.Token.get(token0_field)
              switch optToken0 {
              | Some(token0) => token0
              | None =>
                let entities = await asyncGetters.getToken(token0_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Burn token0 data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token0 of Burn is undefined.",
                    ),
                  )
                }
              }
            },
            getPool: async burn => {
              let pool_field = burn.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Burn pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of Burn is undefined.",
                    ),
                  )
                }
              }
            },
            getToken1: async burn => {
              let token1_field = burn.token1_id
              let optToken1 = inMemoryStore.token->IO.InMemoryStore.Token.get(token1_field)
              switch optToken1 {
              | Some(token1) => token1
              | None =>
                let entities = await asyncGetters.getToken(token1_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Burn token1 data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token1 of Burn is undefined.",
                    ),
                  )
                }
              }
            },
          },
          collect: {
            set: entity => {
              inMemoryStore.collect->IO.InMemoryStore.Collect.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(collect) with ID ${id}.`),
            getTransaction: async collect => {
              let transaction_field = collect.transaction_id
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(transaction_field)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                let entities = await asyncGetters.getTransaction(transaction_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Transaction.set(
                    inMemoryStore.transaction,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Collect transaction data not found. Loading associated transaction from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity transaction of Collect is undefined.",
                    ),
                  )
                }
              }
            },
            getPool: async collect => {
              let pool_field = collect.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Collect pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of Collect is undefined.",
                    ),
                  )
                }
              }
            },
          },
          factory: {
            set: entity => {
              inMemoryStore.factory->IO.InMemoryStore.Factory.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(factory) with ID ${id}.`),
          },
          flash: {
            set: entity => {
              inMemoryStore.flash->IO.InMemoryStore.Flash.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(flash) with ID ${id}.`),
            getPool: async flash => {
              let pool_field = flash.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Flash pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of Flash is undefined.",
                    ),
                  )
                }
              }
            },
            getTransaction: async flash => {
              let transaction_field = flash.transaction_id
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(transaction_field)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                let entities = await asyncGetters.getTransaction(transaction_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Transaction.set(
                    inMemoryStore.transaction,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Flash transaction data not found. Loading associated transaction from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity transaction of Flash is undefined.",
                    ),
                  )
                }
              }
            },
          },
          mint: {
            set: entity => {
              inMemoryStore.mint->IO.InMemoryStore.Mint.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(mint) with ID ${id}.`),
            getToken0: async mint => {
              let token0_field = mint.token0_id
              let optToken0 = inMemoryStore.token->IO.InMemoryStore.Token.get(token0_field)
              switch optToken0 {
              | Some(token0) => token0
              | None =>
                let entities = await asyncGetters.getToken(token0_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Mint token0 data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token0 of Mint is undefined.",
                    ),
                  )
                }
              }
            },
            getTransaction: async mint => {
              let transaction_field = mint.transaction_id
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(transaction_field)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                let entities = await asyncGetters.getTransaction(transaction_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Transaction.set(
                    inMemoryStore.transaction,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Mint transaction data not found. Loading associated transaction from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity transaction of Mint is undefined.",
                    ),
                  )
                }
              }
            },
            getPool: async mint => {
              let pool_field = mint.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Mint pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of Mint is undefined.",
                    ),
                  )
                }
              }
            },
            getToken1: async mint => {
              let token1_field = mint.token1_id
              let optToken1 = inMemoryStore.token->IO.InMemoryStore.Token.get(token1_field)
              switch optToken1 {
              | Some(token1) => token1
              | None =>
                let entities = await asyncGetters.getToken(token1_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Mint token1 data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token1 of Mint is undefined.",
                    ),
                  )
                }
              }
            },
          },
          pool: {
            set: entity => {
              inMemoryStore.pool->IO.InMemoryStore.Pool.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(pool) with ID ${id}.`),
            getToken1: async pool => {
              let token1_field = pool.token1_id
              let optToken1 = inMemoryStore.token->IO.InMemoryStore.Token.get(token1_field)
              switch optToken1 {
              | Some(token1) => token1
              | None =>
                let entities = await asyncGetters.getToken(token1_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Pool token1 data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token1 of Pool is undefined.",
                    ),
                  )
                }
              }
            },
            getToken0: async pool => {
              let token0_field = pool.token0_id
              let optToken0 = inMemoryStore.token->IO.InMemoryStore.Token.get(token0_field)
              switch optToken0 {
              | Some(token0) => token0
              | None =>
                let entities = await asyncGetters.getToken(token0_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Pool token0 data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token0 of Pool is undefined.",
                    ),
                  )
                }
              }
            },
          },
          poolDayData: {
            set: entity => {
              inMemoryStore.poolDayData->IO.InMemoryStore.PoolDayData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(poolDayData) with ID ${id}.`,
              ),
            getPool: async poolDayData => {
              let pool_field = poolDayData.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`PoolDayData pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of PoolDayData is undefined.",
                    ),
                  )
                }
              }
            },
          },
          poolHourData: {
            set: entity => {
              inMemoryStore.poolHourData->IO.InMemoryStore.PoolHourData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(poolHourData) with ID ${id}.`,
              ),
            getPool: async poolHourData => {
              let pool_field = poolHourData.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`PoolHourData pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of PoolHourData is undefined.",
                    ),
                  )
                }
              }
            },
          },
          position: {
            set: entity => {
              inMemoryStore.position->IO.InMemoryStore.Position.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(position) with ID ${id}.`),
            get: async (id: Types.id) => {
              if optSetOfIds_position->Set.has(id) {
                inMemoryStore.position->IO.InMemoryStore.Position.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.position->IO.InMemoryStore.Position.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getPosition(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Position.set(
                      inMemoryStore.position,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    Some(entity)
                  | None => None
                  }
                }
              }
            },
            getToken1: async position => {
              let token1_field = position.token1_id
              let optToken1 = inMemoryStore.token->IO.InMemoryStore.Token.get(token1_field)
              switch optToken1 {
              | Some(token1) => token1
              | None =>
                let entities = await asyncGetters.getToken(token1_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Position token1 data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token1 of Position is undefined.",
                    ),
                  )
                }
              }
            },
            getToken0: async position => {
              let token0_field = position.token0_id
              let optToken0 = inMemoryStore.token->IO.InMemoryStore.Token.get(token0_field)
              switch optToken0 {
              | Some(token0) => token0
              | None =>
                let entities = await asyncGetters.getToken(token0_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Position token0 data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token0 of Position is undefined.",
                    ),
                  )
                }
              }
            },
            getTickLower: async position => {
              let tickLower_field = position.tickLower_id
              let optTickLower = inMemoryStore.tick->IO.InMemoryStore.Tick.get(tickLower_field)
              switch optTickLower {
              | Some(tickLower) => tickLower
              | None =>
                let entities = await asyncGetters.getTick(tickLower_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Tick.set(
                    inMemoryStore.tick,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Position tickLower data not found. Loading associated tick from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity tickLower of Position is undefined.",
                    ),
                  )
                }
              }
            },
            getTransaction: async position => {
              let transaction_field = position.transaction_id
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(transaction_field)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                let entities = await asyncGetters.getTransaction(transaction_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Transaction.set(
                    inMemoryStore.transaction,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Position transaction data not found. Loading associated transaction from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity transaction of Position is undefined.",
                    ),
                  )
                }
              }
            },
            getPool: async position => {
              let pool_field = position.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Position pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of Position is undefined.",
                    ),
                  )
                }
              }
            },
            getTickUpper: async position => {
              let tickUpper_field = position.tickUpper_id
              let optTickUpper = inMemoryStore.tick->IO.InMemoryStore.Tick.get(tickUpper_field)
              switch optTickUpper {
              | Some(tickUpper) => tickUpper
              | None =>
                let entities = await asyncGetters.getTick(tickUpper_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Tick.set(
                    inMemoryStore.tick,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Position tickUpper data not found. Loading associated tick from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity tickUpper of Position is undefined.",
                    ),
                  )
                }
              }
            },
          },
          positionSnapshot: {
            set: entity => {
              inMemoryStore.positionSnapshot->IO.InMemoryStore.PositionSnapshot.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(positionSnapshot) with ID ${id}.`,
              ),
            get: async (id: Types.id) => {
              if optSetOfIds_positionSnapshot->Set.has(id) {
                inMemoryStore.positionSnapshot->IO.InMemoryStore.PositionSnapshot.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.positionSnapshot->IO.InMemoryStore.PositionSnapshot.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getPositionSnapshot(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.PositionSnapshot.set(
                      inMemoryStore.positionSnapshot,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    Some(entity)
                  | None => None
                  }
                }
              }
            },
            getPool: async positionSnapshot => {
              let pool_field = positionSnapshot.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`PositionSnapshot pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of PositionSnapshot is undefined.",
                    ),
                  )
                }
              }
            },
            getPosition: async positionSnapshot => {
              let position_field = positionSnapshot.position_id
              let optPosition =
                inMemoryStore.position->IO.InMemoryStore.Position.get(position_field)
              switch optPosition {
              | Some(position) => position
              | None =>
                let entities = await asyncGetters.getPosition(position_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Position.set(
                    inMemoryStore.position,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`PositionSnapshot position data not found. Loading associated position from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity position of PositionSnapshot is undefined.",
                    ),
                  )
                }
              }
            },
            getTransaction: async positionSnapshot => {
              let transaction_field = positionSnapshot.transaction_id
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(transaction_field)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                let entities = await asyncGetters.getTransaction(transaction_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Transaction.set(
                    inMemoryStore.transaction,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`PositionSnapshot transaction data not found. Loading associated transaction from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity transaction of PositionSnapshot is undefined.",
                    ),
                  )
                }
              }
            },
          },
          swap: {
            set: entity => {
              inMemoryStore.swap->IO.InMemoryStore.Swap.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(swap) with ID ${id}.`),
            getTick: async swap => {
              let tick_field = swap.tick_id
              let optTick = inMemoryStore.tick->IO.InMemoryStore.Tick.get(tick_field)
              switch optTick {
              | Some(tick) => tick
              | None =>
                let entities = await asyncGetters.getTick(tick_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Tick.set(
                    inMemoryStore.tick,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Swap tick data not found. Loading associated tick from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity tick of Swap is undefined.",
                    ),
                  )
                }
              }
            },
            getTransaction: async swap => {
              let transaction_field = swap.transaction_id
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(transaction_field)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                let entities = await asyncGetters.getTransaction(transaction_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Transaction.set(
                    inMemoryStore.transaction,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Swap transaction data not found. Loading associated transaction from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity transaction of Swap is undefined.",
                    ),
                  )
                }
              }
            },
            getToken1: async swap => {
              let token1_field = swap.token1_id
              let optToken1 = inMemoryStore.token->IO.InMemoryStore.Token.get(token1_field)
              switch optToken1 {
              | Some(token1) => token1
              | None =>
                let entities = await asyncGetters.getToken(token1_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Swap token1 data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token1 of Swap is undefined.",
                    ),
                  )
                }
              }
            },
            getToken0: async swap => {
              let token0_field = swap.token0_id
              let optToken0 = inMemoryStore.token->IO.InMemoryStore.Token.get(token0_field)
              switch optToken0 {
              | Some(token0) => token0
              | None =>
                let entities = await asyncGetters.getToken(token0_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Swap token0 data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token0 of Swap is undefined.",
                    ),
                  )
                }
              }
            },
            getPool: async swap => {
              let pool_field = swap.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Swap pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of Swap is undefined.",
                    ),
                  )
                }
              }
            },
          },
          tick: {
            set: entity => {
              inMemoryStore.tick->IO.InMemoryStore.Tick.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(tick) with ID ${id}.`),
            getPool: async tick => {
              let pool_field = tick.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Tick pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of Tick is undefined.",
                    ),
                  )
                }
              }
            },
          },
          tickDayData: {
            set: entity => {
              inMemoryStore.tickDayData->IO.InMemoryStore.TickDayData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(tickDayData) with ID ${id}.`,
              ),
            getPool: async tickDayData => {
              let pool_field = tickDayData.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`TickDayData pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of TickDayData is undefined.",
                    ),
                  )
                }
              }
            },
            getTick: async tickDayData => {
              let tick_field = tickDayData.tick_id
              let optTick = inMemoryStore.tick->IO.InMemoryStore.Tick.get(tick_field)
              switch optTick {
              | Some(tick) => tick
              | None =>
                let entities = await asyncGetters.getTick(tick_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Tick.set(
                    inMemoryStore.tick,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`TickDayData tick data not found. Loading associated tick from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity tick of TickDayData is undefined.",
                    ),
                  )
                }
              }
            },
          },
          tickHourData: {
            set: entity => {
              inMemoryStore.tickHourData->IO.InMemoryStore.TickHourData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(tickHourData) with ID ${id}.`,
              ),
            getTick: async tickHourData => {
              let tick_field = tickHourData.tick_id
              let optTick = inMemoryStore.tick->IO.InMemoryStore.Tick.get(tick_field)
              switch optTick {
              | Some(tick) => tick
              | None =>
                let entities = await asyncGetters.getTick(tick_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Tick.set(
                    inMemoryStore.tick,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`TickHourData tick data not found. Loading associated tick from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity tick of TickHourData is undefined.",
                    ),
                  )
                }
              }
            },
            getPool: async tickHourData => {
              let pool_field = tickHourData.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`TickHourData pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of TickHourData is undefined.",
                    ),
                  )
                }
              }
            },
          },
          token: {
            set: entity => {
              inMemoryStore.token->IO.InMemoryStore.Token.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(token) with ID ${id}.`),
          },
          tokenDayData: {
            set: entity => {
              inMemoryStore.tokenDayData->IO.InMemoryStore.TokenDayData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(tokenDayData) with ID ${id}.`,
              ),
            getToken: async tokenDayData => {
              let token_field = tokenDayData.token_id
              let optToken = inMemoryStore.token->IO.InMemoryStore.Token.get(token_field)
              switch optToken {
              | Some(token) => token
              | None =>
                let entities = await asyncGetters.getToken(token_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`TokenDayData token data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token of TokenDayData is undefined.",
                    ),
                  )
                }
              }
            },
          },
          tokenHourData: {
            set: entity => {
              inMemoryStore.tokenHourData->IO.InMemoryStore.TokenHourData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(tokenHourData) with ID ${id}.`,
              ),
            getToken: async tokenHourData => {
              let token_field = tokenHourData.token_id
              let optToken = inMemoryStore.token->IO.InMemoryStore.Token.get(token_field)
              switch optToken {
              | Some(token) => token
              | None =>
                let entities = await asyncGetters.getToken(token_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`TokenHourData token data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token of TokenHourData is undefined.",
                    ),
                  )
                }
              }
            },
          },
          tokenPoolWhitelist: {
            set: entity => {
              inMemoryStore.tokenPoolWhitelist->IO.InMemoryStore.TokenPoolWhitelist.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(tokenPoolWhitelist) with ID ${id}.`,
              ),
            getToken: async tokenPoolWhitelist => {
              let token_field = tokenPoolWhitelist.token_id
              let optToken = inMemoryStore.token->IO.InMemoryStore.Token.get(token_field)
              switch optToken {
              | Some(token) => token
              | None =>
                let entities = await asyncGetters.getToken(token_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`TokenPoolWhitelist token data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token of TokenPoolWhitelist is undefined.",
                    ),
                  )
                }
              }
            },
            getPool: async tokenPoolWhitelist => {
              let pool_field = tokenPoolWhitelist.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`TokenPoolWhitelist pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of TokenPoolWhitelist is undefined.",
                    ),
                  )
                }
              }
            },
          },
          transaction: {
            set: entity => {
              inMemoryStore.transaction->IO.InMemoryStore.Transaction.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(transaction) with ID ${id}.`,
              ),
          },
          uniswapDayData: {
            set: entity => {
              inMemoryStore.uniswapDayData->IO.InMemoryStore.UniswapDayData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(uniswapDayData) with ID ${id}.`,
              ),
          },
        }
      }

      {
        logger,
        log: contextLogger,
        getEntitiesToLoad: () => entitiesToLoad,
        getAddedDynamicContractRegistrations: () => addedDynamicContractRegistrations,
        getLoaderContext: () => loaderContext,
        getHandlerContextSync,
        getHandlerContextAsync,
      }
    }
  }
}

module PoolContract = {
  module SwapEvent = {
    type loaderContext = Types.PoolContract.SwapEvent.loaderContext
    type handlerContext = Types.PoolContract.SwapEvent.handlerContext
    type handlerContextAsync = Types.PoolContract.SwapEvent.handlerContextAsync
    type context = genericContextCreatorFunctions<
      loaderContext,
      handlerContext,
      handlerContextAsync,
    >

    let contextCreator: contextCreator<
      Types.PoolContract.SwapEvent.eventArgs,
      loaderContext,
      handlerContext,
      handlerContextAsync,
    > = (~inMemoryStore, ~chainId, ~event, ~logger, ~asyncGetters) => {
      // NOTE: we could optimise this code to onle create a logger if there was a log called.
      let logger = logger->Logging.createChildFrom(
        ~logger=_,
        ~params={
          "context": "Pool.Swap",
          "chainId": chainId,
          "block": event.blockNumber,
          "logIndex": event.logIndex,
          "txHash": event.transactionHash,
        },
      )

      let contextLogger: Logs.userLogger = {
        info: (message: string) => logger->Logging.uinfo(message),
        debug: (message: string) => logger->Logging.udebug(message),
        warn: (message: string) => logger->Logging.uwarn(message),
        error: (message: string) => logger->Logging.uerror(message),
        errorWithExn: (exn: option<Js.Exn.t>, message: string) =>
          logger->Logging.uerrorWithExn(exn, message),
      }

      let optSetOfIds_swap: Set.t<Types.id> = Set.make()
      let optSetOfIds_token: Set.t<Types.id> = Set.make()

      let entitiesToLoad: array<Types.entityRead> = []

      let addedDynamicContractRegistrations: array<Types.dynamicContractRegistryEntity> = []

      //Loader context can be defined as a value and the getter can return that value

      @warning("-16")
      let loaderContext: loaderContext = {
        log: contextLogger,
        contractRegistration: {
          //TODO only add contracts we've registered for the event in the config
          addFactory: (contractAddress: Ethers.ethAddress) => {
            let eventId = EventUtils.packEventIndex(
              ~blockNumber=event.blockNumber,
              ~logIndex=event.logIndex,
            )
            let dynamicContractRegistration: Types.dynamicContractRegistryEntity = {
              chainId,
              eventId,
              contractAddress,
              contractType: "Factory",
            }

            addedDynamicContractRegistrations->Js.Array2.push(dynamicContractRegistration)->ignore

            inMemoryStore.dynamicContractRegistry->IO.InMemoryStore.DynamicContractRegistry.set(
              ~key={chainId, contractAddress},
              ~entity=dynamicContractRegistration,
              ~dbOp=Set,
            )
          },
          //TODO only add contracts we've registered for the event in the config
          addNonfungiblePositionManager: (contractAddress: Ethers.ethAddress) => {
            let eventId = EventUtils.packEventIndex(
              ~blockNumber=event.blockNumber,
              ~logIndex=event.logIndex,
            )
            let dynamicContractRegistration: Types.dynamicContractRegistryEntity = {
              chainId,
              eventId,
              contractAddress,
              contractType: "NonfungiblePositionManager",
            }

            addedDynamicContractRegistrations->Js.Array2.push(dynamicContractRegistration)->ignore

            inMemoryStore.dynamicContractRegistry->IO.InMemoryStore.DynamicContractRegistry.set(
              ~key={chainId, contractAddress},
              ~entity=dynamicContractRegistration,
              ~dbOp=Set,
            )
          },
          //TODO only add contracts we've registered for the event in the config
          addPool: (contractAddress: Ethers.ethAddress) => {
            let eventId = EventUtils.packEventIndex(
              ~blockNumber=event.blockNumber,
              ~logIndex=event.logIndex,
            )
            let dynamicContractRegistration: Types.dynamicContractRegistryEntity = {
              chainId,
              eventId,
              contractAddress,
              contractType: "Pool",
            }

            addedDynamicContractRegistrations->Js.Array2.push(dynamicContractRegistration)->ignore

            inMemoryStore.dynamicContractRegistry->IO.InMemoryStore.DynamicContractRegistry.set(
              ~key={chainId, contractAddress},
              ~entity=dynamicContractRegistration,
              ~dbOp=Set,
            )
          },
        },
        swap: {
          load: (id: Types.id, ~loaders={}) => {
            let _ = optSetOfIds_swap->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.SwapRead(id, loaders))
          },
        },
        token: {
          load: (id: Types.id) => {
            let _ = optSetOfIds_token->Set.add(id)
            let _ = Js.Array2.push(entitiesToLoad, Types.TokenRead(id))
          },
        },
      }

      //handler context must be defined as a getter functoin so that it can construct the context
      //without stale values whenever it is used
      let getHandlerContextSync: unit => handlerContext = () => {
        {
          log: contextLogger,
          bundle: {
            set: entity => {
              inMemoryStore.bundle->IO.InMemoryStore.Bundle.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(bundle) with ID ${id}.`),
          },
          burn: {
            set: entity => {
              inMemoryStore.burn->IO.InMemoryStore.Burn.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(burn) with ID ${id}.`),
            getTransaction: burn => {
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(burn.transaction_id)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                Logging.warn(`Burn transaction data not found. Loading associated transaction from database.
Please consider loading the transaction in the UpdateBurn entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Burn is undefined.",
                  ),
                )
              }
            },
            getToken0: burn => {
              let optToken0 = inMemoryStore.token->IO.InMemoryStore.Token.get(burn.token0_id)
              switch optToken0 {
              | Some(token0) => token0
              | None =>
                Logging.warn(`Burn token0 data not found. Loading associated token from database.
Please consider loading the token in the UpdateBurn entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Burn is undefined.",
                  ),
                )
              }
            },
            getPool: burn => {
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(burn.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`Burn pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdateBurn entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Burn is undefined.",
                  ),
                )
              }
            },
            getToken1: burn => {
              let optToken1 = inMemoryStore.token->IO.InMemoryStore.Token.get(burn.token1_id)
              switch optToken1 {
              | Some(token1) => token1
              | None =>
                Logging.warn(`Burn token1 data not found. Loading associated token from database.
Please consider loading the token in the UpdateBurn entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Burn is undefined.",
                  ),
                )
              }
            },
          },
          collect: {
            set: entity => {
              inMemoryStore.collect->IO.InMemoryStore.Collect.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(collect) with ID ${id}.`),
            getTransaction: collect => {
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(collect.transaction_id)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                Logging.warn(`Collect transaction data not found. Loading associated transaction from database.
Please consider loading the transaction in the UpdateCollect entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Collect is undefined.",
                  ),
                )
              }
            },
            getPool: collect => {
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(collect.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`Collect pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdateCollect entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Collect is undefined.",
                  ),
                )
              }
            },
          },
          factory: {
            set: entity => {
              inMemoryStore.factory->IO.InMemoryStore.Factory.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(factory) with ID ${id}.`),
          },
          flash: {
            set: entity => {
              inMemoryStore.flash->IO.InMemoryStore.Flash.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(flash) with ID ${id}.`),
            getPool: flash => {
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(flash.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`Flash pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdateFlash entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Flash is undefined.",
                  ),
                )
              }
            },
            getTransaction: flash => {
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(flash.transaction_id)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                Logging.warn(`Flash transaction data not found. Loading associated transaction from database.
Please consider loading the transaction in the UpdateFlash entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Flash is undefined.",
                  ),
                )
              }
            },
          },
          mint: {
            set: entity => {
              inMemoryStore.mint->IO.InMemoryStore.Mint.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(mint) with ID ${id}.`),
            getToken0: mint => {
              let optToken0 = inMemoryStore.token->IO.InMemoryStore.Token.get(mint.token0_id)
              switch optToken0 {
              | Some(token0) => token0
              | None =>
                Logging.warn(`Mint token0 data not found. Loading associated token from database.
Please consider loading the token in the UpdateMint entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Mint is undefined.",
                  ),
                )
              }
            },
            getTransaction: mint => {
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(mint.transaction_id)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                Logging.warn(`Mint transaction data not found. Loading associated transaction from database.
Please consider loading the transaction in the UpdateMint entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Mint is undefined.",
                  ),
                )
              }
            },
            getPool: mint => {
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(mint.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`Mint pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdateMint entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Mint is undefined.",
                  ),
                )
              }
            },
            getToken1: mint => {
              let optToken1 = inMemoryStore.token->IO.InMemoryStore.Token.get(mint.token1_id)
              switch optToken1 {
              | Some(token1) => token1
              | None =>
                Logging.warn(`Mint token1 data not found. Loading associated token from database.
Please consider loading the token in the UpdateMint entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Mint is undefined.",
                  ),
                )
              }
            },
          },
          pool: {
            set: entity => {
              inMemoryStore.pool->IO.InMemoryStore.Pool.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(pool) with ID ${id}.`),
            getToken1: pool => {
              let optToken1 = inMemoryStore.token->IO.InMemoryStore.Token.get(pool.token1_id)
              switch optToken1 {
              | Some(token1) => token1
              | None =>
                Logging.warn(`Pool token1 data not found. Loading associated token from database.
Please consider loading the token in the UpdatePool entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Pool is undefined.",
                  ),
                )
              }
            },
            getToken0: pool => {
              let optToken0 = inMemoryStore.token->IO.InMemoryStore.Token.get(pool.token0_id)
              switch optToken0 {
              | Some(token0) => token0
              | None =>
                Logging.warn(`Pool token0 data not found. Loading associated token from database.
Please consider loading the token in the UpdatePool entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Pool is undefined.",
                  ),
                )
              }
            },
          },
          poolDayData: {
            set: entity => {
              inMemoryStore.poolDayData->IO.InMemoryStore.PoolDayData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(poolDayData) with ID ${id}.`,
              ),
            getPool: poolDayData => {
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(poolDayData.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`PoolDayData pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdatePoolDayData entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of PoolDayData is undefined.",
                  ),
                )
              }
            },
          },
          poolHourData: {
            set: entity => {
              inMemoryStore.poolHourData->IO.InMemoryStore.PoolHourData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(poolHourData) with ID ${id}.`,
              ),
            getPool: poolHourData => {
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(poolHourData.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`PoolHourData pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdatePoolHourData entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of PoolHourData is undefined.",
                  ),
                )
              }
            },
          },
          position: {
            set: entity => {
              inMemoryStore.position->IO.InMemoryStore.Position.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(position) with ID ${id}.`),
            getToken1: position => {
              let optToken1 = inMemoryStore.token->IO.InMemoryStore.Token.get(position.token1_id)
              switch optToken1 {
              | Some(token1) => token1
              | None =>
                Logging.warn(`Position token1 data not found. Loading associated token from database.
Please consider loading the token in the UpdatePosition entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Position is undefined.",
                  ),
                )
              }
            },
            getToken0: position => {
              let optToken0 = inMemoryStore.token->IO.InMemoryStore.Token.get(position.token0_id)
              switch optToken0 {
              | Some(token0) => token0
              | None =>
                Logging.warn(`Position token0 data not found. Loading associated token from database.
Please consider loading the token in the UpdatePosition entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Position is undefined.",
                  ),
                )
              }
            },
            getTickLower: position => {
              let optTickLower =
                inMemoryStore.tick->IO.InMemoryStore.Tick.get(position.tickLower_id)
              switch optTickLower {
              | Some(tickLower) => tickLower
              | None =>
                Logging.warn(`Position tickLower data not found. Loading associated tick from database.
Please consider loading the tick in the UpdatePosition entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Position is undefined.",
                  ),
                )
              }
            },
            getTransaction: position => {
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(position.transaction_id)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                Logging.warn(`Position transaction data not found. Loading associated transaction from database.
Please consider loading the transaction in the UpdatePosition entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Position is undefined.",
                  ),
                )
              }
            },
            getPool: position => {
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(position.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`Position pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdatePosition entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Position is undefined.",
                  ),
                )
              }
            },
            getTickUpper: position => {
              let optTickUpper =
                inMemoryStore.tick->IO.InMemoryStore.Tick.get(position.tickUpper_id)
              switch optTickUpper {
              | Some(tickUpper) => tickUpper
              | None =>
                Logging.warn(`Position tickUpper data not found. Loading associated tick from database.
Please consider loading the tick in the UpdatePosition entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Position is undefined.",
                  ),
                )
              }
            },
          },
          positionSnapshot: {
            set: entity => {
              inMemoryStore.positionSnapshot->IO.InMemoryStore.PositionSnapshot.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(positionSnapshot) with ID ${id}.`,
              ),
            getPool: positionSnapshot => {
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(positionSnapshot.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`PositionSnapshot pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdatePositionSnapshot entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of PositionSnapshot is undefined.",
                  ),
                )
              }
            },
            getPosition: positionSnapshot => {
              let optPosition =
                inMemoryStore.position->IO.InMemoryStore.Position.get(positionSnapshot.position_id)
              switch optPosition {
              | Some(position) => position
              | None =>
                Logging.warn(`PositionSnapshot position data not found. Loading associated position from database.
Please consider loading the position in the UpdatePositionSnapshot entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of PositionSnapshot is undefined.",
                  ),
                )
              }
            },
            getTransaction: positionSnapshot => {
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(
                  positionSnapshot.transaction_id,
                )
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                Logging.warn(`PositionSnapshot transaction data not found. Loading associated transaction from database.
Please consider loading the transaction in the UpdatePositionSnapshot entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of PositionSnapshot is undefined.",
                  ),
                )
              }
            },
          },
          swap: {
            set: entity => {
              inMemoryStore.swap->IO.InMemoryStore.Swap.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(swap) with ID ${id}.`),
            get: (id: Types.id) => {
              if optSetOfIds_swap->Set.has(id) {
                inMemoryStore.swap->IO.InMemoryStore.Swap.get(id)
              } else {
                Logging.warn(
                  `The loader for a "Swap" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.swap.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.swap->IO.InMemoryStore.Swap.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
            getTick: swap => {
              let optTick = inMemoryStore.tick->IO.InMemoryStore.Tick.get(swap.tick_id)
              switch optTick {
              | Some(tick) => tick
              | None =>
                Logging.warn(`Swap tick data not found. Loading associated tick from database.
Please consider loading the tick in the UpdateSwap entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Swap is undefined.",
                  ),
                )
              }
            },
            getTransaction: swap => {
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(swap.transaction_id)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                Logging.warn(`Swap transaction data not found. Loading associated transaction from database.
Please consider loading the transaction in the UpdateSwap entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Swap is undefined.",
                  ),
                )
              }
            },
            getToken1: swap => {
              let optToken1 = inMemoryStore.token->IO.InMemoryStore.Token.get(swap.token1_id)
              switch optToken1 {
              | Some(token1) => token1
              | None =>
                Logging.warn(`Swap token1 data not found. Loading associated token from database.
Please consider loading the token in the UpdateSwap entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Swap is undefined.",
                  ),
                )
              }
            },
            getToken0: swap => {
              let optToken0 = inMemoryStore.token->IO.InMemoryStore.Token.get(swap.token0_id)
              switch optToken0 {
              | Some(token0) => token0
              | None =>
                Logging.warn(`Swap token0 data not found. Loading associated token from database.
Please consider loading the token in the UpdateSwap entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Swap is undefined.",
                  ),
                )
              }
            },
            getPool: swap => {
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(swap.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`Swap pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdateSwap entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Swap is undefined.",
                  ),
                )
              }
            },
          },
          tick: {
            set: entity => {
              inMemoryStore.tick->IO.InMemoryStore.Tick.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(tick) with ID ${id}.`),
            getPool: tick => {
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(tick.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`Tick pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdateTick entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of Tick is undefined.",
                  ),
                )
              }
            },
          },
          tickDayData: {
            set: entity => {
              inMemoryStore.tickDayData->IO.InMemoryStore.TickDayData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(tickDayData) with ID ${id}.`,
              ),
            getPool: tickDayData => {
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(tickDayData.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`TickDayData pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdateTickDayData entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of TickDayData is undefined.",
                  ),
                )
              }
            },
            getTick: tickDayData => {
              let optTick = inMemoryStore.tick->IO.InMemoryStore.Tick.get(tickDayData.tick_id)
              switch optTick {
              | Some(tick) => tick
              | None =>
                Logging.warn(`TickDayData tick data not found. Loading associated tick from database.
Please consider loading the tick in the UpdateTickDayData entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of TickDayData is undefined.",
                  ),
                )
              }
            },
          },
          tickHourData: {
            set: entity => {
              inMemoryStore.tickHourData->IO.InMemoryStore.TickHourData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(tickHourData) with ID ${id}.`,
              ),
            getTick: tickHourData => {
              let optTick = inMemoryStore.tick->IO.InMemoryStore.Tick.get(tickHourData.tick_id)
              switch optTick {
              | Some(tick) => tick
              | None =>
                Logging.warn(`TickHourData tick data not found. Loading associated tick from database.
Please consider loading the tick in the UpdateTickHourData entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of TickHourData is undefined.",
                  ),
                )
              }
            },
            getPool: tickHourData => {
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(tickHourData.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`TickHourData pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdateTickHourData entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of TickHourData is undefined.",
                  ),
                )
              }
            },
          },
          token: {
            set: entity => {
              inMemoryStore.token->IO.InMemoryStore.Token.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(token) with ID ${id}.`),
            get: (id: Types.id) => {
              if optSetOfIds_token->Set.has(id) {
                inMemoryStore.token->IO.InMemoryStore.Token.get(id)
              } else {
                Logging.warn(
                  `The loader for a "Token" of entity with id "${id}" was not used please add it to your default loader function (ie. place 'context.token.load("${id}")' inside your loader) to avoid unexpected behaviour. This is a runtime validation check.`,
                )

                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                inMemoryStore.token->IO.InMemoryStore.Token.get(id)

                // TODO: add a further step to synchronously try fetch this from the DB if it isn't in the in-memory store - similar to this PR: https://github.com/Float-Capital/indexer/pull/759
              }
            },
          },
          tokenDayData: {
            set: entity => {
              inMemoryStore.tokenDayData->IO.InMemoryStore.TokenDayData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(tokenDayData) with ID ${id}.`,
              ),
            getToken: tokenDayData => {
              let optToken = inMemoryStore.token->IO.InMemoryStore.Token.get(tokenDayData.token_id)
              switch optToken {
              | Some(token) => token
              | None =>
                Logging.warn(`TokenDayData token data not found. Loading associated token from database.
Please consider loading the token in the UpdateTokenDayData entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of TokenDayData is undefined.",
                  ),
                )
              }
            },
          },
          tokenHourData: {
            set: entity => {
              inMemoryStore.tokenHourData->IO.InMemoryStore.TokenHourData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(tokenHourData) with ID ${id}.`,
              ),
            getToken: tokenHourData => {
              let optToken = inMemoryStore.token->IO.InMemoryStore.Token.get(tokenHourData.token_id)
              switch optToken {
              | Some(token) => token
              | None =>
                Logging.warn(`TokenHourData token data not found. Loading associated token from database.
Please consider loading the token in the UpdateTokenHourData entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of TokenHourData is undefined.",
                  ),
                )
              }
            },
          },
          tokenPoolWhitelist: {
            set: entity => {
              inMemoryStore.tokenPoolWhitelist->IO.InMemoryStore.TokenPoolWhitelist.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(tokenPoolWhitelist) with ID ${id}.`,
              ),
            getToken: tokenPoolWhitelist => {
              let optToken =
                inMemoryStore.token->IO.InMemoryStore.Token.get(tokenPoolWhitelist.token_id)
              switch optToken {
              | Some(token) => token
              | None =>
                Logging.warn(`TokenPoolWhitelist token data not found. Loading associated token from database.
Please consider loading the token in the UpdateTokenPoolWhitelist entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of TokenPoolWhitelist is undefined.",
                  ),
                )
              }
            },
            getPool: tokenPoolWhitelist => {
              let optPool =
                inMemoryStore.pool->IO.InMemoryStore.Pool.get(tokenPoolWhitelist.pool_id)
              switch optPool {
              | Some(pool) => pool
              | None =>
                Logging.warn(`TokenPoolWhitelist pool data not found. Loading associated pool from database.
Please consider loading the pool in the UpdateTokenPoolWhitelist entity loader to greatly improve sync speed of your application.
`)

                raise(
                  LinkedEntityNotAvailableInSyncHandler(
                    "The required linked entity of TokenPoolWhitelist is undefined.",
                  ),
                )
              }
            },
          },
          transaction: {
            set: entity => {
              inMemoryStore.transaction->IO.InMemoryStore.Transaction.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(transaction) with ID ${id}.`,
              ),
          },
          uniswapDayData: {
            set: entity => {
              inMemoryStore.uniswapDayData->IO.InMemoryStore.UniswapDayData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(uniswapDayData) with ID ${id}.`,
              ),
          },
        }
      }

      let getHandlerContextAsync = (): handlerContextAsync => {
        {
          log: contextLogger,
          bundle: {
            set: entity => {
              inMemoryStore.bundle->IO.InMemoryStore.Bundle.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(bundle) with ID ${id}.`),
          },
          burn: {
            set: entity => {
              inMemoryStore.burn->IO.InMemoryStore.Burn.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(burn) with ID ${id}.`),
            getTransaction: async burn => {
              let transaction_field = burn.transaction_id
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(transaction_field)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                let entities = await asyncGetters.getTransaction(transaction_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Transaction.set(
                    inMemoryStore.transaction,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Burn transaction data not found. Loading associated transaction from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity transaction of Burn is undefined.",
                    ),
                  )
                }
              }
            },
            getToken0: async burn => {
              let token0_field = burn.token0_id
              let optToken0 = inMemoryStore.token->IO.InMemoryStore.Token.get(token0_field)
              switch optToken0 {
              | Some(token0) => token0
              | None =>
                let entities = await asyncGetters.getToken(token0_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Burn token0 data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token0 of Burn is undefined.",
                    ),
                  )
                }
              }
            },
            getPool: async burn => {
              let pool_field = burn.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Burn pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of Burn is undefined.",
                    ),
                  )
                }
              }
            },
            getToken1: async burn => {
              let token1_field = burn.token1_id
              let optToken1 = inMemoryStore.token->IO.InMemoryStore.Token.get(token1_field)
              switch optToken1 {
              | Some(token1) => token1
              | None =>
                let entities = await asyncGetters.getToken(token1_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Burn token1 data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token1 of Burn is undefined.",
                    ),
                  )
                }
              }
            },
          },
          collect: {
            set: entity => {
              inMemoryStore.collect->IO.InMemoryStore.Collect.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(collect) with ID ${id}.`),
            getTransaction: async collect => {
              let transaction_field = collect.transaction_id
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(transaction_field)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                let entities = await asyncGetters.getTransaction(transaction_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Transaction.set(
                    inMemoryStore.transaction,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Collect transaction data not found. Loading associated transaction from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity transaction of Collect is undefined.",
                    ),
                  )
                }
              }
            },
            getPool: async collect => {
              let pool_field = collect.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Collect pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of Collect is undefined.",
                    ),
                  )
                }
              }
            },
          },
          factory: {
            set: entity => {
              inMemoryStore.factory->IO.InMemoryStore.Factory.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(factory) with ID ${id}.`),
          },
          flash: {
            set: entity => {
              inMemoryStore.flash->IO.InMemoryStore.Flash.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(flash) with ID ${id}.`),
            getPool: async flash => {
              let pool_field = flash.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Flash pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of Flash is undefined.",
                    ),
                  )
                }
              }
            },
            getTransaction: async flash => {
              let transaction_field = flash.transaction_id
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(transaction_field)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                let entities = await asyncGetters.getTransaction(transaction_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Transaction.set(
                    inMemoryStore.transaction,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Flash transaction data not found. Loading associated transaction from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity transaction of Flash is undefined.",
                    ),
                  )
                }
              }
            },
          },
          mint: {
            set: entity => {
              inMemoryStore.mint->IO.InMemoryStore.Mint.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(mint) with ID ${id}.`),
            getToken0: async mint => {
              let token0_field = mint.token0_id
              let optToken0 = inMemoryStore.token->IO.InMemoryStore.Token.get(token0_field)
              switch optToken0 {
              | Some(token0) => token0
              | None =>
                let entities = await asyncGetters.getToken(token0_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Mint token0 data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token0 of Mint is undefined.",
                    ),
                  )
                }
              }
            },
            getTransaction: async mint => {
              let transaction_field = mint.transaction_id
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(transaction_field)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                let entities = await asyncGetters.getTransaction(transaction_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Transaction.set(
                    inMemoryStore.transaction,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Mint transaction data not found. Loading associated transaction from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity transaction of Mint is undefined.",
                    ),
                  )
                }
              }
            },
            getPool: async mint => {
              let pool_field = mint.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Mint pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of Mint is undefined.",
                    ),
                  )
                }
              }
            },
            getToken1: async mint => {
              let token1_field = mint.token1_id
              let optToken1 = inMemoryStore.token->IO.InMemoryStore.Token.get(token1_field)
              switch optToken1 {
              | Some(token1) => token1
              | None =>
                let entities = await asyncGetters.getToken(token1_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Mint token1 data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token1 of Mint is undefined.",
                    ),
                  )
                }
              }
            },
          },
          pool: {
            set: entity => {
              inMemoryStore.pool->IO.InMemoryStore.Pool.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(pool) with ID ${id}.`),
            getToken1: async pool => {
              let token1_field = pool.token1_id
              let optToken1 = inMemoryStore.token->IO.InMemoryStore.Token.get(token1_field)
              switch optToken1 {
              | Some(token1) => token1
              | None =>
                let entities = await asyncGetters.getToken(token1_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Pool token1 data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token1 of Pool is undefined.",
                    ),
                  )
                }
              }
            },
            getToken0: async pool => {
              let token0_field = pool.token0_id
              let optToken0 = inMemoryStore.token->IO.InMemoryStore.Token.get(token0_field)
              switch optToken0 {
              | Some(token0) => token0
              | None =>
                let entities = await asyncGetters.getToken(token0_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Pool token0 data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token0 of Pool is undefined.",
                    ),
                  )
                }
              }
            },
          },
          poolDayData: {
            set: entity => {
              inMemoryStore.poolDayData->IO.InMemoryStore.PoolDayData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(poolDayData) with ID ${id}.`,
              ),
            getPool: async poolDayData => {
              let pool_field = poolDayData.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`PoolDayData pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of PoolDayData is undefined.",
                    ),
                  )
                }
              }
            },
          },
          poolHourData: {
            set: entity => {
              inMemoryStore.poolHourData->IO.InMemoryStore.PoolHourData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(poolHourData) with ID ${id}.`,
              ),
            getPool: async poolHourData => {
              let pool_field = poolHourData.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`PoolHourData pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of PoolHourData is undefined.",
                    ),
                  )
                }
              }
            },
          },
          position: {
            set: entity => {
              inMemoryStore.position->IO.InMemoryStore.Position.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(position) with ID ${id}.`),
            getToken1: async position => {
              let token1_field = position.token1_id
              let optToken1 = inMemoryStore.token->IO.InMemoryStore.Token.get(token1_field)
              switch optToken1 {
              | Some(token1) => token1
              | None =>
                let entities = await asyncGetters.getToken(token1_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Position token1 data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token1 of Position is undefined.",
                    ),
                  )
                }
              }
            },
            getToken0: async position => {
              let token0_field = position.token0_id
              let optToken0 = inMemoryStore.token->IO.InMemoryStore.Token.get(token0_field)
              switch optToken0 {
              | Some(token0) => token0
              | None =>
                let entities = await asyncGetters.getToken(token0_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Position token0 data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token0 of Position is undefined.",
                    ),
                  )
                }
              }
            },
            getTickLower: async position => {
              let tickLower_field = position.tickLower_id
              let optTickLower = inMemoryStore.tick->IO.InMemoryStore.Tick.get(tickLower_field)
              switch optTickLower {
              | Some(tickLower) => tickLower
              | None =>
                let entities = await asyncGetters.getTick(tickLower_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Tick.set(
                    inMemoryStore.tick,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Position tickLower data not found. Loading associated tick from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity tickLower of Position is undefined.",
                    ),
                  )
                }
              }
            },
            getTransaction: async position => {
              let transaction_field = position.transaction_id
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(transaction_field)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                let entities = await asyncGetters.getTransaction(transaction_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Transaction.set(
                    inMemoryStore.transaction,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Position transaction data not found. Loading associated transaction from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity transaction of Position is undefined.",
                    ),
                  )
                }
              }
            },
            getPool: async position => {
              let pool_field = position.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Position pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of Position is undefined.",
                    ),
                  )
                }
              }
            },
            getTickUpper: async position => {
              let tickUpper_field = position.tickUpper_id
              let optTickUpper = inMemoryStore.tick->IO.InMemoryStore.Tick.get(tickUpper_field)
              switch optTickUpper {
              | Some(tickUpper) => tickUpper
              | None =>
                let entities = await asyncGetters.getTick(tickUpper_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Tick.set(
                    inMemoryStore.tick,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Position tickUpper data not found. Loading associated tick from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity tickUpper of Position is undefined.",
                    ),
                  )
                }
              }
            },
          },
          positionSnapshot: {
            set: entity => {
              inMemoryStore.positionSnapshot->IO.InMemoryStore.PositionSnapshot.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(positionSnapshot) with ID ${id}.`,
              ),
            getPool: async positionSnapshot => {
              let pool_field = positionSnapshot.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`PositionSnapshot pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of PositionSnapshot is undefined.",
                    ),
                  )
                }
              }
            },
            getPosition: async positionSnapshot => {
              let position_field = positionSnapshot.position_id
              let optPosition =
                inMemoryStore.position->IO.InMemoryStore.Position.get(position_field)
              switch optPosition {
              | Some(position) => position
              | None =>
                let entities = await asyncGetters.getPosition(position_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Position.set(
                    inMemoryStore.position,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`PositionSnapshot position data not found. Loading associated position from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity position of PositionSnapshot is undefined.",
                    ),
                  )
                }
              }
            },
            getTransaction: async positionSnapshot => {
              let transaction_field = positionSnapshot.transaction_id
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(transaction_field)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                let entities = await asyncGetters.getTransaction(transaction_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Transaction.set(
                    inMemoryStore.transaction,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`PositionSnapshot transaction data not found. Loading associated transaction from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity transaction of PositionSnapshot is undefined.",
                    ),
                  )
                }
              }
            },
          },
          swap: {
            set: entity => {
              inMemoryStore.swap->IO.InMemoryStore.Swap.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(swap) with ID ${id}.`),
            get: async (id: Types.id) => {
              if optSetOfIds_swap->Set.has(id) {
                inMemoryStore.swap->IO.InMemoryStore.Swap.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.swap->IO.InMemoryStore.Swap.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getSwap(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Swap.set(
                      inMemoryStore.swap,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    Some(entity)
                  | None => None
                  }
                }
              }
            },
            getTick: async swap => {
              let tick_field = swap.tick_id
              let optTick = inMemoryStore.tick->IO.InMemoryStore.Tick.get(tick_field)
              switch optTick {
              | Some(tick) => tick
              | None =>
                let entities = await asyncGetters.getTick(tick_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Tick.set(
                    inMemoryStore.tick,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Swap tick data not found. Loading associated tick from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity tick of Swap is undefined.",
                    ),
                  )
                }
              }
            },
            getTransaction: async swap => {
              let transaction_field = swap.transaction_id
              let optTransaction =
                inMemoryStore.transaction->IO.InMemoryStore.Transaction.get(transaction_field)
              switch optTransaction {
              | Some(transaction) => transaction
              | None =>
                let entities = await asyncGetters.getTransaction(transaction_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Transaction.set(
                    inMemoryStore.transaction,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Swap transaction data not found. Loading associated transaction from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity transaction of Swap is undefined.",
                    ),
                  )
                }
              }
            },
            getToken1: async swap => {
              let token1_field = swap.token1_id
              let optToken1 = inMemoryStore.token->IO.InMemoryStore.Token.get(token1_field)
              switch optToken1 {
              | Some(token1) => token1
              | None =>
                let entities = await asyncGetters.getToken(token1_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Swap token1 data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token1 of Swap is undefined.",
                    ),
                  )
                }
              }
            },
            getToken0: async swap => {
              let token0_field = swap.token0_id
              let optToken0 = inMemoryStore.token->IO.InMemoryStore.Token.get(token0_field)
              switch optToken0 {
              | Some(token0) => token0
              | None =>
                let entities = await asyncGetters.getToken(token0_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Swap token0 data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token0 of Swap is undefined.",
                    ),
                  )
                }
              }
            },
            getPool: async swap => {
              let pool_field = swap.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Swap pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of Swap is undefined.",
                    ),
                  )
                }
              }
            },
          },
          tick: {
            set: entity => {
              inMemoryStore.tick->IO.InMemoryStore.Tick.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(tick) with ID ${id}.`),
            getPool: async tick => {
              let pool_field = tick.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`Tick pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of Tick is undefined.",
                    ),
                  )
                }
              }
            },
          },
          tickDayData: {
            set: entity => {
              inMemoryStore.tickDayData->IO.InMemoryStore.TickDayData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(tickDayData) with ID ${id}.`,
              ),
            getPool: async tickDayData => {
              let pool_field = tickDayData.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`TickDayData pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of TickDayData is undefined.",
                    ),
                  )
                }
              }
            },
            getTick: async tickDayData => {
              let tick_field = tickDayData.tick_id
              let optTick = inMemoryStore.tick->IO.InMemoryStore.Tick.get(tick_field)
              switch optTick {
              | Some(tick) => tick
              | None =>
                let entities = await asyncGetters.getTick(tick_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Tick.set(
                    inMemoryStore.tick,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`TickDayData tick data not found. Loading associated tick from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity tick of TickDayData is undefined.",
                    ),
                  )
                }
              }
            },
          },
          tickHourData: {
            set: entity => {
              inMemoryStore.tickHourData->IO.InMemoryStore.TickHourData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(tickHourData) with ID ${id}.`,
              ),
            getTick: async tickHourData => {
              let tick_field = tickHourData.tick_id
              let optTick = inMemoryStore.tick->IO.InMemoryStore.Tick.get(tick_field)
              switch optTick {
              | Some(tick) => tick
              | None =>
                let entities = await asyncGetters.getTick(tick_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Tick.set(
                    inMemoryStore.tick,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`TickHourData tick data not found. Loading associated tick from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity tick of TickHourData is undefined.",
                    ),
                  )
                }
              }
            },
            getPool: async tickHourData => {
              let pool_field = tickHourData.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`TickHourData pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of TickHourData is undefined.",
                    ),
                  )
                }
              }
            },
          },
          token: {
            set: entity => {
              inMemoryStore.token->IO.InMemoryStore.Token.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(`[unimplemented delete] can't delete entity(token) with ID ${id}.`),
            get: async (id: Types.id) => {
              if optSetOfIds_token->Set.has(id) {
                inMemoryStore.token->IO.InMemoryStore.Token.get(id)
              } else {
                // NOTE: this will still return the value if it exists in the in-memory store (despite the loader not being run).
                switch inMemoryStore.token->IO.InMemoryStore.Token.get(id) {
                | Some(entity) => Some(entity)
                | None =>
                  let entities = await asyncGetters.getToken(id)

                  switch entities->Belt.Array.get(0) {
                  | Some(entity) =>
                    // TODO: make this work with the test framework too.
                    IO.InMemoryStore.Token.set(
                      inMemoryStore.token,
                      ~key=entity.id,
                      ~dbOp=Types.Read,
                      ~entity,
                    )
                    Some(entity)
                  | None => None
                  }
                }
              }
            },
          },
          tokenDayData: {
            set: entity => {
              inMemoryStore.tokenDayData->IO.InMemoryStore.TokenDayData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(tokenDayData) with ID ${id}.`,
              ),
            getToken: async tokenDayData => {
              let token_field = tokenDayData.token_id
              let optToken = inMemoryStore.token->IO.InMemoryStore.Token.get(token_field)
              switch optToken {
              | Some(token) => token
              | None =>
                let entities = await asyncGetters.getToken(token_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`TokenDayData token data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token of TokenDayData is undefined.",
                    ),
                  )
                }
              }
            },
          },
          tokenHourData: {
            set: entity => {
              inMemoryStore.tokenHourData->IO.InMemoryStore.TokenHourData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(tokenHourData) with ID ${id}.`,
              ),
            getToken: async tokenHourData => {
              let token_field = tokenHourData.token_id
              let optToken = inMemoryStore.token->IO.InMemoryStore.Token.get(token_field)
              switch optToken {
              | Some(token) => token
              | None =>
                let entities = await asyncGetters.getToken(token_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`TokenHourData token data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token of TokenHourData is undefined.",
                    ),
                  )
                }
              }
            },
          },
          tokenPoolWhitelist: {
            set: entity => {
              inMemoryStore.tokenPoolWhitelist->IO.InMemoryStore.TokenPoolWhitelist.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(tokenPoolWhitelist) with ID ${id}.`,
              ),
            getToken: async tokenPoolWhitelist => {
              let token_field = tokenPoolWhitelist.token_id
              let optToken = inMemoryStore.token->IO.InMemoryStore.Token.get(token_field)
              switch optToken {
              | Some(token) => token
              | None =>
                let entities = await asyncGetters.getToken(token_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Token.set(
                    inMemoryStore.token,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`TokenPoolWhitelist token data not found. Loading associated token from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity token of TokenPoolWhitelist is undefined.",
                    ),
                  )
                }
              }
            },
            getPool: async tokenPoolWhitelist => {
              let pool_field = tokenPoolWhitelist.pool_id
              let optPool = inMemoryStore.pool->IO.InMemoryStore.Pool.get(pool_field)
              switch optPool {
              | Some(pool) => pool
              | None =>
                let entities = await asyncGetters.getPool(pool_field)

                switch entities->Belt.Array.get(0) {
                | Some(entity) =>
                  // TODO: make this work with the test framework too.
                  IO.InMemoryStore.Pool.set(
                    inMemoryStore.pool,
                    ~key=entity.id,
                    ~dbOp=Types.Read,
                    ~entity,
                  )
                  entity
                | None =>
                  Logging.error(`TokenPoolWhitelist pool data not found. Loading associated pool from database.
This is likely due to a database corruption. Please reach out to the team on discord.
`)

                  raise(
                    UnableToLoadNonNullableLinkedEntity(
                      "The required linked entity pool of TokenPoolWhitelist is undefined.",
                    ),
                  )
                }
              }
            },
          },
          transaction: {
            set: entity => {
              inMemoryStore.transaction->IO.InMemoryStore.Transaction.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(transaction) with ID ${id}.`,
              ),
          },
          uniswapDayData: {
            set: entity => {
              inMemoryStore.uniswapDayData->IO.InMemoryStore.UniswapDayData.set(
                ~key=entity.id,
                ~entity,
                ~dbOp=Types.Set,
              )
            },
            delete: id =>
              Logging.warn(
                `[unimplemented delete] can't delete entity(uniswapDayData) with ID ${id}.`,
              ),
          },
        }
      }

      {
        logger,
        log: contextLogger,
        getEntitiesToLoad: () => entitiesToLoad,
        getAddedDynamicContractRegistrations: () => addedDynamicContractRegistrations,
        getLoaderContext: () => loaderContext,
        getHandlerContextSync,
        getHandlerContextAsync,
      }
    }
  }
}

@deriving(accessors)
type eventAndContext =
  | FactoryContract_PoolCreatedWithContext(
      Types.eventLog<Types.FactoryContract.PoolCreatedEvent.eventArgs>,
      FactoryContract.PoolCreatedEvent.context,
    )
  | NonfungiblePositionManagerContract_IncreaseLiquidityWithContext(
      Types.eventLog<Types.NonfungiblePositionManagerContract.IncreaseLiquidityEvent.eventArgs>,
      NonfungiblePositionManagerContract.IncreaseLiquidityEvent.context,
    )
  | NonfungiblePositionManagerContract_DecreaseLiquidityWithContext(
      Types.eventLog<Types.NonfungiblePositionManagerContract.DecreaseLiquidityEvent.eventArgs>,
      NonfungiblePositionManagerContract.DecreaseLiquidityEvent.context,
    )
  | NonfungiblePositionManagerContract_TransferWithContext(
      Types.eventLog<Types.NonfungiblePositionManagerContract.TransferEvent.eventArgs>,
      NonfungiblePositionManagerContract.TransferEvent.context,
    )
  | PoolContract_SwapWithContext(
      Types.eventLog<Types.PoolContract.SwapEvent.eventArgs>,
      PoolContract.SwapEvent.context,
    )

type eventRouterEventAndContext = {
  chainId: int,
  event: eventAndContext,
}
