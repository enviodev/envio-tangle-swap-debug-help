open Belt
RegisterHandlers.registerAllHandlers()

/***** TAKE NOTE ******
This is a hack to get genType to work!

In order for genType to produce recursive types, it needs to be at the 
root module of a file. If it's defined in a nested module it does not 
work. So all the MockDb types and internal functions are defined in TestHelpers_MockDb
and only public functions are recreated and exported from this module.

the following module:
```rescript
module MyModule = {
  @genType
  type rec a = {fieldB: b}
  @genType and b = {fieldA: a}
}
```

produces the following in ts:
```ts
// tslint:disable-next-line:interface-over-type-literal
export type MyModule_a = { readonly fieldB: b };

// tslint:disable-next-line:interface-over-type-literal
export type MyModule_b = { readonly fieldA: MyModule_a };
```

fieldB references type b which doesn't exist because it's defined
as MyModule_b
*/

module MockDb = {
  @genType
  let createMockDb = TestHelpers_MockDb.createMockDb
}

module EventFunctions = {
  //Note these are made into a record to make operate in the same way
  //for Res, JS and TS.

  /**
  The arguements that get passed to a "processEvent" helper function
  */
  @genType
  type eventProcessorArgs<'eventArgs> = {
    event: Types.eventLog<'eventArgs>,
    mockDb: TestHelpers_MockDb.t,
    chainId?: int,
  }

  /**
  The default chain ID to use (ethereum mainnet) if a user does not specify int the 
  eventProcessor helper
  */
  let \"DEFAULT_CHAIN_ID" = 1

  /**
  A function composer to help create individual processEvent functions
  */
  let makeEventProcessor = (
    ~contextCreator: Context.contextCreator<
      'eventArgs,
      'loaderContext,
      'handlerContextSync,
      'handlerContextAsync,
    >,
    ~getLoader,
    ~eventWithContextAccessor: (
      Types.eventLog<'eventArgs>,
      Context.genericContextCreatorFunctions<
        'loaderContext,
        'handlerContextSync,
        'handlerContextAsync,
      >,
    ) => Context.eventAndContext,
    ~eventName: Types.eventName,
    ~cb: TestHelpers_MockDb.t => unit,
  ) => {
    ({event, mockDb, ?chainId}) => {
      //The user can specify a chainId of an event or leave it off
      //and it will default to "DEFAULT_CHAIN_ID"
      let chainId = chainId->Option.getWithDefault(\"DEFAULT_CHAIN_ID")

      //Create an individual logging context for traceability
      let logger = Logging.createChild(
        ~params={
          "Context": `Test Processor for ${eventName
            ->Types.eventName_encode
            ->Js.Json.stringify} Event`,
          "Chain ID": chainId,
          "event": event,
        },
      )

      //Deep copy the data in mockDb, mutate the clone and return the clone
      //So no side effects occur here and state can be compared between process
      //steps
      let mockDbClone = mockDb->TestHelpers_MockDb.cloneMockDb

      let asyncGetters: Context.entityGetters = {
        getBundle: async id =>
          mockDbClone.entities.bundle.get(id)->Belt.Option.mapWithDefault([], entity => [entity]),
        getBurn: async id =>
          mockDbClone.entities.burn.get(id)->Belt.Option.mapWithDefault([], entity => [entity]),
        getCollect: async id =>
          mockDbClone.entities.collect.get(id)->Belt.Option.mapWithDefault([], entity => [entity]),
        getFactory: async id =>
          mockDbClone.entities.factory.get(id)->Belt.Option.mapWithDefault([], entity => [entity]),
        getFlash: async id =>
          mockDbClone.entities.flash.get(id)->Belt.Option.mapWithDefault([], entity => [entity]),
        getMint: async id =>
          mockDbClone.entities.mint.get(id)->Belt.Option.mapWithDefault([], entity => [entity]),
        getPool: async id =>
          mockDbClone.entities.pool.get(id)->Belt.Option.mapWithDefault([], entity => [entity]),
        getPoolDayData: async id =>
          mockDbClone.entities.poolDayData.get(id)->Belt.Option.mapWithDefault([], entity => [
            entity,
          ]),
        getPoolHourData: async id =>
          mockDbClone.entities.poolHourData.get(id)->Belt.Option.mapWithDefault([], entity => [
            entity,
          ]),
        getPosition: async id =>
          mockDbClone.entities.position.get(id)->Belt.Option.mapWithDefault([], entity => [entity]),
        getPositionSnapshot: async id =>
          mockDbClone.entities.positionSnapshot.get(id)->Belt.Option.mapWithDefault([], entity => [
            entity,
          ]),
        getSwap: async id =>
          mockDbClone.entities.swap.get(id)->Belt.Option.mapWithDefault([], entity => [entity]),
        getTick: async id =>
          mockDbClone.entities.tick.get(id)->Belt.Option.mapWithDefault([], entity => [entity]),
        getTickDayData: async id =>
          mockDbClone.entities.tickDayData.get(id)->Belt.Option.mapWithDefault([], entity => [
            entity,
          ]),
        getTickHourData: async id =>
          mockDbClone.entities.tickHourData.get(id)->Belt.Option.mapWithDefault([], entity => [
            entity,
          ]),
        getToken: async id =>
          mockDbClone.entities.token.get(id)->Belt.Option.mapWithDefault([], entity => [entity]),
        getTokenDayData: async id =>
          mockDbClone.entities.tokenDayData.get(id)->Belt.Option.mapWithDefault([], entity => [
            entity,
          ]),
        getTokenHourData: async id =>
          mockDbClone.entities.tokenHourData.get(id)->Belt.Option.mapWithDefault([], entity => [
            entity,
          ]),
        getTokenPoolWhitelist: async id =>
          mockDbClone.entities.tokenPoolWhitelist.get(id)->Belt.Option.mapWithDefault(
            [],
            entity => [entity],
          ),
        getTransaction: async id =>
          mockDbClone.entities.transaction.get(id)->Belt.Option.mapWithDefault([], entity => [
            entity,
          ]),
        getUniswapDayData: async id =>
          mockDbClone.entities.uniswapDayData.get(id)->Belt.Option.mapWithDefault([], entity => [
            entity,
          ]),
      }

      //Construct a new instance of an in memory store to run for the given event
      let inMemoryStore = IO.InMemoryStore.make()

      //Construct a context with the inMemory store for the given event to run
      //loaders and handlers
      let context = contextCreator(~event, ~inMemoryStore, ~chainId, ~logger, ~asyncGetters)

      let loaderContext = context.getLoaderContext()

      let loader = getLoader()

      //Run the loader, to get all the read values/contract registrations
      //into the context
      loader(~event, ~context=loaderContext)

      //Get all the entities are requested to be loaded from the mockDB
      let entityBatch = context.getEntitiesToLoad()

      //Load requested entities from the cloned mockDb into the inMemoryStore
      mockDbClone->TestHelpers_MockDb.loadEntitiesToInMemStore(~entityBatch, ~inMemoryStore)

      //Run the event and handler context through the eventRouter
      //With inMemoryStore
      let eventAndContext: Context.eventRouterEventAndContext = {
        chainId,
        event: eventWithContextAccessor(event, context),
      }

      eventAndContext->EventProcessing.eventRouter(~inMemoryStore, ~cb=res =>
        switch res {
        | Ok() =>
          //Now that the processing is finished. Simulate writing a batch
          //(Although in this case a batch of 1 event only) to the cloned mockDb
          mockDbClone->TestHelpers_MockDb.writeFromMemoryStore(~inMemoryStore)

          //Return the cloned mock db
          cb(mockDbClone)

        | Error(errHandler) =>
          errHandler->ErrorHandling.log
          errHandler->ErrorHandling.raiseExn
        }
      )
    }
  }

  /**Creates a mock event processor, wrapping the callback in a Promise for async use*/
  let makeAsyncEventProcessor = (
    ~contextCreator,
    ~getLoader,
    ~eventWithContextAccessor,
    ~eventName,
    eventProcessorArgs,
  ) => {
    Promise.make((res, _rej) => {
      makeEventProcessor(
        ~contextCreator,
        ~getLoader,
        ~eventWithContextAccessor,
        ~eventName,
        ~cb=mockDb => res(. mockDb),
        eventProcessorArgs,
      )
    })
  }

  /**
  Creates a mock event processor, exposing the return of the callback in the return,
  raises an exception if the handler is async
  */
  let makeSyncEventProcessor = (
    ~contextCreator,
    ~getLoader,
    ~eventWithContextAccessor,
    ~eventName,
    eventProcessorArgs,
  ) => {
    //Dangerously set to None, nextMockDb will be set in the callback
    let nextMockDb = ref(None)
    makeEventProcessor(
      ~contextCreator,
      ~getLoader,
      ~eventWithContextAccessor,
      ~eventName,
      ~cb=mockDb => nextMockDb := Some(mockDb),
      eventProcessorArgs,
    )

    //The callback is called synchronously so nextMockDb should be set.
    //In the case it's not set it would mean that the user is using an async handler
    //in which case we want to error and alert the user.
    switch nextMockDb.contents {
    | Some(mockDb) => mockDb
    | None =>
      Js.Exn.raiseError(
        "processEvent failed because handler is not synchronous, please use processEventAsync instead",
      )
    }
  }

  /**
  Optional params for all additional data related to an eventLog
  */
  @genType
  type mockEventData = {
    blockNumber?: int,
    blockTimestamp?: int,
    blockHash?: string,
    chainId?: int,
    srcAddress?: Ethers.ethAddress,
    transactionHash?: string,
    transactionIndex?: int,
    txOrigin?: option<Ethers.ethAddress>,
    logIndex?: int,
  }

  /**
  Applies optional paramters with defaults for all common eventLog field
  */
  let makeEventMocker = (
    ~params: 'eventParams,
    ~mockEventData: option<mockEventData>,
  ): Types.eventLog<'eventParams> => {
    let {
      ?blockNumber,
      ?blockTimestamp,
      ?blockHash,
      ?srcAddress,
      ?chainId,
      ?transactionHash,
      ?transactionIndex,
      ?logIndex,
      ?txOrigin,
    } =
      mockEventData->Belt.Option.getWithDefault({})

    {
      params,
      txOrigin: txOrigin->Belt.Option.flatMap(i => i),
      chainId: chainId->Belt.Option.getWithDefault(1),
      blockNumber: blockNumber->Belt.Option.getWithDefault(0),
      blockTimestamp: blockTimestamp->Belt.Option.getWithDefault(0),
      blockHash: blockHash->Belt.Option.getWithDefault(Ethers.Constants.zeroHash),
      srcAddress: srcAddress->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
      transactionHash: transactionHash->Belt.Option.getWithDefault(Ethers.Constants.zeroHash),
      transactionIndex: transactionIndex->Belt.Option.getWithDefault(0),
      logIndex: logIndex->Belt.Option.getWithDefault(0),
    }
  }
}

module Factory = {
  module PoolCreated = {
    @genType
    let processEvent = EventFunctions.makeSyncEventProcessor(
      ~contextCreator=Context.FactoryContract.PoolCreatedEvent.contextCreator,
      ~getLoader=Handlers.FactoryContract.PoolCreated.getLoader,
      ~eventWithContextAccessor=Context.factoryContract_PoolCreatedWithContext,
      ~eventName=Types.Factory_PoolCreated,
    )

    @genType
    let processEventAsync = EventFunctions.makeAsyncEventProcessor(
      ~contextCreator=Context.FactoryContract.PoolCreatedEvent.contextCreator,
      ~getLoader=Handlers.FactoryContract.PoolCreated.getLoader,
      ~eventWithContextAccessor=Context.factoryContract_PoolCreatedWithContext,
      ~eventName=Types.Factory_PoolCreated,
    )

    @genType
    type createMockArgs = {
      token0?: Ethers.ethAddress,
      token1?: Ethers.ethAddress,
      fee?: Ethers.BigInt.t,
      tickSpacing?: Ethers.BigInt.t,
      pool?: Ethers.ethAddress,
      mockEventData?: EventFunctions.mockEventData,
    }

    @genType
    let createMockEvent = args => {
      let {?token0, ?token1, ?fee, ?tickSpacing, ?pool, ?mockEventData} = args

      let params: Types.FactoryContract.PoolCreatedEvent.eventArgs = {
        token0: token0->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
        token1: token1->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
        fee: fee->Belt.Option.getWithDefault(Ethers.BigInt.zero),
        tickSpacing: tickSpacing->Belt.Option.getWithDefault(Ethers.BigInt.zero),
        pool: pool->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
      }

      EventFunctions.makeEventMocker(~params, ~mockEventData)
    }
  }
}

module NonfungiblePositionManager = {
  module IncreaseLiquidity = {
    @genType
    let processEvent = EventFunctions.makeSyncEventProcessor(
      ~contextCreator=Context.NonfungiblePositionManagerContract.IncreaseLiquidityEvent.contextCreator,
      ~getLoader=Handlers.NonfungiblePositionManagerContract.IncreaseLiquidity.getLoader,
      ~eventWithContextAccessor=Context.nonfungiblePositionManagerContract_IncreaseLiquidityWithContext,
      ~eventName=Types.NonfungiblePositionManager_IncreaseLiquidity,
    )

    @genType
    let processEventAsync = EventFunctions.makeAsyncEventProcessor(
      ~contextCreator=Context.NonfungiblePositionManagerContract.IncreaseLiquidityEvent.contextCreator,
      ~getLoader=Handlers.NonfungiblePositionManagerContract.IncreaseLiquidity.getLoader,
      ~eventWithContextAccessor=Context.nonfungiblePositionManagerContract_IncreaseLiquidityWithContext,
      ~eventName=Types.NonfungiblePositionManager_IncreaseLiquidity,
    )

    @genType
    type createMockArgs = {
      tokenId?: Ethers.BigInt.t,
      liquidity?: Ethers.BigInt.t,
      amount0?: Ethers.BigInt.t,
      amount1?: Ethers.BigInt.t,
      mockEventData?: EventFunctions.mockEventData,
    }

    @genType
    let createMockEvent = args => {
      let {?tokenId, ?liquidity, ?amount0, ?amount1, ?mockEventData} = args

      let params: Types.NonfungiblePositionManagerContract.IncreaseLiquidityEvent.eventArgs = {
        tokenId: tokenId->Belt.Option.getWithDefault(Ethers.BigInt.zero),
        liquidity: liquidity->Belt.Option.getWithDefault(Ethers.BigInt.zero),
        amount0: amount0->Belt.Option.getWithDefault(Ethers.BigInt.zero),
        amount1: amount1->Belt.Option.getWithDefault(Ethers.BigInt.zero),
      }

      EventFunctions.makeEventMocker(~params, ~mockEventData)
    }
  }

  module DecreaseLiquidity = {
    @genType
    let processEvent = EventFunctions.makeSyncEventProcessor(
      ~contextCreator=Context.NonfungiblePositionManagerContract.DecreaseLiquidityEvent.contextCreator,
      ~getLoader=Handlers.NonfungiblePositionManagerContract.DecreaseLiquidity.getLoader,
      ~eventWithContextAccessor=Context.nonfungiblePositionManagerContract_DecreaseLiquidityWithContext,
      ~eventName=Types.NonfungiblePositionManager_DecreaseLiquidity,
    )

    @genType
    let processEventAsync = EventFunctions.makeAsyncEventProcessor(
      ~contextCreator=Context.NonfungiblePositionManagerContract.DecreaseLiquidityEvent.contextCreator,
      ~getLoader=Handlers.NonfungiblePositionManagerContract.DecreaseLiquidity.getLoader,
      ~eventWithContextAccessor=Context.nonfungiblePositionManagerContract_DecreaseLiquidityWithContext,
      ~eventName=Types.NonfungiblePositionManager_DecreaseLiquidity,
    )

    @genType
    type createMockArgs = {
      tokenId?: Ethers.BigInt.t,
      liquidity?: Ethers.BigInt.t,
      amount0?: Ethers.BigInt.t,
      amount1?: Ethers.BigInt.t,
      mockEventData?: EventFunctions.mockEventData,
    }

    @genType
    let createMockEvent = args => {
      let {?tokenId, ?liquidity, ?amount0, ?amount1, ?mockEventData} = args

      let params: Types.NonfungiblePositionManagerContract.DecreaseLiquidityEvent.eventArgs = {
        tokenId: tokenId->Belt.Option.getWithDefault(Ethers.BigInt.zero),
        liquidity: liquidity->Belt.Option.getWithDefault(Ethers.BigInt.zero),
        amount0: amount0->Belt.Option.getWithDefault(Ethers.BigInt.zero),
        amount1: amount1->Belt.Option.getWithDefault(Ethers.BigInt.zero),
      }

      EventFunctions.makeEventMocker(~params, ~mockEventData)
    }
  }

  module Transfer = {
    @genType
    let processEvent = EventFunctions.makeSyncEventProcessor(
      ~contextCreator=Context.NonfungiblePositionManagerContract.TransferEvent.contextCreator,
      ~getLoader=Handlers.NonfungiblePositionManagerContract.Transfer.getLoader,
      ~eventWithContextAccessor=Context.nonfungiblePositionManagerContract_TransferWithContext,
      ~eventName=Types.NonfungiblePositionManager_Transfer,
    )

    @genType
    let processEventAsync = EventFunctions.makeAsyncEventProcessor(
      ~contextCreator=Context.NonfungiblePositionManagerContract.TransferEvent.contextCreator,
      ~getLoader=Handlers.NonfungiblePositionManagerContract.Transfer.getLoader,
      ~eventWithContextAccessor=Context.nonfungiblePositionManagerContract_TransferWithContext,
      ~eventName=Types.NonfungiblePositionManager_Transfer,
    )

    @genType
    type createMockArgs = {
      from?: Ethers.ethAddress,
      to?: Ethers.ethAddress,
      tokenId?: Ethers.BigInt.t,
      mockEventData?: EventFunctions.mockEventData,
    }

    @genType
    let createMockEvent = args => {
      let {?from, ?to, ?tokenId, ?mockEventData} = args

      let params: Types.NonfungiblePositionManagerContract.TransferEvent.eventArgs = {
        from: from->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
        to: to->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
        tokenId: tokenId->Belt.Option.getWithDefault(Ethers.BigInt.zero),
      }

      EventFunctions.makeEventMocker(~params, ~mockEventData)
    }
  }
}

module Pool = {
  module Swap = {
    @genType
    let processEvent = EventFunctions.makeSyncEventProcessor(
      ~contextCreator=Context.PoolContract.SwapEvent.contextCreator,
      ~getLoader=Handlers.PoolContract.Swap.getLoader,
      ~eventWithContextAccessor=Context.poolContract_SwapWithContext,
      ~eventName=Types.Pool_Swap,
    )

    @genType
    let processEventAsync = EventFunctions.makeAsyncEventProcessor(
      ~contextCreator=Context.PoolContract.SwapEvent.contextCreator,
      ~getLoader=Handlers.PoolContract.Swap.getLoader,
      ~eventWithContextAccessor=Context.poolContract_SwapWithContext,
      ~eventName=Types.Pool_Swap,
    )

    @genType
    type createMockArgs = {
      sender?: Ethers.ethAddress,
      recipient?: Ethers.ethAddress,
      amount0?: Ethers.BigInt.t,
      amount1?: Ethers.BigInt.t,
      sqrtPriceX96?: Ethers.BigInt.t,
      liquidity?: Ethers.BigInt.t,
      tick?: Ethers.BigInt.t,
      mockEventData?: EventFunctions.mockEventData,
    }

    @genType
    let createMockEvent = args => {
      let {
        ?sender,
        ?recipient,
        ?amount0,
        ?amount1,
        ?sqrtPriceX96,
        ?liquidity,
        ?tick,
        ?mockEventData,
      } = args

      let params: Types.PoolContract.SwapEvent.eventArgs = {
        sender: sender->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
        recipient: recipient->Belt.Option.getWithDefault(Ethers.Addresses.defaultAddress),
        amount0: amount0->Belt.Option.getWithDefault(Ethers.BigInt.zero),
        amount1: amount1->Belt.Option.getWithDefault(Ethers.BigInt.zero),
        sqrtPriceX96: sqrtPriceX96->Belt.Option.getWithDefault(Ethers.BigInt.zero),
        liquidity: liquidity->Belt.Option.getWithDefault(Ethers.BigInt.zero),
        tick: tick->Belt.Option.getWithDefault(Ethers.BigInt.zero),
      }

      EventFunctions.makeEventMocker(~params, ~mockEventData)
    }
  }
}
