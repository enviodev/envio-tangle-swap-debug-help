open Belt

let addEventToRawEvents = (
  event: Types.eventLog<'a>,
  ~inMemoryStore: IO.InMemoryStore.t,
  ~chainId,
  ~jsonSerializedParams: Js.Json.t,
  ~eventName: Types.eventName,
) => {
  let {
    blockNumber,
    logIndex,
    transactionIndex,
    transactionHash,
    srcAddress,
    blockHash,
    blockTimestamp,
  } = event

  let eventId = EventUtils.packEventIndex(~logIndex, ~blockNumber)
  let rawEvent: Types.rawEventsEntity = {
    chainId,
    eventId: eventId->Ethers.BigInt.toString,
    blockNumber,
    logIndex,
    transactionIndex,
    transactionHash,
    srcAddress,
    blockHash,
    blockTimestamp,
    eventType: eventName->Types.eventName_encode,
    params: jsonSerializedParams->Js.Json.stringify,
  }

  let eventIdStr = eventId->Ethers.BigInt.toString

  inMemoryStore.rawEvents->IO.InMemoryStore.RawEvents.set(
    ~key={chainId, eventId: eventIdStr},
    ~entity=rawEvent,
    ~dbOp=Set,
  )
}

let updateEventSyncState = (
  event: Types.eventLog<'a>,
  ~chainId,
  ~inMemoryStore: IO.InMemoryStore.t,
) => {
  let {blockNumber, logIndex, transactionIndex, blockTimestamp} = event
  let _ = inMemoryStore.eventSyncState->IO.InMemoryStore.EventSyncState.set(
    ~key=chainId,
    ~entity={
      chainId,
      blockTimestamp,
      blockNumber,
      logIndex,
      transactionIndex,
    },
    ~dbOp=Set,
  )
}

/** Function composer for handling an event*/
let handleEvent = (
  ~inMemoryStore,
  ~chainId,
  ~serializer,
  ~context: Context.genericContextCreatorFunctions<'b, 'c, 'd>,
  ~handlerWithContextGetter: Handlers.handlerWithContextGetterSyncAsync<'a, 'b, 'c, 'd>,
  ~event,
  ~eventName,
  ~cb,
) => {
  event->updateEventSyncState(~chainId, ~inMemoryStore)

  let jsonSerializedParams = event.params->serializer

  event->addEventToRawEvents(~inMemoryStore, ~chainId, ~jsonSerializedParams, ~eventName)

  let makeErr = ErrorHandling.make(
    ~msg="Event Handler failed, please fix the error to keep the indexer running smoothly",
    ~logger=context.logger,
  )

  switch handlerWithContextGetter {
  | Sync({handler, contextGetter}) =>
    //Call the context getter here, ensures no stale values in the context
    //Since loaders and previous handlers have already run
    let handlerContext = contextGetter(context)
    switch handler(~event, ~context=handlerContext) {
    | exception exn => Error(makeErr(exn))
    | () => Ok()
    }->cb
  | Async({handler, contextGetter}) =>
    //Call the context getter here, ensures no stale values in the context
    //Since loaders and previous handlers have already run
    let handlerContext = contextGetter(context)
    handler(~event, ~context=handlerContext)
    ->Promise.thenResolve(_ => cb(Ok()))
    ->Promise.catch(exn => {
      cb(Error(makeErr(exn)))
      Promise.resolve()
    })
    ->ignore
  }
}

let eventRouter = (item: Context.eventRouterEventAndContext, ~inMemoryStore, ~cb) => {
  let {event, chainId} = item

  switch event {
  | FactoryContract_PoolCreatedWithContext(event, context) =>
    handleEvent(
      ~event,
      ~eventName=Factory_PoolCreated,
      ~serializer=Types.FactoryContract.PoolCreatedEvent.eventArgs_encode,
      ~handlerWithContextGetter=Handlers.FactoryContract.PoolCreated.getHandler(),
      ~chainId,
      ~inMemoryStore,
      ~cb,
      ~context,
    )

  | NonfungiblePositionManagerContract_IncreaseLiquidityWithContext(event, context) =>
    handleEvent(
      ~event,
      ~eventName=NonfungiblePositionManager_IncreaseLiquidity,
      ~serializer=Types.NonfungiblePositionManagerContract.IncreaseLiquidityEvent.eventArgs_encode,
      ~handlerWithContextGetter=Handlers.NonfungiblePositionManagerContract.IncreaseLiquidity.getHandler(),
      ~chainId,
      ~inMemoryStore,
      ~cb,
      ~context,
    )

  | NonfungiblePositionManagerContract_DecreaseLiquidityWithContext(event, context) =>
    handleEvent(
      ~event,
      ~eventName=NonfungiblePositionManager_DecreaseLiquidity,
      ~serializer=Types.NonfungiblePositionManagerContract.DecreaseLiquidityEvent.eventArgs_encode,
      ~handlerWithContextGetter=Handlers.NonfungiblePositionManagerContract.DecreaseLiquidity.getHandler(),
      ~chainId,
      ~inMemoryStore,
      ~cb,
      ~context,
    )

  | NonfungiblePositionManagerContract_TransferWithContext(event, context) =>
    handleEvent(
      ~event,
      ~eventName=NonfungiblePositionManager_Transfer,
      ~serializer=Types.NonfungiblePositionManagerContract.TransferEvent.eventArgs_encode,
      ~handlerWithContextGetter=Handlers.NonfungiblePositionManagerContract.Transfer.getHandler(),
      ~chainId,
      ~inMemoryStore,
      ~cb,
      ~context,
    )

  | PoolContract_SwapWithContext(event, context) =>
    handleEvent(
      ~event,
      ~eventName=Pool_Swap,
      ~serializer=Types.PoolContract.SwapEvent.eventArgs_encode,
      ~handlerWithContextGetter=Handlers.PoolContract.Swap.getHandler(),
      ~chainId,
      ~inMemoryStore,
      ~cb,
      ~context,
    )
  }
}

let asyncGetters: Context.entityGetters = {
  getBundle: id => DbFunctions.Bundle.readEntities(DbFunctions.sql, [id]),
  getBurn: id => DbFunctions.Burn.readEntities(DbFunctions.sql, [id]),
  getCollect: id => DbFunctions.Collect.readEntities(DbFunctions.sql, [id]),
  getFactory: id => DbFunctions.Factory.readEntities(DbFunctions.sql, [id]),
  getFlash: id => DbFunctions.Flash.readEntities(DbFunctions.sql, [id]),
  getMint: id => DbFunctions.Mint.readEntities(DbFunctions.sql, [id]),
  getPool: id => DbFunctions.Pool.readEntities(DbFunctions.sql, [id]),
  getPoolDayData: id => DbFunctions.PoolDayData.readEntities(DbFunctions.sql, [id]),
  getPoolHourData: id => DbFunctions.PoolHourData.readEntities(DbFunctions.sql, [id]),
  getPosition: id => DbFunctions.Position.readEntities(DbFunctions.sql, [id]),
  getPositionSnapshot: id => DbFunctions.PositionSnapshot.readEntities(DbFunctions.sql, [id]),
  getSwap: id => DbFunctions.Swap.readEntities(DbFunctions.sql, [id]),
  getTick: id => DbFunctions.Tick.readEntities(DbFunctions.sql, [id]),
  getTickDayData: id => DbFunctions.TickDayData.readEntities(DbFunctions.sql, [id]),
  getTickHourData: id => DbFunctions.TickHourData.readEntities(DbFunctions.sql, [id]),
  getToken: id => DbFunctions.Token.readEntities(DbFunctions.sql, [id]),
  getTokenDayData: id => DbFunctions.TokenDayData.readEntities(DbFunctions.sql, [id]),
  getTokenHourData: id => DbFunctions.TokenHourData.readEntities(DbFunctions.sql, [id]),
  getTokenPoolWhitelist: id => DbFunctions.TokenPoolWhitelist.readEntities(DbFunctions.sql, [id]),
  getTransaction: id => DbFunctions.Transaction.readEntities(DbFunctions.sql, [id]),
  getUniswapDayData: id => DbFunctions.UniswapDayData.readEntities(DbFunctions.sql, [id]),
}

type dynamicContractRegistration = {
  registeringEventBlockNumber: int,
  registeringEventLogIndex: int,
  registeringEventChain: ChainMap.Chain.t,
  dynamicContracts: array<Types.dynamicContractRegistryEntity>,
}

type dynamicContractRegistrations = {
  //Its better to apply these in reverse so that we register them with
  //the fetcher from latest to earliest. That way there are less recursions
  registrationsReversed: list<dynamicContractRegistration>,
  unprocessedBatchReversed: list<Types.eventBatchQueueItem>,
  //Once a single registration happens, the rest of the batches
  //loaders should be run on an isolated in memory store so that
  //they don't affect state of the batch that will be processed
  inMemoryStore: IO.InMemoryStore.t,
}

type loadResponse<'a> = {
  val: 'a,
  dynamicContractRegistrations: option<dynamicContractRegistrations>,
}

type getReadEntitiesRes = loadResponse<
  array<(array<Types.entityRead>, Context.eventRouterEventAndContext)>,
>

/**
Composer for getting entitiesToLoad and dynamicContractRegistrations for a given event
*/
let composeGetReadEntity = (
  ~event: Types.eventLog<_>,
  ~contextCreator,
  ~inMemoryStore,
  ~logger,
  ~asyncGetters,
  ~getLoader,
  ~item: Types.eventBatchQueueItem,
  ~entitiesToLoad,
  ~dynamicContractRegistrations: option<dynamicContractRegistrations>,
  ~eventWithContextAccessor,
  ~checkContractIsRegistered,
): result<getReadEntitiesRes, ErrorHandling.t> => {
  let {chain} = item
  let chainId = chain->ChainMap.Chain.toChainId
  //If there are dynamic contracts, context loader should use the cloned in memory store
  //Otherwise we can use the passed in one
  let inMemoryStore =
    dynamicContractRegistrations->Option.mapWithDefault(inMemoryStore, d => d.inMemoryStore)

  let contextHelper: Context.genericContextCreatorFunctions<_> = contextCreator(
    ~inMemoryStore,
    ~chainId,
    ~event,
    ~logger,
    ~asyncGetters,
  )

  let context = contextHelper.getLoaderContext()

  let loader = getLoader()

  switch loader(~event, ~context) {
  | exception exn =>
    let errorHandler =
      exn->ErrorHandling.make(
        ~msg="Event Loader failed, please fix the error to keep the indexer running smoothly",
        ~logger=contextHelper.logger,
      )
    Error(errorHandler)
  | () =>
    let dynamicContracts = if item.hasRegisteredDynamicContracts->Option.getWithDefault(false) {
      //If an item has already been registered, it would have been
      //put back on the arbitrary events queue and is now being reprocessed
      []
    } else {
      contextHelper.getAddedDynamicContractRegistrations()->Array.keep(({
        contractAddress,
        contractType,
      }) => {
        !checkContractIsRegistered(~chain, ~contractAddress, ~contractName=contractType)
      })
    }

    let addToDynamicContractRegistrations = (
      ~registrationsReversed,
      ~unprocessedBatchReversed,
      ~inMemoryStore,
    ) => {
      //If there are any dynamic contract registrations, put this item in the unprocessedBatch flagged
      //with "hasRegisteredDynamicContracts" and return the same list of entitiesToLoad without the
      //current item
      let unprocessedBatchReversed = list{
        {...item, hasRegisteredDynamicContracts: true},
        ...unprocessedBatchReversed,
      }

      let dynamicContractRegistration = {
        dynamicContracts,
        registeringEventBlockNumber: event.blockNumber,
        registeringEventLogIndex: event.logIndex,
        registeringEventChain: chain,
      }
      let dynamicContractRegistrations = {
        unprocessedBatchReversed,
        registrationsReversed: list{dynamicContractRegistration, ...registrationsReversed},
        inMemoryStore,
      }->Some
      {val: entitiesToLoad, dynamicContractRegistrations}
    }

    switch dynamicContractRegistrations {
    | None =>
      if dynamicContracts->Array.length > 0 {
        //Clone the inMemoryStore
        let inMemoryStoreDeepClone = inMemoryStore->IO.InMemoryStore.clone

        addToDynamicContractRegistrations(
          ~registrationsReversed=list{},
          ~unprocessedBatchReversed=list{},
          ~inMemoryStore=inMemoryStoreDeepClone,
        )
      } else {
        //If there are no dynamic contract registrations, get the entities to load and
        //return a context with the event for the handlers
        let entitiesToLoad = entitiesToLoad->Array.concat([
          (
            contextHelper.getEntitiesToLoad(),
            (
              {
                chainId,
                event: eventWithContextAccessor(event, contextHelper),
              }: Context.eventRouterEventAndContext
            ),
          ),
        ])

        {val: entitiesToLoad, dynamicContractRegistrations: None}
      }
    | Some({unprocessedBatchReversed, registrationsReversed, inMemoryStore}) =>
      if dynamicContracts->Array.length > 0 {
        addToDynamicContractRegistrations(
          ~registrationsReversed,
          ~unprocessedBatchReversed,
          ~inMemoryStore,
        )
      } else {
        let unprocessedBatchReversed = list{item, ...unprocessedBatchReversed}

        let dynamicContractRegistrations = {
          unprocessedBatchReversed,
          registrationsReversed,
          inMemoryStore,
        }->Some
        {val: entitiesToLoad, dynamicContractRegistrations}
      }
    }->Ok
  }
}

let rec getReadEntities = (
  ~inMemoryStore,
  ~logger,
  ~entitiesToLoad=[],
  ~checkContractIsRegistered,
  ~dynamicContractRegistrations=None,
  eventBatch: list<Types.eventBatchQueueItem>,
): result<getReadEntitiesRes, ErrorHandling.t> => {
  switch eventBatch {
  | list{} => {val: entitiesToLoad, dynamicContractRegistrations}->Ok
  | list{item, ...tail} => {
      let composer = composeGetReadEntity(
        ~entitiesToLoad,
        ~asyncGetters,
        ~inMemoryStore,
        ~logger,
        ~item,
        ~checkContractIsRegistered,
        ~dynamicContractRegistrations,
      )

      let res = switch item.event {
      | FactoryContract_PoolCreated(event) =>
        composer(
          ~event,
          ~contextCreator=Context.FactoryContract.PoolCreatedEvent.contextCreator,
          ~getLoader=Handlers.FactoryContract.PoolCreated.getLoader,
          ~eventWithContextAccessor=Context.factoryContract_PoolCreatedWithContext,
        )
      | NonfungiblePositionManagerContract_IncreaseLiquidity(event) =>
        composer(
          ~event,
          ~contextCreator=Context.NonfungiblePositionManagerContract.IncreaseLiquidityEvent.contextCreator,
          ~getLoader=Handlers.NonfungiblePositionManagerContract.IncreaseLiquidity.getLoader,
          ~eventWithContextAccessor=Context.nonfungiblePositionManagerContract_IncreaseLiquidityWithContext,
        )
      | NonfungiblePositionManagerContract_DecreaseLiquidity(event) =>
        composer(
          ~event,
          ~contextCreator=Context.NonfungiblePositionManagerContract.DecreaseLiquidityEvent.contextCreator,
          ~getLoader=Handlers.NonfungiblePositionManagerContract.DecreaseLiquidity.getLoader,
          ~eventWithContextAccessor=Context.nonfungiblePositionManagerContract_DecreaseLiquidityWithContext,
        )
      | NonfungiblePositionManagerContract_Transfer(event) =>
        composer(
          ~event,
          ~contextCreator=Context.NonfungiblePositionManagerContract.TransferEvent.contextCreator,
          ~getLoader=Handlers.NonfungiblePositionManagerContract.Transfer.getLoader,
          ~eventWithContextAccessor=Context.nonfungiblePositionManagerContract_TransferWithContext,
        )
      | PoolContract_Swap(event) =>
        composer(
          ~event,
          ~contextCreator=Context.PoolContract.SwapEvent.contextCreator,
          ~getLoader=Handlers.PoolContract.Swap.getLoader,
          ~eventWithContextAccessor=Context.poolContract_SwapWithContext,
        )
      }

      //else keep getting read entities from batch
      switch res {
      | Error(e) => Error(e)
      | Ok(res) =>
        tail->getReadEntities(
          ~inMemoryStore,
          ~logger,
          ~entitiesToLoad=res.val,
          ~checkContractIsRegistered,
          ~dynamicContractRegistrations=res.dynamicContractRegistrations,
        )
      }
    }
  }
}

let loadReadEntities = async (
  ~inMemoryStore,
  ~eventBatch: list<Types.eventBatchQueueItem>,
  ~checkContractIsRegistered,
  ~logger: Pino.t,
): result<loadResponse<array<Context.eventRouterEventAndContext>>, ErrorHandling.t> => {
  switch eventBatch->getReadEntities(~inMemoryStore, ~logger, ~checkContractIsRegistered) {
  | Ok({val: entitiesToLoad, dynamicContractRegistrations}) =>
    let (readEntitiesGrouped, contexts): (
      array<array<Types.entityRead>>,
      array<Context.eventRouterEventAndContext>,
    ) =
      entitiesToLoad->Array.unzip

    let readEntities = readEntitiesGrouped->Belt.Array.concatMany

    await IO.loadEntitiesToInMemStore(~inMemoryStore, ~entityBatch=readEntities)

    {val: contexts, dynamicContractRegistrations}->Ok
  | Error(e) => Error(e)
  }
}

let registerProcessEventBatchMetrics = (
  ~logger,
  ~batchSize,
  ~loadDuration,
  ~handlerDuration,
  ~dbWriteDuration,
) => {
  logger->Logging.childTrace({
    "message": "Finished processing batch",
    "batch_size": batchSize,
    "loader_time_elapsed": loadDuration,
    "handlers_time_elapsed": handlerDuration,
    "write_time_elapsed": dbWriteDuration,
  })

  Prometheus.incrementLoadEntityDurationCounter(~duration=loadDuration)

  Prometheus.incrementEventRouterDurationCounter(~duration=handlerDuration)

  Prometheus.incrementExecuteBatchDurationCounter(~duration=dbWriteDuration)

  Prometheus.incrementEventsProcessedCounter(~number=batchSize)
}

let processEventBatch = async (
  ~eventBatch: list<Types.eventBatchQueueItem>,
  ~inMemoryStore: IO.InMemoryStore.t,
  ~checkContractIsRegistered,
) => {
  let logger = Logging.createChild(
    ~params={
      "context": "batch",
    },
  )

  let timeRef = Hrtime.makeTimer()

  switch await loadReadEntities(~inMemoryStore, ~eventBatch, ~logger, ~checkContractIsRegistered) {
  | Ok({val: eventBatchAndContext, dynamicContractRegistrations}) =>
    let elapsedAfterLoad = timeRef->Hrtime.timeSince->Hrtime.toMillis->Hrtime.intFromMillis

    switch await eventBatchAndContext->Belt.Array.reduce(Promise.resolve(Ok()), async (
      previousPromise,
      event,
    ) => {
      switch await previousPromise {
      | Error(e) => Error(e)
      | Ok() =>
        await Promise.make((resolve, _reject) =>
          event->eventRouter(~inMemoryStore, ~cb=res => resolve(. res))
        )
      }
    }) {
    | Ok() =>
      let elapsedTimeAfterProcess = timeRef->Hrtime.timeSince->Hrtime.toMillis->Hrtime.intFromMillis
      switch await DbFunctions.sql->IO.executeBatch(~inMemoryStore) {
      | exception exn =>
        exn->ErrorHandling.make(~msg="Failed writing batch to database", ~logger)->Error
      | () =>
        let elapsedTimeAfterDbWrite =
          timeRef->Hrtime.timeSince->Hrtime.toMillis->Hrtime.intFromMillis

        registerProcessEventBatchMetrics(
          ~logger,
          ~batchSize=eventBatchAndContext->Array.length,
          ~loadDuration=elapsedAfterLoad,
          ~handlerDuration=elapsedTimeAfterProcess - elapsedAfterLoad,
          ~dbWriteDuration=elapsedTimeAfterDbWrite - elapsedTimeAfterProcess,
        )

        {val: (), dynamicContractRegistrations}->Ok
      }
    | Error(e) => Error(e)
    }
  | Error(e) => Error(e)
  }
}
