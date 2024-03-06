module InMemoryStore = {
  let entityCurrentCrud = (currentCrud: option<Types.dbOp>, nextCrud: Types.dbOp): Types.dbOp => {
    switch (currentCrud, nextCrud) {
    | (Some(Set), Read)
    | (_, Set) =>
      Set
    | (Some(Read), Read) => Read
    | (Some(Delete), Read)
    | (_, Delete) =>
      Delete
    | (None, _) => nextCrud
    }
  }

  type stringHasher<'val> = 'val => string
  type storeState<'entity, 'entityKey> = {
    dict: Js.Dict.t<Types.inMemoryStoreRow<'entity>>,
    hasher: stringHasher<'entityKey>,
  }

  module type StoreItem = {
    type t
    type key
    let hasher: stringHasher<key>
  }

  //Binding used for deep cloning stores in tests
  @val external structuredClone: 'a => 'a = "structuredClone"

  module MakeStore = (StoreItem: StoreItem) => {
    @genType
    type value = StoreItem.t
    @genType
    type key = StoreItem.key
    type t = storeState<value, key>

    let make = (): t => {dict: Js.Dict.empty(), hasher: StoreItem.hasher}

    let set = (self: t, ~key: StoreItem.key, ~dbOp, ~entity: StoreItem.t) =>
      self.dict->Js.Dict.set(key->self.hasher, {entity, dbOp})

    let get = (self: t, key: StoreItem.key) =>
      self.dict->Js.Dict.get(key->self.hasher)->Belt.Option.map(row => row.entity)

    let values = (self: t) => self.dict->Js.Dict.values

    let clone = (self: t) => {
      ...self,
      dict: self.dict->structuredClone,
    }
  }

  module EventSyncState = MakeStore({
    type t = DbFunctions.EventSyncState.eventSyncState
    type key = int
    let hasher = Belt.Int.toString
  })

  @genType
  type rawEventsKey = {
    chainId: int,
    eventId: string,
  }

  module RawEvents = MakeStore({
    type t = Types.rawEventsEntity
    type key = rawEventsKey
    let hasher = (key: key) =>
      EventUtils.getEventIdKeyString(~chainId=key.chainId, ~eventId=key.eventId)
  })

  @genType
  type dynamicContractRegistryKey = {
    chainId: int,
    contractAddress: Ethers.ethAddress,
  }

  module DynamicContractRegistry = MakeStore({
    type t = Types.dynamicContractRegistryEntity
    type key = dynamicContractRegistryKey
    let hasher = ({chainId, contractAddress}) =>
      EventUtils.getContractAddressKeyString(~chainId, ~contractAddress)
  })

  module Bundle = MakeStore({
    type t = Types.bundleEntity
    type key = string
    let hasher = Obj.magic
  })

  module Burn = MakeStore({
    type t = Types.burnEntity
    type key = string
    let hasher = Obj.magic
  })

  module Collect = MakeStore({
    type t = Types.collectEntity
    type key = string
    let hasher = Obj.magic
  })

  module Factory = MakeStore({
    type t = Types.factoryEntity
    type key = string
    let hasher = Obj.magic
  })

  module Flash = MakeStore({
    type t = Types.flashEntity
    type key = string
    let hasher = Obj.magic
  })

  module Mint = MakeStore({
    type t = Types.mintEntity
    type key = string
    let hasher = Obj.magic
  })

  module Pool = MakeStore({
    type t = Types.poolEntity
    type key = string
    let hasher = Obj.magic
  })

  module PoolDayData = MakeStore({
    type t = Types.poolDayDataEntity
    type key = string
    let hasher = Obj.magic
  })

  module PoolHourData = MakeStore({
    type t = Types.poolHourDataEntity
    type key = string
    let hasher = Obj.magic
  })

  module Position = MakeStore({
    type t = Types.positionEntity
    type key = string
    let hasher = Obj.magic
  })

  module PositionSnapshot = MakeStore({
    type t = Types.positionSnapshotEntity
    type key = string
    let hasher = Obj.magic
  })

  module Swap = MakeStore({
    type t = Types.swapEntity
    type key = string
    let hasher = Obj.magic
  })

  module Tick = MakeStore({
    type t = Types.tickEntity
    type key = string
    let hasher = Obj.magic
  })

  module TickDayData = MakeStore({
    type t = Types.tickDayDataEntity
    type key = string
    let hasher = Obj.magic
  })

  module TickHourData = MakeStore({
    type t = Types.tickHourDataEntity
    type key = string
    let hasher = Obj.magic
  })

  module Token = MakeStore({
    type t = Types.tokenEntity
    type key = string
    let hasher = Obj.magic
  })

  module TokenDayData = MakeStore({
    type t = Types.tokenDayDataEntity
    type key = string
    let hasher = Obj.magic
  })

  module TokenHourData = MakeStore({
    type t = Types.tokenHourDataEntity
    type key = string
    let hasher = Obj.magic
  })

  module TokenPoolWhitelist = MakeStore({
    type t = Types.tokenPoolWhitelistEntity
    type key = string
    let hasher = Obj.magic
  })

  module Transaction = MakeStore({
    type t = Types.transactionEntity
    type key = string
    let hasher = Obj.magic
  })

  module UniswapDayData = MakeStore({
    type t = Types.uniswapDayDataEntity
    type key = string
    let hasher = Obj.magic
  })

  @genType
  type t = {
    eventSyncState: EventSyncState.t,
    rawEvents: RawEvents.t,
    dynamicContractRegistry: DynamicContractRegistry.t,
    bundle: Bundle.t,
    burn: Burn.t,
    collect: Collect.t,
    factory: Factory.t,
    flash: Flash.t,
    mint: Mint.t,
    pool: Pool.t,
    poolDayData: PoolDayData.t,
    poolHourData: PoolHourData.t,
    position: Position.t,
    positionSnapshot: PositionSnapshot.t,
    swap: Swap.t,
    tick: Tick.t,
    tickDayData: TickDayData.t,
    tickHourData: TickHourData.t,
    token: Token.t,
    tokenDayData: TokenDayData.t,
    tokenHourData: TokenHourData.t,
    tokenPoolWhitelist: TokenPoolWhitelist.t,
    transaction: Transaction.t,
    uniswapDayData: UniswapDayData.t,
  }

  let make = (): t => {
    eventSyncState: EventSyncState.make(),
    rawEvents: RawEvents.make(),
    dynamicContractRegistry: DynamicContractRegistry.make(),
    bundle: Bundle.make(),
    burn: Burn.make(),
    collect: Collect.make(),
    factory: Factory.make(),
    flash: Flash.make(),
    mint: Mint.make(),
    pool: Pool.make(),
    poolDayData: PoolDayData.make(),
    poolHourData: PoolHourData.make(),
    position: Position.make(),
    positionSnapshot: PositionSnapshot.make(),
    swap: Swap.make(),
    tick: Tick.make(),
    tickDayData: TickDayData.make(),
    tickHourData: TickHourData.make(),
    token: Token.make(),
    tokenDayData: TokenDayData.make(),
    tokenHourData: TokenHourData.make(),
    tokenPoolWhitelist: TokenPoolWhitelist.make(),
    transaction: Transaction.make(),
    uniswapDayData: UniswapDayData.make(),
  }

  let clone = (self: t) => {
    eventSyncState: self.eventSyncState->EventSyncState.clone,
    rawEvents: self.rawEvents->RawEvents.clone,
    dynamicContractRegistry: self.dynamicContractRegistry->DynamicContractRegistry.clone,
    bundle: self.bundle->Bundle.clone,
    burn: self.burn->Burn.clone,
    collect: self.collect->Collect.clone,
    factory: self.factory->Factory.clone,
    flash: self.flash->Flash.clone,
    mint: self.mint->Mint.clone,
    pool: self.pool->Pool.clone,
    poolDayData: self.poolDayData->PoolDayData.clone,
    poolHourData: self.poolHourData->PoolHourData.clone,
    position: self.position->Position.clone,
    positionSnapshot: self.positionSnapshot->PositionSnapshot.clone,
    swap: self.swap->Swap.clone,
    tick: self.tick->Tick.clone,
    tickDayData: self.tickDayData->TickDayData.clone,
    tickHourData: self.tickHourData->TickHourData.clone,
    token: self.token->Token.clone,
    tokenDayData: self.tokenDayData->TokenDayData.clone,
    tokenHourData: self.tokenHourData->TokenHourData.clone,
    tokenPoolWhitelist: self.tokenPoolWhitelist->TokenPoolWhitelist.clone,
    transaction: self.transaction->Transaction.clone,
    uniswapDayData: self.uniswapDayData->UniswapDayData.clone,
  }
}

module LoadLayer = {
  /**The ids to load for a particular entity*/
  type idsToLoad = Belt.Set.String.t

  /**
  A round of entities to load from the DB. Depending on what entities come back
  and the dataLoaded "actions" that get run after the entities are loaded up. It
  could mean another load layer is created based of values that are returned
  */
  type rec t = {
    //A an array of getters to run after the entities with idsToLoad have been loaded
    dataLoadedActionsGetters: dataLoadedActionsGetters,
    //A unique list of ids that need to be loaded for entity bundle
    bundleIdsToLoad: idsToLoad,
    //A unique list of ids that need to be loaded for entity burn
    burnIdsToLoad: idsToLoad,
    //A unique list of ids that need to be loaded for entity collect
    collectIdsToLoad: idsToLoad,
    //A unique list of ids that need to be loaded for entity factory
    factoryIdsToLoad: idsToLoad,
    //A unique list of ids that need to be loaded for entity flash
    flashIdsToLoad: idsToLoad,
    //A unique list of ids that need to be loaded for entity mint
    mintIdsToLoad: idsToLoad,
    //A unique list of ids that need to be loaded for entity pool
    poolIdsToLoad: idsToLoad,
    //A unique list of ids that need to be loaded for entity poolDayData
    poolDayDataIdsToLoad: idsToLoad,
    //A unique list of ids that need to be loaded for entity poolHourData
    poolHourDataIdsToLoad: idsToLoad,
    //A unique list of ids that need to be loaded for entity position
    positionIdsToLoad: idsToLoad,
    //A unique list of ids that need to be loaded for entity positionSnapshot
    positionSnapshotIdsToLoad: idsToLoad,
    //A unique list of ids that need to be loaded for entity swap
    swapIdsToLoad: idsToLoad,
    //A unique list of ids that need to be loaded for entity tick
    tickIdsToLoad: idsToLoad,
    //A unique list of ids that need to be loaded for entity tickDayData
    tickDayDataIdsToLoad: idsToLoad,
    //A unique list of ids that need to be loaded for entity tickHourData
    tickHourDataIdsToLoad: idsToLoad,
    //A unique list of ids that need to be loaded for entity token
    tokenIdsToLoad: idsToLoad,
    //A unique list of ids that need to be loaded for entity tokenDayData
    tokenDayDataIdsToLoad: idsToLoad,
    //A unique list of ids that need to be loaded for entity tokenHourData
    tokenHourDataIdsToLoad: idsToLoad,
    //A unique list of ids that need to be loaded for entity tokenPoolWhitelist
    tokenPoolWhitelistIdsToLoad: idsToLoad,
    //A unique list of ids that need to be loaded for entity transaction
    transactionIdsToLoad: idsToLoad,
    //A unique list of ids that need to be loaded for entity uniswapDayData
    uniswapDayDataIdsToLoad: idsToLoad,
  }
  //An action that gets run after the data is loaded in from the db to the in memory store
  //the action will derive values from the loaded data and update the next load layer
  and dataLoadedAction = t => t
  //A getter function that returns an array of actions that need to be run
  //Actions will fetch values from the in memory store and update a load layer
  and dataLoadedActionsGetter = unit => array<dataLoadedAction>
  //An array of getter functions for dataLoadedActions
  and dataLoadedActionsGetters = array<dataLoadedActionsGetter>

  /**Instantiates a load layer*/
  let emptyLoadLayer = () => {
    bundleIdsToLoad: Belt.Set.String.empty,
    burnIdsToLoad: Belt.Set.String.empty,
    collectIdsToLoad: Belt.Set.String.empty,
    factoryIdsToLoad: Belt.Set.String.empty,
    flashIdsToLoad: Belt.Set.String.empty,
    mintIdsToLoad: Belt.Set.String.empty,
    poolIdsToLoad: Belt.Set.String.empty,
    poolDayDataIdsToLoad: Belt.Set.String.empty,
    poolHourDataIdsToLoad: Belt.Set.String.empty,
    positionIdsToLoad: Belt.Set.String.empty,
    positionSnapshotIdsToLoad: Belt.Set.String.empty,
    swapIdsToLoad: Belt.Set.String.empty,
    tickIdsToLoad: Belt.Set.String.empty,
    tickDayDataIdsToLoad: Belt.Set.String.empty,
    tickHourDataIdsToLoad: Belt.Set.String.empty,
    tokenIdsToLoad: Belt.Set.String.empty,
    tokenDayDataIdsToLoad: Belt.Set.String.empty,
    tokenHourDataIdsToLoad: Belt.Set.String.empty,
    tokenPoolWhitelistIdsToLoad: Belt.Set.String.empty,
    transactionIdsToLoad: Belt.Set.String.empty,
    uniswapDayDataIdsToLoad: Belt.Set.String.empty,
    dataLoadedActionsGetters: [],
  }

  /* Helper to append an ID to load for a given entity to the loadLayer */
  let extendIdsToLoad = (idsToLoad: idsToLoad, entityId: Types.id): idsToLoad =>
    idsToLoad->Belt.Set.String.add(entityId)

  /* Helper to append a getter for DataLoadedActions to load for a given entity to the loadLayer */
  let extendDataLoadedActionsGetters = (
    dataLoadedActionsGetters: dataLoadedActionsGetters,
    newDataLoadedActionsGetters: dataLoadedActionsGetters,
  ): dataLoadedActionsGetters =>
    dataLoadedActionsGetters->Belt.Array.concat(newDataLoadedActionsGetters)
}

//remove warning 39 for unused "rec" flag in case of no other related loaders
/**
Loader functions for each entity. The loader function extends a load layer with the given id and config.
*/
@warning("-39")
let rec bundleLinkedEntityLoader = (
  loadLayer: LoadLayer.t,
  ~entityId: string,
  ~inMemoryStore: InMemoryStore.t,
  ~bundleLoaderConfig: Types.bundleLoaderConfig,
): LoadLayer.t => {
  //No dataLoaded actions need to happen on the in memory
  //since there are no relational non-derivedfrom params
  let _ = inMemoryStore //ignore inMemoryStore and stop warning

  //In this case the "bundleLoaderConfig" type is a boolean.
  if !bundleLoaderConfig {
    //If bundleLoaderConfig is false, don't load the entity
    //simply return the current load layer
    loadLayer
  } else {
    //If bundleLoaderConfig is true,
    //extend the entity ids to load field
    //There can be no dataLoadedActionsGetters to add since this type does not contain
    //any non derived from relational params
    {
      ...loadLayer,
      bundleIdsToLoad: loadLayer.bundleIdsToLoad->LoadLayer.extendIdsToLoad(entityId),
    }
  }
}
@warning("-27")
and burnLinkedEntityLoader = (
  loadLayer: LoadLayer.t,
  ~entityId: string,
  ~inMemoryStore: InMemoryStore.t,
  ~burnLoaderConfig: Types.burnLoaderConfig,
): LoadLayer.t => {
  //An array of getter functions for dataLoaded actions that will be run
  //after the current load layer is executed
  let dataLoadedActionsGetters = [
    burnLoaderConfig.loadTransaction->Belt.Option.map(transactionLoaderConfig => {
      () =>
        inMemoryStore.burn
        ->InMemoryStore.Burn.get(entityId)
        ->Belt.Option.mapWithDefault([], entity => {
          //getLoader can be used to map arrays of ids, optional ids or single ids
          let getLoader = entityId =>
            transactionLinkedEntityLoader(~transactionLoaderConfig, ~entityId, ~inMemoryStore)
          //In this case entity.transaction is a single value. But we
          //still pass back an array of actions in order for cases where the related entity is an array of ids
          [entity.transaction_id->getLoader]
        })
    }),
    burnLoaderConfig.loadToken0->Belt.Option.map(tokenLoaderConfig => {
      () =>
        inMemoryStore.burn
        ->InMemoryStore.Burn.get(entityId)
        ->Belt.Option.mapWithDefault([], entity => {
          //getLoader can be used to map arrays of ids, optional ids or single ids
          let getLoader = entityId =>
            tokenLinkedEntityLoader(~tokenLoaderConfig, ~entityId, ~inMemoryStore)
          //In this case entity.token0 is a single value. But we
          //still pass back an array of actions in order for cases where the related entity is an array of ids
          [entity.token0_id->getLoader]
        })
    }),
    burnLoaderConfig.loadPool->Belt.Option.map(poolLoaderConfig => {
      () =>
        inMemoryStore.burn
        ->InMemoryStore.Burn.get(entityId)
        ->Belt.Option.mapWithDefault([], entity => {
          //getLoader can be used to map arrays of ids, optional ids or single ids
          let getLoader = entityId =>
            poolLinkedEntityLoader(~poolLoaderConfig, ~entityId, ~inMemoryStore)
          //In this case entity.pool is a single value. But we
          //still pass back an array of actions in order for cases where the related entity is an array of ids
          [entity.pool_id->getLoader]
        })
    }),
    burnLoaderConfig.loadToken1->Belt.Option.map(tokenLoaderConfig => {
      () =>
        inMemoryStore.burn
        ->InMemoryStore.Burn.get(entityId)
        ->Belt.Option.mapWithDefault([], entity => {
          //getLoader can be used to map arrays of ids, optional ids or single ids
          let getLoader = entityId =>
            tokenLinkedEntityLoader(~tokenLoaderConfig, ~entityId, ~inMemoryStore)
          //In this case entity.token1 is a single value. But we
          //still pass back an array of actions in order for cases where the related entity is an array of ids
          [entity.token1_id->getLoader]
        })
    }),
  ]->Belt.Array.keepMap(v => v)

  {
    ...loadLayer,
    burnIdsToLoad: loadLayer.burnIdsToLoad->LoadLayer.extendIdsToLoad(entityId),
    dataLoadedActionsGetters: loadLayer.dataLoadedActionsGetters->LoadLayer.extendDataLoadedActionsGetters(
      dataLoadedActionsGetters,
    ),
  }
}
@warning("-27")
and collectLinkedEntityLoader = (
  loadLayer: LoadLayer.t,
  ~entityId: string,
  ~inMemoryStore: InMemoryStore.t,
  ~collectLoaderConfig: Types.collectLoaderConfig,
): LoadLayer.t => {
  //An array of getter functions for dataLoaded actions that will be run
  //after the current load layer is executed
  let dataLoadedActionsGetters = [
    collectLoaderConfig.loadTransaction->Belt.Option.map(transactionLoaderConfig => {
      () =>
        inMemoryStore.collect
        ->InMemoryStore.Collect.get(entityId)
        ->Belt.Option.mapWithDefault([], entity => {
          //getLoader can be used to map arrays of ids, optional ids or single ids
          let getLoader = entityId =>
            transactionLinkedEntityLoader(~transactionLoaderConfig, ~entityId, ~inMemoryStore)
          //In this case entity.transaction is a single value. But we
          //still pass back an array of actions in order for cases where the related entity is an array of ids
          [entity.transaction_id->getLoader]
        })
    }),
    collectLoaderConfig.loadPool->Belt.Option.map(poolLoaderConfig => {
      () =>
        inMemoryStore.collect
        ->InMemoryStore.Collect.get(entityId)
        ->Belt.Option.mapWithDefault([], entity => {
          //getLoader can be used to map arrays of ids, optional ids or single ids
          let getLoader = entityId =>
            poolLinkedEntityLoader(~poolLoaderConfig, ~entityId, ~inMemoryStore)
          //In this case entity.pool is a single value. But we
          //still pass back an array of actions in order for cases where the related entity is an array of ids
          [entity.pool_id->getLoader]
        })
    }),
  ]->Belt.Array.keepMap(v => v)

  {
    ...loadLayer,
    collectIdsToLoad: loadLayer.collectIdsToLoad->LoadLayer.extendIdsToLoad(entityId),
    dataLoadedActionsGetters: loadLayer.dataLoadedActionsGetters->LoadLayer.extendDataLoadedActionsGetters(
      dataLoadedActionsGetters,
    ),
  }
}
@warning("-27")
and factoryLinkedEntityLoader = (
  loadLayer: LoadLayer.t,
  ~entityId: string,
  ~inMemoryStore: InMemoryStore.t,
  ~factoryLoaderConfig: Types.factoryLoaderConfig,
): LoadLayer.t => {
  //No dataLoaded actions need to happen on the in memory
  //since there are no relational non-derivedfrom params
  let _ = inMemoryStore //ignore inMemoryStore and stop warning

  //In this case the "factoryLoaderConfig" type is a boolean.
  if !factoryLoaderConfig {
    //If factoryLoaderConfig is false, don't load the entity
    //simply return the current load layer
    loadLayer
  } else {
    //If factoryLoaderConfig is true,
    //extend the entity ids to load field
    //There can be no dataLoadedActionsGetters to add since this type does not contain
    //any non derived from relational params
    {
      ...loadLayer,
      factoryIdsToLoad: loadLayer.factoryIdsToLoad->LoadLayer.extendIdsToLoad(entityId),
    }
  }
}
@warning("-27")
and flashLinkedEntityLoader = (
  loadLayer: LoadLayer.t,
  ~entityId: string,
  ~inMemoryStore: InMemoryStore.t,
  ~flashLoaderConfig: Types.flashLoaderConfig,
): LoadLayer.t => {
  //An array of getter functions for dataLoaded actions that will be run
  //after the current load layer is executed
  let dataLoadedActionsGetters = [
    flashLoaderConfig.loadPool->Belt.Option.map(poolLoaderConfig => {
      () =>
        inMemoryStore.flash
        ->InMemoryStore.Flash.get(entityId)
        ->Belt.Option.mapWithDefault([], entity => {
          //getLoader can be used to map arrays of ids, optional ids or single ids
          let getLoader = entityId =>
            poolLinkedEntityLoader(~poolLoaderConfig, ~entityId, ~inMemoryStore)
          //In this case entity.pool is a single value. But we
          //still pass back an array of actions in order for cases where the related entity is an array of ids
          [entity.pool_id->getLoader]
        })
    }),
    flashLoaderConfig.loadTransaction->Belt.Option.map(transactionLoaderConfig => {
      () =>
        inMemoryStore.flash
        ->InMemoryStore.Flash.get(entityId)
        ->Belt.Option.mapWithDefault([], entity => {
          //getLoader can be used to map arrays of ids, optional ids or single ids
          let getLoader = entityId =>
            transactionLinkedEntityLoader(~transactionLoaderConfig, ~entityId, ~inMemoryStore)
          //In this case entity.transaction is a single value. But we
          //still pass back an array of actions in order for cases where the related entity is an array of ids
          [entity.transaction_id->getLoader]
        })
    }),
  ]->Belt.Array.keepMap(v => v)

  {
    ...loadLayer,
    flashIdsToLoad: loadLayer.flashIdsToLoad->LoadLayer.extendIdsToLoad(entityId),
    dataLoadedActionsGetters: loadLayer.dataLoadedActionsGetters->LoadLayer.extendDataLoadedActionsGetters(
      dataLoadedActionsGetters,
    ),
  }
}
@warning("-27")
and mintLinkedEntityLoader = (
  loadLayer: LoadLayer.t,
  ~entityId: string,
  ~inMemoryStore: InMemoryStore.t,
  ~mintLoaderConfig: Types.mintLoaderConfig,
): LoadLayer.t => {
  //An array of getter functions for dataLoaded actions that will be run
  //after the current load layer is executed
  let dataLoadedActionsGetters = [
    mintLoaderConfig.loadToken0->Belt.Option.map(tokenLoaderConfig => {
      () =>
        inMemoryStore.mint
        ->InMemoryStore.Mint.get(entityId)
        ->Belt.Option.mapWithDefault([], entity => {
          //getLoader can be used to map arrays of ids, optional ids or single ids
          let getLoader = entityId =>
            tokenLinkedEntityLoader(~tokenLoaderConfig, ~entityId, ~inMemoryStore)
          //In this case entity.token0 is a single value. But we
          //still pass back an array of actions in order for cases where the related entity is an array of ids
          [entity.token0_id->getLoader]
        })
    }),
    mintLoaderConfig.loadTransaction->Belt.Option.map(transactionLoaderConfig => {
      () =>
        inMemoryStore.mint
        ->InMemoryStore.Mint.get(entityId)
        ->Belt.Option.mapWithDefault([], entity => {
          //getLoader can be used to map arrays of ids, optional ids or single ids
          let getLoader = entityId =>
            transactionLinkedEntityLoader(~transactionLoaderConfig, ~entityId, ~inMemoryStore)
          //In this case entity.transaction is a single value. But we
          //still pass back an array of actions in order for cases where the related entity is an array of ids
          [entity.transaction_id->getLoader]
        })
    }),
    mintLoaderConfig.loadPool->Belt.Option.map(poolLoaderConfig => {
      () =>
        inMemoryStore.mint
        ->InMemoryStore.Mint.get(entityId)
        ->Belt.Option.mapWithDefault([], entity => {
          //getLoader can be used to map arrays of ids, optional ids or single ids
          let getLoader = entityId =>
            poolLinkedEntityLoader(~poolLoaderConfig, ~entityId, ~inMemoryStore)
          //In this case entity.pool is a single value. But we
          //still pass back an array of actions in order for cases where the related entity is an array of ids
          [entity.pool_id->getLoader]
        })
    }),
    mintLoaderConfig.loadToken1->Belt.Option.map(tokenLoaderConfig => {
      () =>
        inMemoryStore.mint
        ->InMemoryStore.Mint.get(entityId)
        ->Belt.Option.mapWithDefault([], entity => {
          //getLoader can be used to map arrays of ids, optional ids or single ids
          let getLoader = entityId =>
            tokenLinkedEntityLoader(~tokenLoaderConfig, ~entityId, ~inMemoryStore)
          //In this case entity.token1 is a single value. But we
          //still pass back an array of actions in order for cases where the related entity is an array of ids
          [entity.token1_id->getLoader]
        })
    }),
  ]->Belt.Array.keepMap(v => v)

  {
    ...loadLayer,
    mintIdsToLoad: loadLayer.mintIdsToLoad->LoadLayer.extendIdsToLoad(entityId),
    dataLoadedActionsGetters: loadLayer.dataLoadedActionsGetters->LoadLayer.extendDataLoadedActionsGetters(
      dataLoadedActionsGetters,
    ),
  }
}
@warning("-27")
and poolLinkedEntityLoader = (
  loadLayer: LoadLayer.t,
  ~entityId: string,
  ~inMemoryStore: InMemoryStore.t,
  ~poolLoaderConfig: Types.poolLoaderConfig,
): LoadLayer.t => {
  //An array of getter functions for dataLoaded actions that will be run
  //after the current load layer is executed
  let dataLoadedActionsGetters = [
    poolLoaderConfig.loadToken1->Belt.Option.map(tokenLoaderConfig => {
      () =>
        inMemoryStore.pool
        ->InMemoryStore.Pool.get(entityId)
        ->Belt.Option.mapWithDefault([], entity => {
          //getLoader can be used to map arrays of ids, optional ids or single ids
          let getLoader = entityId =>
            tokenLinkedEntityLoader(~tokenLoaderConfig, ~entityId, ~inMemoryStore)
          //In this case entity.token1 is a single value. But we
          //still pass back an array of actions in order for cases where the related entity is an array of ids
          [entity.token1_id->getLoader]
        })
    }),
    poolLoaderConfig.loadToken0->Belt.Option.map(tokenLoaderConfig => {
      () =>
        inMemoryStore.pool
        ->InMemoryStore.Pool.get(entityId)
        ->Belt.Option.mapWithDefault([], entity => {
          //getLoader can be used to map arrays of ids, optional ids or single ids
          let getLoader = entityId =>
            tokenLinkedEntityLoader(~tokenLoaderConfig, ~entityId, ~inMemoryStore)
          //In this case entity.token0 is a single value. But we
          //still pass back an array of actions in order for cases where the related entity is an array of ids
          [entity.token0_id->getLoader]
        })
    }),
  ]->Belt.Array.keepMap(v => v)

  {
    ...loadLayer,
    poolIdsToLoad: loadLayer.poolIdsToLoad->LoadLayer.extendIdsToLoad(entityId),
    dataLoadedActionsGetters: loadLayer.dataLoadedActionsGetters->LoadLayer.extendDataLoadedActionsGetters(
      dataLoadedActionsGetters,
    ),
  }
}
@warning("-27")
and poolDayDataLinkedEntityLoader = (
  loadLayer: LoadLayer.t,
  ~entityId: string,
  ~inMemoryStore: InMemoryStore.t,
  ~poolDayDataLoaderConfig: Types.poolDayDataLoaderConfig,
): LoadLayer.t => {
  //An array of getter functions for dataLoaded actions that will be run
  //after the current load layer is executed
  let dataLoadedActionsGetters = [
    poolDayDataLoaderConfig.loadPool->Belt.Option.map(poolLoaderConfig => {
      () =>
        inMemoryStore.poolDayData
        ->InMemoryStore.PoolDayData.get(entityId)
        ->Belt.Option.mapWithDefault([], entity => {
          //getLoader can be used to map arrays of ids, optional ids or single ids
          let getLoader = entityId =>
            poolLinkedEntityLoader(~poolLoaderConfig, ~entityId, ~inMemoryStore)
          //In this case entity.pool is a single value. But we
          //still pass back an array of actions in order for cases where the related entity is an array of ids
          [entity.pool_id->getLoader]
        })
    }),
  ]->Belt.Array.keepMap(v => v)

  {
    ...loadLayer,
    poolDayDataIdsToLoad: loadLayer.poolDayDataIdsToLoad->LoadLayer.extendIdsToLoad(entityId),
    dataLoadedActionsGetters: loadLayer.dataLoadedActionsGetters->LoadLayer.extendDataLoadedActionsGetters(
      dataLoadedActionsGetters,
    ),
  }
}
@warning("-27")
and poolHourDataLinkedEntityLoader = (
  loadLayer: LoadLayer.t,
  ~entityId: string,
  ~inMemoryStore: InMemoryStore.t,
  ~poolHourDataLoaderConfig: Types.poolHourDataLoaderConfig,
): LoadLayer.t => {
  //An array of getter functions for dataLoaded actions that will be run
  //after the current load layer is executed
  let dataLoadedActionsGetters = [
    poolHourDataLoaderConfig.loadPool->Belt.Option.map(poolLoaderConfig => {
      () =>
        inMemoryStore.poolHourData
        ->InMemoryStore.PoolHourData.get(entityId)
        ->Belt.Option.mapWithDefault([], entity => {
          //getLoader can be used to map arrays of ids, optional ids or single ids
          let getLoader = entityId =>
            poolLinkedEntityLoader(~poolLoaderConfig, ~entityId, ~inMemoryStore)
          //In this case entity.pool is a single value. But we
          //still pass back an array of actions in order for cases where the related entity is an array of ids
          [entity.pool_id->getLoader]
        })
    }),
  ]->Belt.Array.keepMap(v => v)

  {
    ...loadLayer,
    poolHourDataIdsToLoad: loadLayer.poolHourDataIdsToLoad->LoadLayer.extendIdsToLoad(entityId),
    dataLoadedActionsGetters: loadLayer.dataLoadedActionsGetters->LoadLayer.extendDataLoadedActionsGetters(
      dataLoadedActionsGetters,
    ),
  }
}
@warning("-27")
and positionLinkedEntityLoader = (
  loadLayer: LoadLayer.t,
  ~entityId: string,
  ~inMemoryStore: InMemoryStore.t,
  ~positionLoaderConfig: Types.positionLoaderConfig,
): LoadLayer.t => {
  //An array of getter functions for dataLoaded actions that will be run
  //after the current load layer is executed
  let dataLoadedActionsGetters = [
    positionLoaderConfig.loadToken1->Belt.Option.map(tokenLoaderConfig => {
      () =>
        inMemoryStore.position
        ->InMemoryStore.Position.get(entityId)
        ->Belt.Option.mapWithDefault([], entity => {
          //getLoader can be used to map arrays of ids, optional ids or single ids
          let getLoader = entityId =>
            tokenLinkedEntityLoader(~tokenLoaderConfig, ~entityId, ~inMemoryStore)
          //In this case entity.token1 is a single value. But we
          //still pass back an array of actions in order for cases where the related entity is an array of ids
          [entity.token1_id->getLoader]
        })
    }),
    positionLoaderConfig.loadToken0->Belt.Option.map(tokenLoaderConfig => {
      () =>
        inMemoryStore.position
        ->InMemoryStore.Position.get(entityId)
        ->Belt.Option.mapWithDefault([], entity => {
          //getLoader can be used to map arrays of ids, optional ids or single ids
          let getLoader = entityId =>
            tokenLinkedEntityLoader(~tokenLoaderConfig, ~entityId, ~inMemoryStore)
          //In this case entity.token0 is a single value. But we
          //still pass back an array of actions in order for cases where the related entity is an array of ids
          [entity.token0_id->getLoader]
        })
    }),
    positionLoaderConfig.loadTickLower->Belt.Option.map(tickLoaderConfig => {
      () =>
        inMemoryStore.position
        ->InMemoryStore.Position.get(entityId)
        ->Belt.Option.mapWithDefault([], entity => {
          //getLoader can be used to map arrays of ids, optional ids or single ids
          let getLoader = entityId =>
            tickLinkedEntityLoader(~tickLoaderConfig, ~entityId, ~inMemoryStore)
          //In this case entity.tickLower is a single value. But we
          //still pass back an array of actions in order for cases where the related entity is an array of ids
          [entity.tickLower_id->getLoader]
        })
    }),
    positionLoaderConfig.loadTransaction->Belt.Option.map(transactionLoaderConfig => {
      () =>
        inMemoryStore.position
        ->InMemoryStore.Position.get(entityId)
        ->Belt.Option.mapWithDefault([], entity => {
          //getLoader can be used to map arrays of ids, optional ids or single ids
          let getLoader = entityId =>
            transactionLinkedEntityLoader(~transactionLoaderConfig, ~entityId, ~inMemoryStore)
          //In this case entity.transaction is a single value. But we
          //still pass back an array of actions in order for cases where the related entity is an array of ids
          [entity.transaction_id->getLoader]
        })
    }),
    positionLoaderConfig.loadPool->Belt.Option.map(poolLoaderConfig => {
      () =>
        inMemoryStore.position
        ->InMemoryStore.Position.get(entityId)
        ->Belt.Option.mapWithDefault([], entity => {
          //getLoader can be used to map arrays of ids, optional ids or single ids
          let getLoader = entityId =>
            poolLinkedEntityLoader(~poolLoaderConfig, ~entityId, ~inMemoryStore)
          //In this case entity.pool is a single value. But we
          //still pass back an array of actions in order for cases where the related entity is an array of ids
          [entity.pool_id->getLoader]
        })
    }),
    positionLoaderConfig.loadTickUpper->Belt.Option.map(tickLoaderConfig => {
      () =>
        inMemoryStore.position
        ->InMemoryStore.Position.get(entityId)
        ->Belt.Option.mapWithDefault([], entity => {
          //getLoader can be used to map arrays of ids, optional ids or single ids
          let getLoader = entityId =>
            tickLinkedEntityLoader(~tickLoaderConfig, ~entityId, ~inMemoryStore)
          //In this case entity.tickUpper is a single value. But we
          //still pass back an array of actions in order for cases where the related entity is an array of ids
          [entity.tickUpper_id->getLoader]
        })
    }),
  ]->Belt.Array.keepMap(v => v)

  {
    ...loadLayer,
    positionIdsToLoad: loadLayer.positionIdsToLoad->LoadLayer.extendIdsToLoad(entityId),
    dataLoadedActionsGetters: loadLayer.dataLoadedActionsGetters->LoadLayer.extendDataLoadedActionsGetters(
      dataLoadedActionsGetters,
    ),
  }
}
@warning("-27")
and positionSnapshotLinkedEntityLoader = (
  loadLayer: LoadLayer.t,
  ~entityId: string,
  ~inMemoryStore: InMemoryStore.t,
  ~positionSnapshotLoaderConfig: Types.positionSnapshotLoaderConfig,
): LoadLayer.t => {
  //An array of getter functions for dataLoaded actions that will be run
  //after the current load layer is executed
  let dataLoadedActionsGetters = [
    positionSnapshotLoaderConfig.loadPool->Belt.Option.map(poolLoaderConfig => {
      () =>
        inMemoryStore.positionSnapshot
        ->InMemoryStore.PositionSnapshot.get(entityId)
        ->Belt.Option.mapWithDefault([], entity => {
          //getLoader can be used to map arrays of ids, optional ids or single ids
          let getLoader = entityId =>
            poolLinkedEntityLoader(~poolLoaderConfig, ~entityId, ~inMemoryStore)
          //In this case entity.pool is a single value. But we
          //still pass back an array of actions in order for cases where the related entity is an array of ids
          [entity.pool_id->getLoader]
        })
    }),
    positionSnapshotLoaderConfig.loadPosition->Belt.Option.map(positionLoaderConfig => {
      () =>
        inMemoryStore.positionSnapshot
        ->InMemoryStore.PositionSnapshot.get(entityId)
        ->Belt.Option.mapWithDefault([], entity => {
          //getLoader can be used to map arrays of ids, optional ids or single ids
          let getLoader = entityId =>
            positionLinkedEntityLoader(~positionLoaderConfig, ~entityId, ~inMemoryStore)
          //In this case entity.position is a single value. But we
          //still pass back an array of actions in order for cases where the related entity is an array of ids
          [entity.position_id->getLoader]
        })
    }),
    positionSnapshotLoaderConfig.loadTransaction->Belt.Option.map(transactionLoaderConfig => {
      () =>
        inMemoryStore.positionSnapshot
        ->InMemoryStore.PositionSnapshot.get(entityId)
        ->Belt.Option.mapWithDefault([], entity => {
          //getLoader can be used to map arrays of ids, optional ids or single ids
          let getLoader = entityId =>
            transactionLinkedEntityLoader(~transactionLoaderConfig, ~entityId, ~inMemoryStore)
          //In this case entity.transaction is a single value. But we
          //still pass back an array of actions in order for cases where the related entity is an array of ids
          [entity.transaction_id->getLoader]
        })
    }),
  ]->Belt.Array.keepMap(v => v)

  {
    ...loadLayer,
    positionSnapshotIdsToLoad: loadLayer.positionSnapshotIdsToLoad->LoadLayer.extendIdsToLoad(
      entityId,
    ),
    dataLoadedActionsGetters: loadLayer.dataLoadedActionsGetters->LoadLayer.extendDataLoadedActionsGetters(
      dataLoadedActionsGetters,
    ),
  }
}
@warning("-27")
and swapLinkedEntityLoader = (
  loadLayer: LoadLayer.t,
  ~entityId: string,
  ~inMemoryStore: InMemoryStore.t,
  ~swapLoaderConfig: Types.swapLoaderConfig,
): LoadLayer.t => {
  //An array of getter functions for dataLoaded actions that will be run
  //after the current load layer is executed
  let dataLoadedActionsGetters = [
    swapLoaderConfig.loadTick->Belt.Option.map(tickLoaderConfig => {
      () =>
        inMemoryStore.swap
        ->InMemoryStore.Swap.get(entityId)
        ->Belt.Option.mapWithDefault([], entity => {
          //getLoader can be used to map arrays of ids, optional ids or single ids
          let getLoader = entityId =>
            tickLinkedEntityLoader(~tickLoaderConfig, ~entityId, ~inMemoryStore)
          //In this case entity.tick is a single value. But we
          //still pass back an array of actions in order for cases where the related entity is an array of ids
          [entity.tick_id->getLoader]
        })
    }),
    swapLoaderConfig.loadTransaction->Belt.Option.map(transactionLoaderConfig => {
      () =>
        inMemoryStore.swap
        ->InMemoryStore.Swap.get(entityId)
        ->Belt.Option.mapWithDefault([], entity => {
          //getLoader can be used to map arrays of ids, optional ids or single ids
          let getLoader = entityId =>
            transactionLinkedEntityLoader(~transactionLoaderConfig, ~entityId, ~inMemoryStore)
          //In this case entity.transaction is a single value. But we
          //still pass back an array of actions in order for cases where the related entity is an array of ids
          [entity.transaction_id->getLoader]
        })
    }),
    swapLoaderConfig.loadToken1->Belt.Option.map(tokenLoaderConfig => {
      () =>
        inMemoryStore.swap
        ->InMemoryStore.Swap.get(entityId)
        ->Belt.Option.mapWithDefault([], entity => {
          //getLoader can be used to map arrays of ids, optional ids or single ids
          let getLoader = entityId =>
            tokenLinkedEntityLoader(~tokenLoaderConfig, ~entityId, ~inMemoryStore)
          //In this case entity.token1 is a single value. But we
          //still pass back an array of actions in order for cases where the related entity is an array of ids
          [entity.token1_id->getLoader]
        })
    }),
    swapLoaderConfig.loadToken0->Belt.Option.map(tokenLoaderConfig => {
      () =>
        inMemoryStore.swap
        ->InMemoryStore.Swap.get(entityId)
        ->Belt.Option.mapWithDefault([], entity => {
          //getLoader can be used to map arrays of ids, optional ids or single ids
          let getLoader = entityId =>
            tokenLinkedEntityLoader(~tokenLoaderConfig, ~entityId, ~inMemoryStore)
          //In this case entity.token0 is a single value. But we
          //still pass back an array of actions in order for cases where the related entity is an array of ids
          [entity.token0_id->getLoader]
        })
    }),
    swapLoaderConfig.loadPool->Belt.Option.map(poolLoaderConfig => {
      () =>
        inMemoryStore.swap
        ->InMemoryStore.Swap.get(entityId)
        ->Belt.Option.mapWithDefault([], entity => {
          //getLoader can be used to map arrays of ids, optional ids or single ids
          let getLoader = entityId =>
            poolLinkedEntityLoader(~poolLoaderConfig, ~entityId, ~inMemoryStore)
          //In this case entity.pool is a single value. But we
          //still pass back an array of actions in order for cases where the related entity is an array of ids
          [entity.pool_id->getLoader]
        })
    }),
  ]->Belt.Array.keepMap(v => v)

  {
    ...loadLayer,
    swapIdsToLoad: loadLayer.swapIdsToLoad->LoadLayer.extendIdsToLoad(entityId),
    dataLoadedActionsGetters: loadLayer.dataLoadedActionsGetters->LoadLayer.extendDataLoadedActionsGetters(
      dataLoadedActionsGetters,
    ),
  }
}
@warning("-27")
and tickLinkedEntityLoader = (
  loadLayer: LoadLayer.t,
  ~entityId: string,
  ~inMemoryStore: InMemoryStore.t,
  ~tickLoaderConfig: Types.tickLoaderConfig,
): LoadLayer.t => {
  //An array of getter functions for dataLoaded actions that will be run
  //after the current load layer is executed
  let dataLoadedActionsGetters = [
    tickLoaderConfig.loadPool->Belt.Option.map(poolLoaderConfig => {
      () =>
        inMemoryStore.tick
        ->InMemoryStore.Tick.get(entityId)
        ->Belt.Option.mapWithDefault([], entity => {
          //getLoader can be used to map arrays of ids, optional ids or single ids
          let getLoader = entityId =>
            poolLinkedEntityLoader(~poolLoaderConfig, ~entityId, ~inMemoryStore)
          //In this case entity.pool is a single value. But we
          //still pass back an array of actions in order for cases where the related entity is an array of ids
          [entity.pool_id->getLoader]
        })
    }),
  ]->Belt.Array.keepMap(v => v)

  {
    ...loadLayer,
    tickIdsToLoad: loadLayer.tickIdsToLoad->LoadLayer.extendIdsToLoad(entityId),
    dataLoadedActionsGetters: loadLayer.dataLoadedActionsGetters->LoadLayer.extendDataLoadedActionsGetters(
      dataLoadedActionsGetters,
    ),
  }
}
@warning("-27")
and tickDayDataLinkedEntityLoader = (
  loadLayer: LoadLayer.t,
  ~entityId: string,
  ~inMemoryStore: InMemoryStore.t,
  ~tickDayDataLoaderConfig: Types.tickDayDataLoaderConfig,
): LoadLayer.t => {
  //An array of getter functions for dataLoaded actions that will be run
  //after the current load layer is executed
  let dataLoadedActionsGetters = [
    tickDayDataLoaderConfig.loadPool->Belt.Option.map(poolLoaderConfig => {
      () =>
        inMemoryStore.tickDayData
        ->InMemoryStore.TickDayData.get(entityId)
        ->Belt.Option.mapWithDefault([], entity => {
          //getLoader can be used to map arrays of ids, optional ids or single ids
          let getLoader = entityId =>
            poolLinkedEntityLoader(~poolLoaderConfig, ~entityId, ~inMemoryStore)
          //In this case entity.pool is a single value. But we
          //still pass back an array of actions in order for cases where the related entity is an array of ids
          [entity.pool_id->getLoader]
        })
    }),
    tickDayDataLoaderConfig.loadTick->Belt.Option.map(tickLoaderConfig => {
      () =>
        inMemoryStore.tickDayData
        ->InMemoryStore.TickDayData.get(entityId)
        ->Belt.Option.mapWithDefault([], entity => {
          //getLoader can be used to map arrays of ids, optional ids or single ids
          let getLoader = entityId =>
            tickLinkedEntityLoader(~tickLoaderConfig, ~entityId, ~inMemoryStore)
          //In this case entity.tick is a single value. But we
          //still pass back an array of actions in order for cases where the related entity is an array of ids
          [entity.tick_id->getLoader]
        })
    }),
  ]->Belt.Array.keepMap(v => v)

  {
    ...loadLayer,
    tickDayDataIdsToLoad: loadLayer.tickDayDataIdsToLoad->LoadLayer.extendIdsToLoad(entityId),
    dataLoadedActionsGetters: loadLayer.dataLoadedActionsGetters->LoadLayer.extendDataLoadedActionsGetters(
      dataLoadedActionsGetters,
    ),
  }
}
@warning("-27")
and tickHourDataLinkedEntityLoader = (
  loadLayer: LoadLayer.t,
  ~entityId: string,
  ~inMemoryStore: InMemoryStore.t,
  ~tickHourDataLoaderConfig: Types.tickHourDataLoaderConfig,
): LoadLayer.t => {
  //An array of getter functions for dataLoaded actions that will be run
  //after the current load layer is executed
  let dataLoadedActionsGetters = [
    tickHourDataLoaderConfig.loadTick->Belt.Option.map(tickLoaderConfig => {
      () =>
        inMemoryStore.tickHourData
        ->InMemoryStore.TickHourData.get(entityId)
        ->Belt.Option.mapWithDefault([], entity => {
          //getLoader can be used to map arrays of ids, optional ids or single ids
          let getLoader = entityId =>
            tickLinkedEntityLoader(~tickLoaderConfig, ~entityId, ~inMemoryStore)
          //In this case entity.tick is a single value. But we
          //still pass back an array of actions in order for cases where the related entity is an array of ids
          [entity.tick_id->getLoader]
        })
    }),
    tickHourDataLoaderConfig.loadPool->Belt.Option.map(poolLoaderConfig => {
      () =>
        inMemoryStore.tickHourData
        ->InMemoryStore.TickHourData.get(entityId)
        ->Belt.Option.mapWithDefault([], entity => {
          //getLoader can be used to map arrays of ids, optional ids or single ids
          let getLoader = entityId =>
            poolLinkedEntityLoader(~poolLoaderConfig, ~entityId, ~inMemoryStore)
          //In this case entity.pool is a single value. But we
          //still pass back an array of actions in order for cases where the related entity is an array of ids
          [entity.pool_id->getLoader]
        })
    }),
  ]->Belt.Array.keepMap(v => v)

  {
    ...loadLayer,
    tickHourDataIdsToLoad: loadLayer.tickHourDataIdsToLoad->LoadLayer.extendIdsToLoad(entityId),
    dataLoadedActionsGetters: loadLayer.dataLoadedActionsGetters->LoadLayer.extendDataLoadedActionsGetters(
      dataLoadedActionsGetters,
    ),
  }
}
@warning("-27")
and tokenLinkedEntityLoader = (
  loadLayer: LoadLayer.t,
  ~entityId: string,
  ~inMemoryStore: InMemoryStore.t,
  ~tokenLoaderConfig: Types.tokenLoaderConfig,
): LoadLayer.t => {
  //No dataLoaded actions need to happen on the in memory
  //since there are no relational non-derivedfrom params
  let _ = inMemoryStore //ignore inMemoryStore and stop warning

  //In this case the "tokenLoaderConfig" type is a boolean.
  if !tokenLoaderConfig {
    //If tokenLoaderConfig is false, don't load the entity
    //simply return the current load layer
    loadLayer
  } else {
    //If tokenLoaderConfig is true,
    //extend the entity ids to load field
    //There can be no dataLoadedActionsGetters to add since this type does not contain
    //any non derived from relational params
    {
      ...loadLayer,
      tokenIdsToLoad: loadLayer.tokenIdsToLoad->LoadLayer.extendIdsToLoad(entityId),
    }
  }
}
@warning("-27")
and tokenDayDataLinkedEntityLoader = (
  loadLayer: LoadLayer.t,
  ~entityId: string,
  ~inMemoryStore: InMemoryStore.t,
  ~tokenDayDataLoaderConfig: Types.tokenDayDataLoaderConfig,
): LoadLayer.t => {
  //An array of getter functions for dataLoaded actions that will be run
  //after the current load layer is executed
  let dataLoadedActionsGetters = [
    tokenDayDataLoaderConfig.loadToken->Belt.Option.map(tokenLoaderConfig => {
      () =>
        inMemoryStore.tokenDayData
        ->InMemoryStore.TokenDayData.get(entityId)
        ->Belt.Option.mapWithDefault([], entity => {
          //getLoader can be used to map arrays of ids, optional ids or single ids
          let getLoader = entityId =>
            tokenLinkedEntityLoader(~tokenLoaderConfig, ~entityId, ~inMemoryStore)
          //In this case entity.token is a single value. But we
          //still pass back an array of actions in order for cases where the related entity is an array of ids
          [entity.token_id->getLoader]
        })
    }),
  ]->Belt.Array.keepMap(v => v)

  {
    ...loadLayer,
    tokenDayDataIdsToLoad: loadLayer.tokenDayDataIdsToLoad->LoadLayer.extendIdsToLoad(entityId),
    dataLoadedActionsGetters: loadLayer.dataLoadedActionsGetters->LoadLayer.extendDataLoadedActionsGetters(
      dataLoadedActionsGetters,
    ),
  }
}
@warning("-27")
and tokenHourDataLinkedEntityLoader = (
  loadLayer: LoadLayer.t,
  ~entityId: string,
  ~inMemoryStore: InMemoryStore.t,
  ~tokenHourDataLoaderConfig: Types.tokenHourDataLoaderConfig,
): LoadLayer.t => {
  //An array of getter functions for dataLoaded actions that will be run
  //after the current load layer is executed
  let dataLoadedActionsGetters = [
    tokenHourDataLoaderConfig.loadToken->Belt.Option.map(tokenLoaderConfig => {
      () =>
        inMemoryStore.tokenHourData
        ->InMemoryStore.TokenHourData.get(entityId)
        ->Belt.Option.mapWithDefault([], entity => {
          //getLoader can be used to map arrays of ids, optional ids or single ids
          let getLoader = entityId =>
            tokenLinkedEntityLoader(~tokenLoaderConfig, ~entityId, ~inMemoryStore)
          //In this case entity.token is a single value. But we
          //still pass back an array of actions in order for cases where the related entity is an array of ids
          [entity.token_id->getLoader]
        })
    }),
  ]->Belt.Array.keepMap(v => v)

  {
    ...loadLayer,
    tokenHourDataIdsToLoad: loadLayer.tokenHourDataIdsToLoad->LoadLayer.extendIdsToLoad(entityId),
    dataLoadedActionsGetters: loadLayer.dataLoadedActionsGetters->LoadLayer.extendDataLoadedActionsGetters(
      dataLoadedActionsGetters,
    ),
  }
}
@warning("-27")
and tokenPoolWhitelistLinkedEntityLoader = (
  loadLayer: LoadLayer.t,
  ~entityId: string,
  ~inMemoryStore: InMemoryStore.t,
  ~tokenPoolWhitelistLoaderConfig: Types.tokenPoolWhitelistLoaderConfig,
): LoadLayer.t => {
  //An array of getter functions for dataLoaded actions that will be run
  //after the current load layer is executed
  let dataLoadedActionsGetters = [
    tokenPoolWhitelistLoaderConfig.loadToken->Belt.Option.map(tokenLoaderConfig => {
      () =>
        inMemoryStore.tokenPoolWhitelist
        ->InMemoryStore.TokenPoolWhitelist.get(entityId)
        ->Belt.Option.mapWithDefault([], entity => {
          //getLoader can be used to map arrays of ids, optional ids or single ids
          let getLoader = entityId =>
            tokenLinkedEntityLoader(~tokenLoaderConfig, ~entityId, ~inMemoryStore)
          //In this case entity.token is a single value. But we
          //still pass back an array of actions in order for cases where the related entity is an array of ids
          [entity.token_id->getLoader]
        })
    }),
    tokenPoolWhitelistLoaderConfig.loadPool->Belt.Option.map(poolLoaderConfig => {
      () =>
        inMemoryStore.tokenPoolWhitelist
        ->InMemoryStore.TokenPoolWhitelist.get(entityId)
        ->Belt.Option.mapWithDefault([], entity => {
          //getLoader can be used to map arrays of ids, optional ids or single ids
          let getLoader = entityId =>
            poolLinkedEntityLoader(~poolLoaderConfig, ~entityId, ~inMemoryStore)
          //In this case entity.pool is a single value. But we
          //still pass back an array of actions in order for cases where the related entity is an array of ids
          [entity.pool_id->getLoader]
        })
    }),
  ]->Belt.Array.keepMap(v => v)

  {
    ...loadLayer,
    tokenPoolWhitelistIdsToLoad: loadLayer.tokenPoolWhitelistIdsToLoad->LoadLayer.extendIdsToLoad(
      entityId,
    ),
    dataLoadedActionsGetters: loadLayer.dataLoadedActionsGetters->LoadLayer.extendDataLoadedActionsGetters(
      dataLoadedActionsGetters,
    ),
  }
}
@warning("-27")
and transactionLinkedEntityLoader = (
  loadLayer: LoadLayer.t,
  ~entityId: string,
  ~inMemoryStore: InMemoryStore.t,
  ~transactionLoaderConfig: Types.transactionLoaderConfig,
): LoadLayer.t => {
  //No dataLoaded actions need to happen on the in memory
  //since there are no relational non-derivedfrom params
  let _ = inMemoryStore //ignore inMemoryStore and stop warning

  //In this case the "transactionLoaderConfig" type is a boolean.
  if !transactionLoaderConfig {
    //If transactionLoaderConfig is false, don't load the entity
    //simply return the current load layer
    loadLayer
  } else {
    //If transactionLoaderConfig is true,
    //extend the entity ids to load field
    //There can be no dataLoadedActionsGetters to add since this type does not contain
    //any non derived from relational params
    {
      ...loadLayer,
      transactionIdsToLoad: loadLayer.transactionIdsToLoad->LoadLayer.extendIdsToLoad(entityId),
    }
  }
}
@warning("-27")
and uniswapDayDataLinkedEntityLoader = (
  loadLayer: LoadLayer.t,
  ~entityId: string,
  ~inMemoryStore: InMemoryStore.t,
  ~uniswapDayDataLoaderConfig: Types.uniswapDayDataLoaderConfig,
): LoadLayer.t => {
  //No dataLoaded actions need to happen on the in memory
  //since there are no relational non-derivedfrom params
  let _ = inMemoryStore //ignore inMemoryStore and stop warning

  //In this case the "uniswapDayDataLoaderConfig" type is a boolean.
  if !uniswapDayDataLoaderConfig {
    //If uniswapDayDataLoaderConfig is false, don't load the entity
    //simply return the current load layer
    loadLayer
  } else {
    //If uniswapDayDataLoaderConfig is true,
    //extend the entity ids to load field
    //There can be no dataLoadedActionsGetters to add since this type does not contain
    //any non derived from relational params
    {
      ...loadLayer,
      uniswapDayDataIdsToLoad: loadLayer.uniswapDayDataIdsToLoad->LoadLayer.extendIdsToLoad(
        entityId,
      ),
    }
  }
}

/**
Creates and populates a load layer with the current in memory store and an array of entityRead variants
*/
let getLoadLayer = (~entityBatch: array<Types.entityRead>, ~inMemoryStore) => {
  entityBatch->Belt.Array.reduce(LoadLayer.emptyLoadLayer(), (loadLayer, readEntity) => {
    switch readEntity {
    | BundleRead(entityId) =>
      loadLayer->bundleLinkedEntityLoader(~entityId, ~inMemoryStore, ~bundleLoaderConfig=true)
    | BurnRead(entityId, burnLoaderConfig) =>
      loadLayer->burnLinkedEntityLoader(~entityId, ~inMemoryStore, ~burnLoaderConfig)
    | CollectRead(entityId, collectLoaderConfig) =>
      loadLayer->collectLinkedEntityLoader(~entityId, ~inMemoryStore, ~collectLoaderConfig)
    | FactoryRead(entityId) =>
      loadLayer->factoryLinkedEntityLoader(~entityId, ~inMemoryStore, ~factoryLoaderConfig=true)
    | FlashRead(entityId, flashLoaderConfig) =>
      loadLayer->flashLinkedEntityLoader(~entityId, ~inMemoryStore, ~flashLoaderConfig)
    | MintRead(entityId, mintLoaderConfig) =>
      loadLayer->mintLinkedEntityLoader(~entityId, ~inMemoryStore, ~mintLoaderConfig)
    | PoolRead(entityId, poolLoaderConfig) =>
      loadLayer->poolLinkedEntityLoader(~entityId, ~inMemoryStore, ~poolLoaderConfig)
    | PoolDayDataRead(entityId, poolDayDataLoaderConfig) =>
      loadLayer->poolDayDataLinkedEntityLoader(~entityId, ~inMemoryStore, ~poolDayDataLoaderConfig)
    | PoolHourDataRead(entityId, poolHourDataLoaderConfig) =>
      loadLayer->poolHourDataLinkedEntityLoader(
        ~entityId,
        ~inMemoryStore,
        ~poolHourDataLoaderConfig,
      )
    | PositionRead(entityId, positionLoaderConfig) =>
      loadLayer->positionLinkedEntityLoader(~entityId, ~inMemoryStore, ~positionLoaderConfig)
    | PositionSnapshotRead(entityId, positionSnapshotLoaderConfig) =>
      loadLayer->positionSnapshotLinkedEntityLoader(
        ~entityId,
        ~inMemoryStore,
        ~positionSnapshotLoaderConfig,
      )
    | SwapRead(entityId, swapLoaderConfig) =>
      loadLayer->swapLinkedEntityLoader(~entityId, ~inMemoryStore, ~swapLoaderConfig)
    | TickRead(entityId, tickLoaderConfig) =>
      loadLayer->tickLinkedEntityLoader(~entityId, ~inMemoryStore, ~tickLoaderConfig)
    | TickDayDataRead(entityId, tickDayDataLoaderConfig) =>
      loadLayer->tickDayDataLinkedEntityLoader(~entityId, ~inMemoryStore, ~tickDayDataLoaderConfig)
    | TickHourDataRead(entityId, tickHourDataLoaderConfig) =>
      loadLayer->tickHourDataLinkedEntityLoader(
        ~entityId,
        ~inMemoryStore,
        ~tickHourDataLoaderConfig,
      )
    | TokenRead(entityId) =>
      loadLayer->tokenLinkedEntityLoader(~entityId, ~inMemoryStore, ~tokenLoaderConfig=true)
    | TokenDayDataRead(entityId, tokenDayDataLoaderConfig) =>
      loadLayer->tokenDayDataLinkedEntityLoader(
        ~entityId,
        ~inMemoryStore,
        ~tokenDayDataLoaderConfig,
      )
    | TokenHourDataRead(entityId, tokenHourDataLoaderConfig) =>
      loadLayer->tokenHourDataLinkedEntityLoader(
        ~entityId,
        ~inMemoryStore,
        ~tokenHourDataLoaderConfig,
      )
    | TokenPoolWhitelistRead(entityId, tokenPoolWhitelistLoaderConfig) =>
      loadLayer->tokenPoolWhitelistLinkedEntityLoader(
        ~entityId,
        ~inMemoryStore,
        ~tokenPoolWhitelistLoaderConfig,
      )
    | TransactionRead(entityId) =>
      loadLayer->transactionLinkedEntityLoader(
        ~entityId,
        ~inMemoryStore,
        ~transactionLoaderConfig=true,
      )
    | UniswapDayDataRead(entityId) =>
      loadLayer->uniswapDayDataLinkedEntityLoader(
        ~entityId,
        ~inMemoryStore,
        ~uniswapDayDataLoaderConfig=true,
      )
    }
  })
}

/**
Represents whether a deeper layer needs to be executed or whether the last layer
has been executed
*/
type nextLayer = NextLayer(LoadLayer.t) | LastLayer

let getNextLayer = (~loadLayer: LoadLayer.t) =>
  switch loadLayer.dataLoadedActionsGetters {
  | [] => LastLayer
  | dataLoadedActionsGetters =>
    dataLoadedActionsGetters
    ->Belt.Array.reduce(LoadLayer.emptyLoadLayer(), (loadLayer, getLoadedActions) => {
      //call getLoadedActions returns array of of actions to run against the load layer
      getLoadedActions()->Belt.Array.reduce(loadLayer, (loadLayer, action) => {
        action(loadLayer)
      })
    })
    ->NextLayer
  }

/**
Used for composing a loadlayer executor
*/
type entityExecutor<'executorRes> = {
  idsToLoad: LoadLayer.idsToLoad,
  executor: LoadLayer.idsToLoad => 'executorRes,
}

/**
Compose an execute load layer function. Used to compose an executor
for a postgres db or a mock db in the testing framework.
*/
let executeLoadLayerComposer = (
  ~entityExecutors: array<entityExecutor<'exectuorRes>>,
  ~handleResponses: array<'exectuorRes> => 'nextLoadlayer,
) => {
  entityExecutors
  ->Belt.Array.map(({idsToLoad, executor}) => {
    idsToLoad->executor
  })
  ->handleResponses
}

/**Recursively load layers with execute fn composer. Can be used with async or sync functions*/
let rec executeNestedLoadLayersComposer = (
  ~loadLayer,
  ~inMemoryStore,
  //Could be an execution function that is async or sync
  ~executeLoadLayerFn,
  //A call back function, for async or sync
  ~then,
  //Unit value, either wrapped in a promise or not
  ~unit,
) => {
  executeLoadLayerFn(~loadLayer, ~inMemoryStore)->then(res =>
    switch res {
    | LastLayer => unit
    | NextLayer(loadLayer) =>
      executeNestedLoadLayersComposer(~loadLayer, ~inMemoryStore, ~executeLoadLayerFn, ~then, ~unit)
    }
  )
}

/**Load all entities in the entity batch from the db to the inMemoryStore */
let loadEntitiesToInMemStoreComposer = (
  ~entityBatch,
  ~inMemoryStore,
  ~executeLoadLayerFn,
  ~then,
  ~unit,
) => {
  executeNestedLoadLayersComposer(
    ~inMemoryStore,
    ~loadLayer=getLoadLayer(~inMemoryStore, ~entityBatch),
    ~executeLoadLayerFn,
    ~then,
    ~unit,
  )
}

let makeEntityExecuterComposer = (
  ~idsToLoad,
  ~dbReadFn,
  ~inMemStoreSetFn,
  ~store,
  ~getEntiyId,
  ~unit,
  ~then,
) => {
  idsToLoad,
  executor: idsToLoad => {
    switch idsToLoad->Belt.Set.String.toArray {
    | [] => unit //Check if there are values so we don't create an unnecessary empty query
    | idsToLoad =>
      idsToLoad
      ->dbReadFn
      ->then(entities =>
        entities->Belt.Array.forEach(entity => {
          store->inMemStoreSetFn(~key=entity->getEntiyId, ~dbOp=Types.Read, ~entity)
        })
      )
    }
  },
}

/**
Specifically create an sql executor with async functionality
*/
let makeSqlEntityExecuter = (~idsToLoad, ~dbReadFn, ~inMemStoreSetFn, ~store, ~getEntiyId) => {
  makeEntityExecuterComposer(
    ~dbReadFn=DbFunctions.sql->dbReadFn,
    ~idsToLoad,
    ~getEntiyId,
    ~store,
    ~inMemStoreSetFn,
    ~then=Promise.thenResolve,
    ~unit=Promise.resolve(),
  )
}

/**
Executes a single load layer using the async sql functions
*/
let executeSqlLoadLayer = (~loadLayer: LoadLayer.t, ~inMemoryStore: InMemoryStore.t) => {
  let entityExecutors = [
    makeSqlEntityExecuter(
      ~idsToLoad=loadLayer.bundleIdsToLoad,
      ~dbReadFn=DbFunctions.Bundle.readEntities,
      ~inMemStoreSetFn=InMemoryStore.Bundle.set,
      ~store=inMemoryStore.bundle,
      ~getEntiyId=entity => entity.id,
    ),
    makeSqlEntityExecuter(
      ~idsToLoad=loadLayer.burnIdsToLoad,
      ~dbReadFn=DbFunctions.Burn.readEntities,
      ~inMemStoreSetFn=InMemoryStore.Burn.set,
      ~store=inMemoryStore.burn,
      ~getEntiyId=entity => entity.id,
    ),
    makeSqlEntityExecuter(
      ~idsToLoad=loadLayer.collectIdsToLoad,
      ~dbReadFn=DbFunctions.Collect.readEntities,
      ~inMemStoreSetFn=InMemoryStore.Collect.set,
      ~store=inMemoryStore.collect,
      ~getEntiyId=entity => entity.id,
    ),
    makeSqlEntityExecuter(
      ~idsToLoad=loadLayer.factoryIdsToLoad,
      ~dbReadFn=DbFunctions.Factory.readEntities,
      ~inMemStoreSetFn=InMemoryStore.Factory.set,
      ~store=inMemoryStore.factory,
      ~getEntiyId=entity => entity.id,
    ),
    makeSqlEntityExecuter(
      ~idsToLoad=loadLayer.flashIdsToLoad,
      ~dbReadFn=DbFunctions.Flash.readEntities,
      ~inMemStoreSetFn=InMemoryStore.Flash.set,
      ~store=inMemoryStore.flash,
      ~getEntiyId=entity => entity.id,
    ),
    makeSqlEntityExecuter(
      ~idsToLoad=loadLayer.mintIdsToLoad,
      ~dbReadFn=DbFunctions.Mint.readEntities,
      ~inMemStoreSetFn=InMemoryStore.Mint.set,
      ~store=inMemoryStore.mint,
      ~getEntiyId=entity => entity.id,
    ),
    makeSqlEntityExecuter(
      ~idsToLoad=loadLayer.poolIdsToLoad,
      ~dbReadFn=DbFunctions.Pool.readEntities,
      ~inMemStoreSetFn=InMemoryStore.Pool.set,
      ~store=inMemoryStore.pool,
      ~getEntiyId=entity => entity.id,
    ),
    makeSqlEntityExecuter(
      ~idsToLoad=loadLayer.poolDayDataIdsToLoad,
      ~dbReadFn=DbFunctions.PoolDayData.readEntities,
      ~inMemStoreSetFn=InMemoryStore.PoolDayData.set,
      ~store=inMemoryStore.poolDayData,
      ~getEntiyId=entity => entity.id,
    ),
    makeSqlEntityExecuter(
      ~idsToLoad=loadLayer.poolHourDataIdsToLoad,
      ~dbReadFn=DbFunctions.PoolHourData.readEntities,
      ~inMemStoreSetFn=InMemoryStore.PoolHourData.set,
      ~store=inMemoryStore.poolHourData,
      ~getEntiyId=entity => entity.id,
    ),
    makeSqlEntityExecuter(
      ~idsToLoad=loadLayer.positionIdsToLoad,
      ~dbReadFn=DbFunctions.Position.readEntities,
      ~inMemStoreSetFn=InMemoryStore.Position.set,
      ~store=inMemoryStore.position,
      ~getEntiyId=entity => entity.id,
    ),
    makeSqlEntityExecuter(
      ~idsToLoad=loadLayer.positionSnapshotIdsToLoad,
      ~dbReadFn=DbFunctions.PositionSnapshot.readEntities,
      ~inMemStoreSetFn=InMemoryStore.PositionSnapshot.set,
      ~store=inMemoryStore.positionSnapshot,
      ~getEntiyId=entity => entity.id,
    ),
    makeSqlEntityExecuter(
      ~idsToLoad=loadLayer.swapIdsToLoad,
      ~dbReadFn=DbFunctions.Swap.readEntities,
      ~inMemStoreSetFn=InMemoryStore.Swap.set,
      ~store=inMemoryStore.swap,
      ~getEntiyId=entity => entity.id,
    ),
    makeSqlEntityExecuter(
      ~idsToLoad=loadLayer.tickIdsToLoad,
      ~dbReadFn=DbFunctions.Tick.readEntities,
      ~inMemStoreSetFn=InMemoryStore.Tick.set,
      ~store=inMemoryStore.tick,
      ~getEntiyId=entity => entity.id,
    ),
    makeSqlEntityExecuter(
      ~idsToLoad=loadLayer.tickDayDataIdsToLoad,
      ~dbReadFn=DbFunctions.TickDayData.readEntities,
      ~inMemStoreSetFn=InMemoryStore.TickDayData.set,
      ~store=inMemoryStore.tickDayData,
      ~getEntiyId=entity => entity.id,
    ),
    makeSqlEntityExecuter(
      ~idsToLoad=loadLayer.tickHourDataIdsToLoad,
      ~dbReadFn=DbFunctions.TickHourData.readEntities,
      ~inMemStoreSetFn=InMemoryStore.TickHourData.set,
      ~store=inMemoryStore.tickHourData,
      ~getEntiyId=entity => entity.id,
    ),
    makeSqlEntityExecuter(
      ~idsToLoad=loadLayer.tokenIdsToLoad,
      ~dbReadFn=DbFunctions.Token.readEntities,
      ~inMemStoreSetFn=InMemoryStore.Token.set,
      ~store=inMemoryStore.token,
      ~getEntiyId=entity => entity.id,
    ),
    makeSqlEntityExecuter(
      ~idsToLoad=loadLayer.tokenDayDataIdsToLoad,
      ~dbReadFn=DbFunctions.TokenDayData.readEntities,
      ~inMemStoreSetFn=InMemoryStore.TokenDayData.set,
      ~store=inMemoryStore.tokenDayData,
      ~getEntiyId=entity => entity.id,
    ),
    makeSqlEntityExecuter(
      ~idsToLoad=loadLayer.tokenHourDataIdsToLoad,
      ~dbReadFn=DbFunctions.TokenHourData.readEntities,
      ~inMemStoreSetFn=InMemoryStore.TokenHourData.set,
      ~store=inMemoryStore.tokenHourData,
      ~getEntiyId=entity => entity.id,
    ),
    makeSqlEntityExecuter(
      ~idsToLoad=loadLayer.tokenPoolWhitelistIdsToLoad,
      ~dbReadFn=DbFunctions.TokenPoolWhitelist.readEntities,
      ~inMemStoreSetFn=InMemoryStore.TokenPoolWhitelist.set,
      ~store=inMemoryStore.tokenPoolWhitelist,
      ~getEntiyId=entity => entity.id,
    ),
    makeSqlEntityExecuter(
      ~idsToLoad=loadLayer.transactionIdsToLoad,
      ~dbReadFn=DbFunctions.Transaction.readEntities,
      ~inMemStoreSetFn=InMemoryStore.Transaction.set,
      ~store=inMemoryStore.transaction,
      ~getEntiyId=entity => entity.id,
    ),
    makeSqlEntityExecuter(
      ~idsToLoad=loadLayer.uniswapDayDataIdsToLoad,
      ~dbReadFn=DbFunctions.UniswapDayData.readEntities,
      ~inMemStoreSetFn=InMemoryStore.UniswapDayData.set,
      ~store=inMemoryStore.uniswapDayData,
      ~getEntiyId=entity => entity.id,
    ),
  ]
  let handleResponses = responses => {
    responses
    ->Promise.all
    ->Promise.thenResolve(_ => {
      getNextLayer(~loadLayer)
    })
  }

  executeLoadLayerComposer(~entityExecutors, ~handleResponses)
}

/**Execute loading of entities using sql*/
let loadEntitiesToInMemStore = (~entityBatch, ~inMemoryStore) => {
  loadEntitiesToInMemStoreComposer(
    ~inMemoryStore,
    ~entityBatch,
    ~executeLoadLayerFn=executeSqlLoadLayer,
    ~then=Promise.then,
    ~unit=Promise.resolve(),
  )
}

let executeEntityFunction = (
  sql: Postgres.sql,
  ~rows: array<Types.inMemoryStoreRow<'a>>,
  ~dbOp: Types.dbOp,
  ~dbFunction: (Postgres.sql, array<'b>) => promise<unit>,
  ~getInputValFromRow: Types.inMemoryStoreRow<'a> => 'b,
) => {
  let entityIds =
    rows->Belt.Array.keepMap(row => row.dbOp == dbOp ? Some(row->getInputValFromRow) : None)

  if entityIds->Array.length > 0 {
    sql->dbFunction(entityIds)
  } else {
    Promise.resolve()
  }
}

let executeSet = executeEntityFunction(~dbOp=Set)
let executeDelete = executeEntityFunction(~dbOp=Delete)

let executeSetSchemaEntity = (~entityEncoder) =>
  executeSet(~getInputValFromRow=row => {
    row.entity->entityEncoder
  })

let executeBatch = async (sql, ~inMemoryStore: InMemoryStore.t) => {
  let setEventSyncState = executeSet(
    ~dbFunction=DbFunctions.EventSyncState.batchSet,
    ~getInputValFromRow=row => row.entity,
    ~rows=inMemoryStore.eventSyncState->InMemoryStore.EventSyncState.values,
  )

  let setRawEvents = executeSet(
    ~dbFunction=DbFunctions.RawEvents.batchSet,
    ~getInputValFromRow=row => row.entity,
    ~rows=inMemoryStore.rawEvents->InMemoryStore.RawEvents.values,
  )

  let setDynamicContracts = executeSet(
    ~dbFunction=DbFunctions.DynamicContractRegistry.batchSet,
    ~rows=inMemoryStore.dynamicContractRegistry->InMemoryStore.DynamicContractRegistry.values,
    ~getInputValFromRow={row => row.entity},
  )

  let deleteBundles = executeDelete(
    ~dbFunction=DbFunctions.Bundle.batchDelete,
    ~rows=inMemoryStore.bundle->InMemoryStore.Bundle.values,
    ~getInputValFromRow={row => row.entity.id},
  )

  let setBundles = executeSetSchemaEntity(
    ~dbFunction=DbFunctions.Bundle.batchSet,
    ~rows=inMemoryStore.bundle->InMemoryStore.Bundle.values,
    ~entityEncoder=Types.bundleEntity_encode,
  )

  let deleteBurns = executeDelete(
    ~dbFunction=DbFunctions.Burn.batchDelete,
    ~rows=inMemoryStore.burn->InMemoryStore.Burn.values,
    ~getInputValFromRow={row => row.entity.id},
  )

  let setBurns = executeSetSchemaEntity(
    ~dbFunction=DbFunctions.Burn.batchSet,
    ~rows=inMemoryStore.burn->InMemoryStore.Burn.values,
    ~entityEncoder=Types.burnEntity_encode,
  )

  let deleteCollects = executeDelete(
    ~dbFunction=DbFunctions.Collect.batchDelete,
    ~rows=inMemoryStore.collect->InMemoryStore.Collect.values,
    ~getInputValFromRow={row => row.entity.id},
  )

  let setCollects = executeSetSchemaEntity(
    ~dbFunction=DbFunctions.Collect.batchSet,
    ~rows=inMemoryStore.collect->InMemoryStore.Collect.values,
    ~entityEncoder=Types.collectEntity_encode,
  )

  let deleteFactorys = executeDelete(
    ~dbFunction=DbFunctions.Factory.batchDelete,
    ~rows=inMemoryStore.factory->InMemoryStore.Factory.values,
    ~getInputValFromRow={row => row.entity.id},
  )

  let setFactorys = executeSetSchemaEntity(
    ~dbFunction=DbFunctions.Factory.batchSet,
    ~rows=inMemoryStore.factory->InMemoryStore.Factory.values,
    ~entityEncoder=Types.factoryEntity_encode,
  )

  let deleteFlashs = executeDelete(
    ~dbFunction=DbFunctions.Flash.batchDelete,
    ~rows=inMemoryStore.flash->InMemoryStore.Flash.values,
    ~getInputValFromRow={row => row.entity.id},
  )

  let setFlashs = executeSetSchemaEntity(
    ~dbFunction=DbFunctions.Flash.batchSet,
    ~rows=inMemoryStore.flash->InMemoryStore.Flash.values,
    ~entityEncoder=Types.flashEntity_encode,
  )

  let deleteMints = executeDelete(
    ~dbFunction=DbFunctions.Mint.batchDelete,
    ~rows=inMemoryStore.mint->InMemoryStore.Mint.values,
    ~getInputValFromRow={row => row.entity.id},
  )

  let setMints = executeSetSchemaEntity(
    ~dbFunction=DbFunctions.Mint.batchSet,
    ~rows=inMemoryStore.mint->InMemoryStore.Mint.values,
    ~entityEncoder=Types.mintEntity_encode,
  )

  let deletePools = executeDelete(
    ~dbFunction=DbFunctions.Pool.batchDelete,
    ~rows=inMemoryStore.pool->InMemoryStore.Pool.values,
    ~getInputValFromRow={row => row.entity.id},
  )

  let setPools = executeSetSchemaEntity(
    ~dbFunction=DbFunctions.Pool.batchSet,
    ~rows=inMemoryStore.pool->InMemoryStore.Pool.values,
    ~entityEncoder=Types.poolEntity_encode,
  )

  let deletePoolDayDatas = executeDelete(
    ~dbFunction=DbFunctions.PoolDayData.batchDelete,
    ~rows=inMemoryStore.poolDayData->InMemoryStore.PoolDayData.values,
    ~getInputValFromRow={row => row.entity.id},
  )

  let setPoolDayDatas = executeSetSchemaEntity(
    ~dbFunction=DbFunctions.PoolDayData.batchSet,
    ~rows=inMemoryStore.poolDayData->InMemoryStore.PoolDayData.values,
    ~entityEncoder=Types.poolDayDataEntity_encode,
  )

  let deletePoolHourDatas = executeDelete(
    ~dbFunction=DbFunctions.PoolHourData.batchDelete,
    ~rows=inMemoryStore.poolHourData->InMemoryStore.PoolHourData.values,
    ~getInputValFromRow={row => row.entity.id},
  )

  let setPoolHourDatas = executeSetSchemaEntity(
    ~dbFunction=DbFunctions.PoolHourData.batchSet,
    ~rows=inMemoryStore.poolHourData->InMemoryStore.PoolHourData.values,
    ~entityEncoder=Types.poolHourDataEntity_encode,
  )

  let deletePositions = executeDelete(
    ~dbFunction=DbFunctions.Position.batchDelete,
    ~rows=inMemoryStore.position->InMemoryStore.Position.values,
    ~getInputValFromRow={row => row.entity.id},
  )

  let setPositions = executeSetSchemaEntity(
    ~dbFunction=DbFunctions.Position.batchSet,
    ~rows=inMemoryStore.position->InMemoryStore.Position.values,
    ~entityEncoder=Types.positionEntity_encode,
  )

  let deletePositionSnapshots = executeDelete(
    ~dbFunction=DbFunctions.PositionSnapshot.batchDelete,
    ~rows=inMemoryStore.positionSnapshot->InMemoryStore.PositionSnapshot.values,
    ~getInputValFromRow={row => row.entity.id},
  )

  let setPositionSnapshots = executeSetSchemaEntity(
    ~dbFunction=DbFunctions.PositionSnapshot.batchSet,
    ~rows=inMemoryStore.positionSnapshot->InMemoryStore.PositionSnapshot.values,
    ~entityEncoder=Types.positionSnapshotEntity_encode,
  )

  let deleteSwaps = executeDelete(
    ~dbFunction=DbFunctions.Swap.batchDelete,
    ~rows=inMemoryStore.swap->InMemoryStore.Swap.values,
    ~getInputValFromRow={row => row.entity.id},
  )

  let setSwaps = executeSetSchemaEntity(
    ~dbFunction=DbFunctions.Swap.batchSet,
    ~rows=inMemoryStore.swap->InMemoryStore.Swap.values,
    ~entityEncoder=Types.swapEntity_encode,
  )

  let deleteTicks = executeDelete(
    ~dbFunction=DbFunctions.Tick.batchDelete,
    ~rows=inMemoryStore.tick->InMemoryStore.Tick.values,
    ~getInputValFromRow={row => row.entity.id},
  )

  let setTicks = executeSetSchemaEntity(
    ~dbFunction=DbFunctions.Tick.batchSet,
    ~rows=inMemoryStore.tick->InMemoryStore.Tick.values,
    ~entityEncoder=Types.tickEntity_encode,
  )

  let deleteTickDayDatas = executeDelete(
    ~dbFunction=DbFunctions.TickDayData.batchDelete,
    ~rows=inMemoryStore.tickDayData->InMemoryStore.TickDayData.values,
    ~getInputValFromRow={row => row.entity.id},
  )

  let setTickDayDatas = executeSetSchemaEntity(
    ~dbFunction=DbFunctions.TickDayData.batchSet,
    ~rows=inMemoryStore.tickDayData->InMemoryStore.TickDayData.values,
    ~entityEncoder=Types.tickDayDataEntity_encode,
  )

  let deleteTickHourDatas = executeDelete(
    ~dbFunction=DbFunctions.TickHourData.batchDelete,
    ~rows=inMemoryStore.tickHourData->InMemoryStore.TickHourData.values,
    ~getInputValFromRow={row => row.entity.id},
  )

  let setTickHourDatas = executeSetSchemaEntity(
    ~dbFunction=DbFunctions.TickHourData.batchSet,
    ~rows=inMemoryStore.tickHourData->InMemoryStore.TickHourData.values,
    ~entityEncoder=Types.tickHourDataEntity_encode,
  )

  let deleteTokens = executeDelete(
    ~dbFunction=DbFunctions.Token.batchDelete,
    ~rows=inMemoryStore.token->InMemoryStore.Token.values,
    ~getInputValFromRow={row => row.entity.id},
  )

  let setTokens = executeSetSchemaEntity(
    ~dbFunction=DbFunctions.Token.batchSet,
    ~rows=inMemoryStore.token->InMemoryStore.Token.values,
    ~entityEncoder=Types.tokenEntity_encode,
  )

  let deleteTokenDayDatas = executeDelete(
    ~dbFunction=DbFunctions.TokenDayData.batchDelete,
    ~rows=inMemoryStore.tokenDayData->InMemoryStore.TokenDayData.values,
    ~getInputValFromRow={row => row.entity.id},
  )

  let setTokenDayDatas = executeSetSchemaEntity(
    ~dbFunction=DbFunctions.TokenDayData.batchSet,
    ~rows=inMemoryStore.tokenDayData->InMemoryStore.TokenDayData.values,
    ~entityEncoder=Types.tokenDayDataEntity_encode,
  )

  let deleteTokenHourDatas = executeDelete(
    ~dbFunction=DbFunctions.TokenHourData.batchDelete,
    ~rows=inMemoryStore.tokenHourData->InMemoryStore.TokenHourData.values,
    ~getInputValFromRow={row => row.entity.id},
  )

  let setTokenHourDatas = executeSetSchemaEntity(
    ~dbFunction=DbFunctions.TokenHourData.batchSet,
    ~rows=inMemoryStore.tokenHourData->InMemoryStore.TokenHourData.values,
    ~entityEncoder=Types.tokenHourDataEntity_encode,
  )

  let deleteTokenPoolWhitelists = executeDelete(
    ~dbFunction=DbFunctions.TokenPoolWhitelist.batchDelete,
    ~rows=inMemoryStore.tokenPoolWhitelist->InMemoryStore.TokenPoolWhitelist.values,
    ~getInputValFromRow={row => row.entity.id},
  )

  let setTokenPoolWhitelists = executeSetSchemaEntity(
    ~dbFunction=DbFunctions.TokenPoolWhitelist.batchSet,
    ~rows=inMemoryStore.tokenPoolWhitelist->InMemoryStore.TokenPoolWhitelist.values,
    ~entityEncoder=Types.tokenPoolWhitelistEntity_encode,
  )

  let deleteTransactions = executeDelete(
    ~dbFunction=DbFunctions.Transaction.batchDelete,
    ~rows=inMemoryStore.transaction->InMemoryStore.Transaction.values,
    ~getInputValFromRow={row => row.entity.id},
  )

  let setTransactions = executeSetSchemaEntity(
    ~dbFunction=DbFunctions.Transaction.batchSet,
    ~rows=inMemoryStore.transaction->InMemoryStore.Transaction.values,
    ~entityEncoder=Types.transactionEntity_encode,
  )

  let deleteUniswapDayDatas = executeDelete(
    ~dbFunction=DbFunctions.UniswapDayData.batchDelete,
    ~rows=inMemoryStore.uniswapDayData->InMemoryStore.UniswapDayData.values,
    ~getInputValFromRow={row => row.entity.id},
  )

  let setUniswapDayDatas = executeSetSchemaEntity(
    ~dbFunction=DbFunctions.UniswapDayData.batchSet,
    ~rows=inMemoryStore.uniswapDayData->InMemoryStore.UniswapDayData.values,
    ~entityEncoder=Types.uniswapDayDataEntity_encode,
  )

  let res = await sql->Postgres.beginSql(sql => {
    [
      setEventSyncState,
      setRawEvents,
      setDynamicContracts,
      deleteBundles,
      setBundles,
      deleteBurns,
      setBurns,
      deleteCollects,
      setCollects,
      deleteFactorys,
      setFactorys,
      deleteFlashs,
      setFlashs,
      deleteMints,
      setMints,
      deletePools,
      setPools,
      deletePoolDayDatas,
      setPoolDayDatas,
      deletePoolHourDatas,
      setPoolHourDatas,
      deletePositions,
      setPositions,
      deletePositionSnapshots,
      setPositionSnapshots,
      deleteSwaps,
      setSwaps,
      deleteTicks,
      setTicks,
      deleteTickDayDatas,
      setTickDayDatas,
      deleteTickHourDatas,
      setTickHourDatas,
      deleteTokens,
      setTokens,
      deleteTokenDayDatas,
      setTokenDayDatas,
      deleteTokenHourDatas,
      setTokenHourDatas,
      deleteTokenPoolWhitelists,
      setTokenPoolWhitelists,
      deleteTransactions,
      setTransactions,
      deleteUniswapDayDatas,
      setUniswapDayDatas,
    ]->Belt.Array.map(dbFunc => sql->dbFunc)
  })

  res
}
