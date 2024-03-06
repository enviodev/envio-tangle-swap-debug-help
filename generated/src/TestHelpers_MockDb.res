/***** TAKE NOTE ******
This file module is a hack to get genType to work!

In order for genType to produce recursive types, it needs to be at the 
root module of a file. If it's defined in a nested module it does not 
work. So all the MockDb types and internal functions are defined here in TestHelpers_MockDb
and only public functions are recreated and exported from TestHelpers.MockDb module.

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

open Belt

/**
A raw js binding to allow deleting from a dict. Used in store delete operation
*/
let deleteDictKey: (Js.Dict.t<'a>, string) => unit = %raw(`
    function(dict, key) {
      delete dict[key]
    }
  `)

/**
The mockDb type is simply an InMemoryStore internally. __dbInternal__ holds a reference
to an inMemoryStore and all the the accessor methods point to the reference of that inMemory
store
*/
@genType
type rec t = {
  __dbInternal__: IO.InMemoryStore.t,
  entities: entities,
  rawEvents: storeOperations<IO.InMemoryStore.rawEventsKey, Types.rawEventsEntity>,
  eventSyncState: storeOperations<Types.chainId, DbFunctions.EventSyncState.eventSyncState>,
  dynamicContractRegistry: storeOperations<
    IO.InMemoryStore.dynamicContractRegistryKey,
    Types.dynamicContractRegistryEntity,
  >,
}

// Each user defined entity will be in this record with all the store or "mockdb" operators
@genType
and entities = {
  @as("Bundle") bundle: entityStoreOperations<Types.bundleEntity>,
  @as("Burn") burn: entityStoreOperations<Types.burnEntity>,
  @as("Collect") collect: entityStoreOperations<Types.collectEntity>,
  @as("Factory") factory: entityStoreOperations<Types.factoryEntity>,
  @as("Flash") flash: entityStoreOperations<Types.flashEntity>,
  @as("Mint") mint: entityStoreOperations<Types.mintEntity>,
  @as("Pool") pool: entityStoreOperations<Types.poolEntity>,
  @as("PoolDayData") poolDayData: entityStoreOperations<Types.poolDayDataEntity>,
  @as("PoolHourData") poolHourData: entityStoreOperations<Types.poolHourDataEntity>,
  @as("Position") position: entityStoreOperations<Types.positionEntity>,
  @as("PositionSnapshot") positionSnapshot: entityStoreOperations<Types.positionSnapshotEntity>,
  @as("Swap") swap: entityStoreOperations<Types.swapEntity>,
  @as("Tick") tick: entityStoreOperations<Types.tickEntity>,
  @as("TickDayData") tickDayData: entityStoreOperations<Types.tickDayDataEntity>,
  @as("TickHourData") tickHourData: entityStoreOperations<Types.tickHourDataEntity>,
  @as("Token") token: entityStoreOperations<Types.tokenEntity>,
  @as("TokenDayData") tokenDayData: entityStoreOperations<Types.tokenDayDataEntity>,
  @as("TokenHourData") tokenHourData: entityStoreOperations<Types.tokenHourDataEntity>,
  @as("TokenPoolWhitelist")
  tokenPoolWhitelist: entityStoreOperations<Types.tokenPoolWhitelistEntity>,
  @as("Transaction") transaction: entityStoreOperations<Types.transactionEntity>,
  @as("UniswapDayData") uniswapDayData: entityStoreOperations<Types.uniswapDayDataEntity>,
}
// User defined entities always have a string for an id which is used as the
// key for entity stores
@genType and entityStoreOperations<'entity> = storeOperations<string, 'entity>
// all the operator functions a user can access on an entity in the mock db
// stores refer to the the module that MakeStore functor outputs in IO.res
@genType
and storeOperations<'entityKey, 'entity> = {
  getAll: unit => array<'entity>,
  get: 'entityKey => option<'entity>,
  set: 'entity => t,
  delete: 'entityKey => t,
}

module type StoreState = {
  type value
  type key
  let get: (IO.InMemoryStore.storeState<value, key>, key) => option<value>
  let values: IO.InMemoryStore.storeState<value, key> => array<Types.inMemoryStoreRow<value>>
  let set: (
    IO.InMemoryStore.storeState<value, key>,
    ~key: key,
    ~dbOp: Types.dbOp,
    ~entity: value,
  ) => unit
}

// /**
// a composable function to make the "storeOperations" record to represent all the mock
// db operations for each entity.
// */
let makeStoreOperator = (
  type entity key,
  storeStateMod: module(StoreState with type value = entity and type key = key),
  ~inMemoryStore: IO.InMemoryStore.t,
  ~makeMockDb,
  ~getStore: IO.InMemoryStore.t => IO.InMemoryStore.storeState<entity, key>,
  ~getKey: entity => key,
): storeOperations<key, entity> => {
  let module(StoreState) = storeStateMod
  let {get, values, set} = module(StoreState)

  let get = inMemoryStore->getStore->get
  let getAll = () => inMemoryStore->getStore->values->Array.map(row => row.entity)

  let set = entity => {
    let cloned = inMemoryStore->IO.InMemoryStore.clone
    cloned->getStore->set(~key=entity->getKey, ~entity, ~dbOp=Set)
    cloned->makeMockDb
  }

  let delete = key => {
    let cloned = inMemoryStore->IO.InMemoryStore.clone
    let store = cloned->getStore
    store.dict->deleteDictKey(key->store.hasher)
    cloned->makeMockDb
  }

  {
    getAll,
    get,
    set,
    delete,
  }
}

/**
The internal make function which can be passed an in memory store and
instantiate a "MockDb". This is useful for cloning or making a MockDb
out of an existing inMemoryStore
*/
let rec makeWithInMemoryStore = (inMemoryStore: IO.InMemoryStore.t) => {
  let rawEvents = module(IO.InMemoryStore.RawEvents)->makeStoreOperator(
    ~inMemoryStore,
    ~makeMockDb=makeWithInMemoryStore,
    ~getStore=db => db.rawEvents,
    ~getKey=({chainId, eventId}) => {
      chainId,
      eventId,
    },
  )

  let eventSyncState =
    module(IO.InMemoryStore.EventSyncState)->makeStoreOperator(
      ~inMemoryStore,
      ~makeMockDb=makeWithInMemoryStore,
      ~getStore=db => db.eventSyncState,
      ~getKey=({chainId}) => chainId,
    )

  let dynamicContractRegistry =
    module(IO.InMemoryStore.DynamicContractRegistry)->makeStoreOperator(
      ~inMemoryStore,
      ~getStore=db => db.dynamicContractRegistry,
      ~makeMockDb=makeWithInMemoryStore,
      ~getKey=({chainId, contractAddress}) => {chainId, contractAddress},
    )

  let entities = {
    bundle: {
      module(IO.InMemoryStore.Bundle)->makeStoreOperator(
        ~inMemoryStore,
        ~makeMockDb=makeWithInMemoryStore,
        ~getStore=db => db.bundle,
        ~getKey=({id}) => id,
      )
    },
    burn: {
      module(IO.InMemoryStore.Burn)->makeStoreOperator(
        ~inMemoryStore,
        ~makeMockDb=makeWithInMemoryStore,
        ~getStore=db => db.burn,
        ~getKey=({id}) => id,
      )
    },
    collect: {
      module(IO.InMemoryStore.Collect)->makeStoreOperator(
        ~inMemoryStore,
        ~makeMockDb=makeWithInMemoryStore,
        ~getStore=db => db.collect,
        ~getKey=({id}) => id,
      )
    },
    factory: {
      module(IO.InMemoryStore.Factory)->makeStoreOperator(
        ~inMemoryStore,
        ~makeMockDb=makeWithInMemoryStore,
        ~getStore=db => db.factory,
        ~getKey=({id}) => id,
      )
    },
    flash: {
      module(IO.InMemoryStore.Flash)->makeStoreOperator(
        ~inMemoryStore,
        ~makeMockDb=makeWithInMemoryStore,
        ~getStore=db => db.flash,
        ~getKey=({id}) => id,
      )
    },
    mint: {
      module(IO.InMemoryStore.Mint)->makeStoreOperator(
        ~inMemoryStore,
        ~makeMockDb=makeWithInMemoryStore,
        ~getStore=db => db.mint,
        ~getKey=({id}) => id,
      )
    },
    pool: {
      module(IO.InMemoryStore.Pool)->makeStoreOperator(
        ~inMemoryStore,
        ~makeMockDb=makeWithInMemoryStore,
        ~getStore=db => db.pool,
        ~getKey=({id}) => id,
      )
    },
    poolDayData: {
      module(IO.InMemoryStore.PoolDayData)->makeStoreOperator(
        ~inMemoryStore,
        ~makeMockDb=makeWithInMemoryStore,
        ~getStore=db => db.poolDayData,
        ~getKey=({id}) => id,
      )
    },
    poolHourData: {
      module(IO.InMemoryStore.PoolHourData)->makeStoreOperator(
        ~inMemoryStore,
        ~makeMockDb=makeWithInMemoryStore,
        ~getStore=db => db.poolHourData,
        ~getKey=({id}) => id,
      )
    },
    position: {
      module(IO.InMemoryStore.Position)->makeStoreOperator(
        ~inMemoryStore,
        ~makeMockDb=makeWithInMemoryStore,
        ~getStore=db => db.position,
        ~getKey=({id}) => id,
      )
    },
    positionSnapshot: {
      module(IO.InMemoryStore.PositionSnapshot)->makeStoreOperator(
        ~inMemoryStore,
        ~makeMockDb=makeWithInMemoryStore,
        ~getStore=db => db.positionSnapshot,
        ~getKey=({id}) => id,
      )
    },
    swap: {
      module(IO.InMemoryStore.Swap)->makeStoreOperator(
        ~inMemoryStore,
        ~makeMockDb=makeWithInMemoryStore,
        ~getStore=db => db.swap,
        ~getKey=({id}) => id,
      )
    },
    tick: {
      module(IO.InMemoryStore.Tick)->makeStoreOperator(
        ~inMemoryStore,
        ~makeMockDb=makeWithInMemoryStore,
        ~getStore=db => db.tick,
        ~getKey=({id}) => id,
      )
    },
    tickDayData: {
      module(IO.InMemoryStore.TickDayData)->makeStoreOperator(
        ~inMemoryStore,
        ~makeMockDb=makeWithInMemoryStore,
        ~getStore=db => db.tickDayData,
        ~getKey=({id}) => id,
      )
    },
    tickHourData: {
      module(IO.InMemoryStore.TickHourData)->makeStoreOperator(
        ~inMemoryStore,
        ~makeMockDb=makeWithInMemoryStore,
        ~getStore=db => db.tickHourData,
        ~getKey=({id}) => id,
      )
    },
    token: {
      module(IO.InMemoryStore.Token)->makeStoreOperator(
        ~inMemoryStore,
        ~makeMockDb=makeWithInMemoryStore,
        ~getStore=db => db.token,
        ~getKey=({id}) => id,
      )
    },
    tokenDayData: {
      module(IO.InMemoryStore.TokenDayData)->makeStoreOperator(
        ~inMemoryStore,
        ~makeMockDb=makeWithInMemoryStore,
        ~getStore=db => db.tokenDayData,
        ~getKey=({id}) => id,
      )
    },
    tokenHourData: {
      module(IO.InMemoryStore.TokenHourData)->makeStoreOperator(
        ~inMemoryStore,
        ~makeMockDb=makeWithInMemoryStore,
        ~getStore=db => db.tokenHourData,
        ~getKey=({id}) => id,
      )
    },
    tokenPoolWhitelist: {
      module(IO.InMemoryStore.TokenPoolWhitelist)->makeStoreOperator(
        ~inMemoryStore,
        ~makeMockDb=makeWithInMemoryStore,
        ~getStore=db => db.tokenPoolWhitelist,
        ~getKey=({id}) => id,
      )
    },
    transaction: {
      module(IO.InMemoryStore.Transaction)->makeStoreOperator(
        ~inMemoryStore,
        ~makeMockDb=makeWithInMemoryStore,
        ~getStore=db => db.transaction,
        ~getKey=({id}) => id,
      )
    },
    uniswapDayData: {
      module(IO.InMemoryStore.UniswapDayData)->makeStoreOperator(
        ~inMemoryStore,
        ~makeMockDb=makeWithInMemoryStore,
        ~getStore=db => db.uniswapDayData,
        ~getKey=({id}) => id,
      )
    },
  }

  {__dbInternal__: inMemoryStore, entities, rawEvents, eventSyncState, dynamicContractRegistry}
}

//Note: It's called createMockDb over "make" to make it more intuitive in JS and TS

/**
The constructor function for a mockDb. Call it and then set up the inital state by calling
any of the set functions it provides access to. A mockDb will be passed into a processEvent 
helper. Note, process event helpers will not mutate the mockDb but return a new mockDb with
new state so you can compare states before and after.
*/
@genType
let createMockDb = () => makeWithInMemoryStore(IO.InMemoryStore.make())

/**
Accessor function for getting the internal inMemoryStore in the mockDb
*/
let getInternalDb = (self: t) => self.__dbInternal__

/**
Deep copies the in memory store data and returns a new mockDb with the same
state and no references to data from the passed in mockDb
*/
let cloneMockDb = (self: t) => {
  let clonedInternalDb = self->getInternalDb->IO.InMemoryStore.clone
  clonedInternalDb->makeWithInMemoryStore
}

/**
Specifically create an executor for the mockDb
*/
let makeMockDbEntityExecuter = (~idsToLoad, ~dbReadFn, ~inMemStoreSetFn, ~store, ~getEntiyId) => {
  let dbReadFn = idsArr => idsArr->Belt.Array.keepMap(id => id->dbReadFn)
  IO.makeEntityExecuterComposer(
    ~idsToLoad,
    ~dbReadFn,
    ~inMemStoreSetFn,
    ~store,
    ~getEntiyId,
    ~unit=(),
    ~then=(res, fn) => res->fn,
  )
}

/**
Executes a single load layer using the mockDb functions
*/
let executeMockDbLoadLayer = (
  mockDb: t,
  ~loadLayer: IO.LoadLayer.t,
  ~inMemoryStore: IO.InMemoryStore.t,
) => {
  let entityExecutors = [
    makeMockDbEntityExecuter(
      ~idsToLoad=loadLayer.bundleIdsToLoad,
      ~dbReadFn=mockDb.entities.bundle.get,
      ~inMemStoreSetFn=IO.InMemoryStore.Bundle.set,
      ~store=inMemoryStore.bundle,
      ~getEntiyId=entity => entity.id,
    ),
    makeMockDbEntityExecuter(
      ~idsToLoad=loadLayer.burnIdsToLoad,
      ~dbReadFn=mockDb.entities.burn.get,
      ~inMemStoreSetFn=IO.InMemoryStore.Burn.set,
      ~store=inMemoryStore.burn,
      ~getEntiyId=entity => entity.id,
    ),
    makeMockDbEntityExecuter(
      ~idsToLoad=loadLayer.collectIdsToLoad,
      ~dbReadFn=mockDb.entities.collect.get,
      ~inMemStoreSetFn=IO.InMemoryStore.Collect.set,
      ~store=inMemoryStore.collect,
      ~getEntiyId=entity => entity.id,
    ),
    makeMockDbEntityExecuter(
      ~idsToLoad=loadLayer.factoryIdsToLoad,
      ~dbReadFn=mockDb.entities.factory.get,
      ~inMemStoreSetFn=IO.InMemoryStore.Factory.set,
      ~store=inMemoryStore.factory,
      ~getEntiyId=entity => entity.id,
    ),
    makeMockDbEntityExecuter(
      ~idsToLoad=loadLayer.flashIdsToLoad,
      ~dbReadFn=mockDb.entities.flash.get,
      ~inMemStoreSetFn=IO.InMemoryStore.Flash.set,
      ~store=inMemoryStore.flash,
      ~getEntiyId=entity => entity.id,
    ),
    makeMockDbEntityExecuter(
      ~idsToLoad=loadLayer.mintIdsToLoad,
      ~dbReadFn=mockDb.entities.mint.get,
      ~inMemStoreSetFn=IO.InMemoryStore.Mint.set,
      ~store=inMemoryStore.mint,
      ~getEntiyId=entity => entity.id,
    ),
    makeMockDbEntityExecuter(
      ~idsToLoad=loadLayer.poolIdsToLoad,
      ~dbReadFn=mockDb.entities.pool.get,
      ~inMemStoreSetFn=IO.InMemoryStore.Pool.set,
      ~store=inMemoryStore.pool,
      ~getEntiyId=entity => entity.id,
    ),
    makeMockDbEntityExecuter(
      ~idsToLoad=loadLayer.poolDayDataIdsToLoad,
      ~dbReadFn=mockDb.entities.poolDayData.get,
      ~inMemStoreSetFn=IO.InMemoryStore.PoolDayData.set,
      ~store=inMemoryStore.poolDayData,
      ~getEntiyId=entity => entity.id,
    ),
    makeMockDbEntityExecuter(
      ~idsToLoad=loadLayer.poolHourDataIdsToLoad,
      ~dbReadFn=mockDb.entities.poolHourData.get,
      ~inMemStoreSetFn=IO.InMemoryStore.PoolHourData.set,
      ~store=inMemoryStore.poolHourData,
      ~getEntiyId=entity => entity.id,
    ),
    makeMockDbEntityExecuter(
      ~idsToLoad=loadLayer.positionIdsToLoad,
      ~dbReadFn=mockDb.entities.position.get,
      ~inMemStoreSetFn=IO.InMemoryStore.Position.set,
      ~store=inMemoryStore.position,
      ~getEntiyId=entity => entity.id,
    ),
    makeMockDbEntityExecuter(
      ~idsToLoad=loadLayer.positionSnapshotIdsToLoad,
      ~dbReadFn=mockDb.entities.positionSnapshot.get,
      ~inMemStoreSetFn=IO.InMemoryStore.PositionSnapshot.set,
      ~store=inMemoryStore.positionSnapshot,
      ~getEntiyId=entity => entity.id,
    ),
    makeMockDbEntityExecuter(
      ~idsToLoad=loadLayer.swapIdsToLoad,
      ~dbReadFn=mockDb.entities.swap.get,
      ~inMemStoreSetFn=IO.InMemoryStore.Swap.set,
      ~store=inMemoryStore.swap,
      ~getEntiyId=entity => entity.id,
    ),
    makeMockDbEntityExecuter(
      ~idsToLoad=loadLayer.tickIdsToLoad,
      ~dbReadFn=mockDb.entities.tick.get,
      ~inMemStoreSetFn=IO.InMemoryStore.Tick.set,
      ~store=inMemoryStore.tick,
      ~getEntiyId=entity => entity.id,
    ),
    makeMockDbEntityExecuter(
      ~idsToLoad=loadLayer.tickDayDataIdsToLoad,
      ~dbReadFn=mockDb.entities.tickDayData.get,
      ~inMemStoreSetFn=IO.InMemoryStore.TickDayData.set,
      ~store=inMemoryStore.tickDayData,
      ~getEntiyId=entity => entity.id,
    ),
    makeMockDbEntityExecuter(
      ~idsToLoad=loadLayer.tickHourDataIdsToLoad,
      ~dbReadFn=mockDb.entities.tickHourData.get,
      ~inMemStoreSetFn=IO.InMemoryStore.TickHourData.set,
      ~store=inMemoryStore.tickHourData,
      ~getEntiyId=entity => entity.id,
    ),
    makeMockDbEntityExecuter(
      ~idsToLoad=loadLayer.tokenIdsToLoad,
      ~dbReadFn=mockDb.entities.token.get,
      ~inMemStoreSetFn=IO.InMemoryStore.Token.set,
      ~store=inMemoryStore.token,
      ~getEntiyId=entity => entity.id,
    ),
    makeMockDbEntityExecuter(
      ~idsToLoad=loadLayer.tokenDayDataIdsToLoad,
      ~dbReadFn=mockDb.entities.tokenDayData.get,
      ~inMemStoreSetFn=IO.InMemoryStore.TokenDayData.set,
      ~store=inMemoryStore.tokenDayData,
      ~getEntiyId=entity => entity.id,
    ),
    makeMockDbEntityExecuter(
      ~idsToLoad=loadLayer.tokenHourDataIdsToLoad,
      ~dbReadFn=mockDb.entities.tokenHourData.get,
      ~inMemStoreSetFn=IO.InMemoryStore.TokenHourData.set,
      ~store=inMemoryStore.tokenHourData,
      ~getEntiyId=entity => entity.id,
    ),
    makeMockDbEntityExecuter(
      ~idsToLoad=loadLayer.tokenPoolWhitelistIdsToLoad,
      ~dbReadFn=mockDb.entities.tokenPoolWhitelist.get,
      ~inMemStoreSetFn=IO.InMemoryStore.TokenPoolWhitelist.set,
      ~store=inMemoryStore.tokenPoolWhitelist,
      ~getEntiyId=entity => entity.id,
    ),
    makeMockDbEntityExecuter(
      ~idsToLoad=loadLayer.transactionIdsToLoad,
      ~dbReadFn=mockDb.entities.transaction.get,
      ~inMemStoreSetFn=IO.InMemoryStore.Transaction.set,
      ~store=inMemoryStore.transaction,
      ~getEntiyId=entity => entity.id,
    ),
    makeMockDbEntityExecuter(
      ~idsToLoad=loadLayer.uniswapDayDataIdsToLoad,
      ~dbReadFn=mockDb.entities.uniswapDayData.get,
      ~inMemStoreSetFn=IO.InMemoryStore.UniswapDayData.set,
      ~store=inMemoryStore.uniswapDayData,
      ~getEntiyId=entity => entity.id,
    ),
  ]
  let handleResponses = _ => {
    IO.getNextLayer(~loadLayer)
  }

  IO.executeLoadLayerComposer(~entityExecutors, ~handleResponses)
}

/**
Given an isolated inMemoryStore and an array of read entities. This function loads the 
requested data from the mockDb into the inMemory store. Simulating how loading happens
from and external db into the inMemoryStore for a batch during event processing
*/
let loadEntitiesToInMemStore = (mockDb, ~entityBatch, ~inMemoryStore) => {
  let executeLoadLayerFn = mockDb->executeMockDbLoadLayer
  //In an async handler this would be a Promise.then... in this case
  //just need to return the value and pass it into the callback
  let then = (res, fn) => res->fn
  IO.loadEntitiesToInMemStoreComposer(
    ~inMemoryStore,
    ~entityBatch,
    ~executeLoadLayerFn,
    ~then,
    ~unit=(),
  )
}

/**
A function composer for simulating the writing of an inMemoryStore to the external db with a mockDb.
Runs all set and delete operations currently cached in an inMemory store against the mockDb
*/
let executeRows = (
  mockDb: t,
  ~inMemoryStore: IO.InMemoryStore.t,
  ~getStore: IO.InMemoryStore.t => IO.InMemoryStore.storeState<'entity, 'key>,
  ~getRows: IO.InMemoryStore.storeState<'entity, 'key> => array<Types.inMemoryStoreRow<'entity>>,
  ~getKey: 'entity => 'key,
  ~setFunction: (
    IO.InMemoryStore.storeState<'entity, 'key>,
    ~key: 'key,
    ~dbOp: Types.dbOp,
    ~entity: 'entity,
  ) => unit,
) => {
  inMemoryStore
  ->getStore
  ->getRows
  ->Array.forEach(row => {
    let store = mockDb->getInternalDb->getStore
    switch row.dbOp {
    | Set => store->setFunction(~dbOp=Read, ~key=getKey(row.entity), ~entity=row.entity)
    | Delete => store.dict->deleteDictKey(row.entity->getKey->store.hasher)
    | Read => ()
    }
  })
}

/**
Simulates the writing of processed data in the inMemoryStore to a mockDb. This function
executes all the rows on each "store" (or pg table) in the inMemoryStore
*/
let writeFromMemoryStore = (mockDb: t, ~inMemoryStore: IO.InMemoryStore.t) => {
  open IO
  //INTERNAL STORES/TABLES EXECUTION
  mockDb->executeRows(
    ~inMemoryStore,
    ~getRows=InMemoryStore.RawEvents.values,
    ~getStore=inMemStore => {inMemStore.rawEvents},
    ~setFunction=InMemoryStore.RawEvents.set,
    ~getKey=(entity): IO.InMemoryStore.rawEventsKey => {
      chainId: entity.chainId,
      eventId: entity.eventId,
    },
  )

  mockDb->executeRows(
    ~inMemoryStore,
    ~getStore=inMemStore => {inMemStore.eventSyncState},
    ~getRows=InMemoryStore.EventSyncState.values,
    ~setFunction=InMemoryStore.EventSyncState.set,
    ~getKey=entity => entity.chainId,
  )

  mockDb->executeRows(
    ~inMemoryStore,
    ~getRows=InMemoryStore.DynamicContractRegistry.values,
    ~getStore=inMemStore => {inMemStore.dynamicContractRegistry},
    ~setFunction=InMemoryStore.DynamicContractRegistry.set,
    ~getKey=(entity): IO.InMemoryStore.dynamicContractRegistryKey => {
      chainId: entity.chainId,
      contractAddress: entity.contractAddress,
    },
  )

  //ENTITY EXECUTION
  mockDb->executeRows(
    ~inMemoryStore,
    ~getStore=self => {self.bundle},
    ~getRows=IO.InMemoryStore.Bundle.values,
    ~setFunction=IO.InMemoryStore.Bundle.set,
    ~getKey=entity => entity.id,
  )
  mockDb->executeRows(
    ~inMemoryStore,
    ~getStore=self => {self.burn},
    ~getRows=IO.InMemoryStore.Burn.values,
    ~setFunction=IO.InMemoryStore.Burn.set,
    ~getKey=entity => entity.id,
  )
  mockDb->executeRows(
    ~inMemoryStore,
    ~getStore=self => {self.collect},
    ~getRows=IO.InMemoryStore.Collect.values,
    ~setFunction=IO.InMemoryStore.Collect.set,
    ~getKey=entity => entity.id,
  )
  mockDb->executeRows(
    ~inMemoryStore,
    ~getStore=self => {self.factory},
    ~getRows=IO.InMemoryStore.Factory.values,
    ~setFunction=IO.InMemoryStore.Factory.set,
    ~getKey=entity => entity.id,
  )
  mockDb->executeRows(
    ~inMemoryStore,
    ~getStore=self => {self.flash},
    ~getRows=IO.InMemoryStore.Flash.values,
    ~setFunction=IO.InMemoryStore.Flash.set,
    ~getKey=entity => entity.id,
  )
  mockDb->executeRows(
    ~inMemoryStore,
    ~getStore=self => {self.mint},
    ~getRows=IO.InMemoryStore.Mint.values,
    ~setFunction=IO.InMemoryStore.Mint.set,
    ~getKey=entity => entity.id,
  )
  mockDb->executeRows(
    ~inMemoryStore,
    ~getStore=self => {self.pool},
    ~getRows=IO.InMemoryStore.Pool.values,
    ~setFunction=IO.InMemoryStore.Pool.set,
    ~getKey=entity => entity.id,
  )
  mockDb->executeRows(
    ~inMemoryStore,
    ~getStore=self => {self.poolDayData},
    ~getRows=IO.InMemoryStore.PoolDayData.values,
    ~setFunction=IO.InMemoryStore.PoolDayData.set,
    ~getKey=entity => entity.id,
  )
  mockDb->executeRows(
    ~inMemoryStore,
    ~getStore=self => {self.poolHourData},
    ~getRows=IO.InMemoryStore.PoolHourData.values,
    ~setFunction=IO.InMemoryStore.PoolHourData.set,
    ~getKey=entity => entity.id,
  )
  mockDb->executeRows(
    ~inMemoryStore,
    ~getStore=self => {self.position},
    ~getRows=IO.InMemoryStore.Position.values,
    ~setFunction=IO.InMemoryStore.Position.set,
    ~getKey=entity => entity.id,
  )
  mockDb->executeRows(
    ~inMemoryStore,
    ~getStore=self => {self.positionSnapshot},
    ~getRows=IO.InMemoryStore.PositionSnapshot.values,
    ~setFunction=IO.InMemoryStore.PositionSnapshot.set,
    ~getKey=entity => entity.id,
  )
  mockDb->executeRows(
    ~inMemoryStore,
    ~getStore=self => {self.swap},
    ~getRows=IO.InMemoryStore.Swap.values,
    ~setFunction=IO.InMemoryStore.Swap.set,
    ~getKey=entity => entity.id,
  )
  mockDb->executeRows(
    ~inMemoryStore,
    ~getStore=self => {self.tick},
    ~getRows=IO.InMemoryStore.Tick.values,
    ~setFunction=IO.InMemoryStore.Tick.set,
    ~getKey=entity => entity.id,
  )
  mockDb->executeRows(
    ~inMemoryStore,
    ~getStore=self => {self.tickDayData},
    ~getRows=IO.InMemoryStore.TickDayData.values,
    ~setFunction=IO.InMemoryStore.TickDayData.set,
    ~getKey=entity => entity.id,
  )
  mockDb->executeRows(
    ~inMemoryStore,
    ~getStore=self => {self.tickHourData},
    ~getRows=IO.InMemoryStore.TickHourData.values,
    ~setFunction=IO.InMemoryStore.TickHourData.set,
    ~getKey=entity => entity.id,
  )
  mockDb->executeRows(
    ~inMemoryStore,
    ~getStore=self => {self.token},
    ~getRows=IO.InMemoryStore.Token.values,
    ~setFunction=IO.InMemoryStore.Token.set,
    ~getKey=entity => entity.id,
  )
  mockDb->executeRows(
    ~inMemoryStore,
    ~getStore=self => {self.tokenDayData},
    ~getRows=IO.InMemoryStore.TokenDayData.values,
    ~setFunction=IO.InMemoryStore.TokenDayData.set,
    ~getKey=entity => entity.id,
  )
  mockDb->executeRows(
    ~inMemoryStore,
    ~getStore=self => {self.tokenHourData},
    ~getRows=IO.InMemoryStore.TokenHourData.values,
    ~setFunction=IO.InMemoryStore.TokenHourData.set,
    ~getKey=entity => entity.id,
  )
  mockDb->executeRows(
    ~inMemoryStore,
    ~getStore=self => {self.tokenPoolWhitelist},
    ~getRows=IO.InMemoryStore.TokenPoolWhitelist.values,
    ~setFunction=IO.InMemoryStore.TokenPoolWhitelist.set,
    ~getKey=entity => entity.id,
  )
  mockDb->executeRows(
    ~inMemoryStore,
    ~getStore=self => {self.transaction},
    ~getRows=IO.InMemoryStore.Transaction.values,
    ~setFunction=IO.InMemoryStore.Transaction.set,
    ~getKey=entity => entity.id,
  )
  mockDb->executeRows(
    ~inMemoryStore,
    ~getStore=self => {self.uniswapDayData},
    ~getRows=IO.InMemoryStore.UniswapDayData.values,
    ~setFunction=IO.InMemoryStore.UniswapDayData.set,
    ~getKey=entity => entity.id,
  )
}
