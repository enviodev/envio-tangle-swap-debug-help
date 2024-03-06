let config: Postgres.poolConfig = {
  ...Config.db,
  transform: {undefined: Js.null},
}
let sql = Postgres.makeSql(~config)

type chainId = int
type eventId = string
type blockNumberRow = {@as("block_number") blockNumber: int}

module ChainMetadata = {
  type chainMetadata = {
    @as("chain_id") chainId: int,
    @as("block_height") blockHeight: int,
    @as("start_block") startBlock: int,
  }

  @module("./DbFunctionsImplementation.js")
  external setChainMetadata: (Postgres.sql, chainMetadata) => promise<unit> = "setChainMetadata"

  let setChainMetadataRow = (~chainId, ~startBlock, ~blockHeight) => {
    sql->setChainMetadata({chainId, startBlock, blockHeight})
  }
}

module EventSyncState = {
  @genType
  type eventSyncState = {
    @as("chain_id") chainId: int,
    @as("block_number") blockNumber: int,
    @as("log_index") logIndex: int,
    @as("transaction_index") transactionIndex: int,
    @as("block_timestamp") blockTimestamp: int,
  }
  @module("./DbFunctionsImplementation.js")
  external readLatestSyncedEventOnChainIdArr: (
    Postgres.sql,
    ~chainId: int,
  ) => promise<array<eventSyncState>> = "readLatestSyncedEventOnChainId"

  let readLatestSyncedEventOnChainId = async (sql, ~chainId) => {
    let arr = await sql->readLatestSyncedEventOnChainIdArr(~chainId)
    arr->Belt.Array.get(0)
  }

  let getLatestProcessedBlockNumber = async (~chainId) => {
    let latestEventOpt = await sql->readLatestSyncedEventOnChainId(~chainId)
    latestEventOpt->Belt.Option.map(event => event.blockNumber)
  }

  @module("./DbFunctionsImplementation.js")
  external batchSet: (Postgres.sql, array<eventSyncState>) => promise<unit> =
    "batchSetEventSyncState"
}

module RawEvents = {
  type rawEventRowId = (chainId, eventId)
  @module("./DbFunctionsImplementation.js")
  external batchSet: (Postgres.sql, array<Types.rawEventsEntity>) => promise<unit> =
    "batchSetRawEvents"

  @module("./DbFunctionsImplementation.js")
  external batchDelete: (Postgres.sql, array<rawEventRowId>) => promise<unit> =
    "batchDeleteRawEvents"

  @module("./DbFunctionsImplementation.js")
  external readEntities: (
    Postgres.sql,
    array<rawEventRowId>,
  ) => promise<array<Types.rawEventsEntity>> = "readRawEventsEntities"

  @module("./DbFunctionsImplementation.js")
  external getRawEventsPageGtOrEqEventId: (
    Postgres.sql,
    ~chainId: chainId,
    ~eventId: Ethers.BigInt.t,
    ~limit: int,
    ~contractAddresses: array<Ethers.ethAddress>,
  ) => promise<array<Types.rawEventsEntity>> = "getRawEventsPageGtOrEqEventId"

  @module("./DbFunctionsImplementation.js")
  external getRawEventsPageWithinEventIdRangeInclusive: (
    Postgres.sql,
    ~chainId: chainId,
    ~fromEventIdInclusive: Ethers.BigInt.t,
    ~toEventIdInclusive: Ethers.BigInt.t,
    ~limit: int,
    ~contractAddresses: array<Ethers.ethAddress>,
  ) => promise<array<Types.rawEventsEntity>> = "getRawEventsPageWithinEventIdRangeInclusive"

  ///Returns an array with 1 block number (the highest processed on the given chainId)
  @module("./DbFunctionsImplementation.js")
  external readLatestRawEventsBlockNumberProcessedOnChainId: (
    Postgres.sql,
    chainId,
  ) => promise<array<blockNumberRow>> = "readLatestRawEventsBlockNumberProcessedOnChainId"

  let getLatestProcessedBlockNumber = async (~chainId) => {
    let row = await sql->readLatestRawEventsBlockNumberProcessedOnChainId(chainId)

    row->Belt.Array.get(0)->Belt.Option.map(row => row.blockNumber)
  }
}

module DynamicContractRegistry = {
  type contractAddress = Ethers.ethAddress
  type dynamicContractRegistryRowId = (chainId, contractAddress)
  @module("./DbFunctionsImplementation.js")
  external batchSet: (Postgres.sql, array<Types.dynamicContractRegistryEntity>) => promise<unit> =
    "batchSetDynamicContractRegistry"

  @module("./DbFunctionsImplementation.js")
  external batchDelete: (Postgres.sql, array<dynamicContractRegistryRowId>) => promise<unit> =
    "batchDeleteDynamicContractRegistry"

  @module("./DbFunctionsImplementation.js")
  external readEntities: (
    Postgres.sql,
    array<dynamicContractRegistryRowId>,
  ) => promise<array<Types.dynamicContractRegistryEntity>> = "readDynamicContractRegistryEntities"

  type contractTypeAndAddress = {
    @as("contract_address") contractAddress: Ethers.ethAddress,
    @as("contract_type") contractType: string,
    @as("event_id") eventId: Ethers.BigInt.t,
  }

  ///Returns an array with 1 block number (the highest processed on the given chainId)
  @module("./DbFunctionsImplementation.js")
  external readDynamicContractsOnChainIdAtOrBeforeBlock: (
    Postgres.sql,
    ~chainId: chainId,
    ~startBlock: int,
  ) => promise<array<contractTypeAndAddress>> = "readDynamicContractsOnChainIdAtOrBeforeBlock"
}

module Bundle = {
  open Types

  let decodeUnsafe = (entityJson: Js.Json.t): bundleEntity => {
    let entityDecoded = switch entityJson->bundleEntity_decode {
    | Ok(v) => Ok(v)
    | Error(e) =>
      Logging.error({
        "err": e,
        "msg": "EE700: Unable to parse row from database of entity bundle using spice",
        "raw_unparsed_object": entityJson,
      })
      Error(e)
    }->Belt.Result.getExn

    entityDecoded
  }

  @module("./DbFunctionsImplementation.js")
  external batchSet: (Postgres.sql, array<Js.Json.t>) => promise<unit> = "batchSetBundle"

  @module("./DbFunctionsImplementation.js")
  external batchDelete: (Postgres.sql, array<Types.id>) => promise<unit> = "batchDeleteBundle"

  @module("./DbFunctionsImplementation.js")
  external readEntitiesFromDb: (Postgres.sql, array<Types.id>) => promise<array<Js.Json.t>> =
    "readBundleEntities"

  let readEntities = async (sql: Postgres.sql, ids: array<Types.id>): array<bundleEntity> => {
    let res = await readEntitiesFromDb(sql, ids)
    res->Belt.Array.map(entityJson => entityJson->decodeUnsafe)
  }
}
module Burn = {
  open Types

  let decodeUnsafe = (entityJson: Js.Json.t): burnEntity => {
    let entityDecoded = switch entityJson->burnEntity_decode {
    | Ok(v) => Ok(v)
    | Error(e) =>
      Logging.error({
        "err": e,
        "msg": "EE700: Unable to parse row from database of entity burn using spice",
        "raw_unparsed_object": entityJson,
      })
      Error(e)
    }->Belt.Result.getExn

    entityDecoded
  }

  @module("./DbFunctionsImplementation.js")
  external batchSet: (Postgres.sql, array<Js.Json.t>) => promise<unit> = "batchSetBurn"

  @module("./DbFunctionsImplementation.js")
  external batchDelete: (Postgres.sql, array<Types.id>) => promise<unit> = "batchDeleteBurn"

  @module("./DbFunctionsImplementation.js")
  external readEntitiesFromDb: (Postgres.sql, array<Types.id>) => promise<array<Js.Json.t>> =
    "readBurnEntities"

  let readEntities = async (sql: Postgres.sql, ids: array<Types.id>): array<burnEntity> => {
    let res = await readEntitiesFromDb(sql, ids)
    res->Belt.Array.map(entityJson => entityJson->decodeUnsafe)
  }
}
module Collect = {
  open Types

  let decodeUnsafe = (entityJson: Js.Json.t): collectEntity => {
    let entityDecoded = switch entityJson->collectEntity_decode {
    | Ok(v) => Ok(v)
    | Error(e) =>
      Logging.error({
        "err": e,
        "msg": "EE700: Unable to parse row from database of entity collect using spice",
        "raw_unparsed_object": entityJson,
      })
      Error(e)
    }->Belt.Result.getExn

    entityDecoded
  }

  @module("./DbFunctionsImplementation.js")
  external batchSet: (Postgres.sql, array<Js.Json.t>) => promise<unit> = "batchSetCollect"

  @module("./DbFunctionsImplementation.js")
  external batchDelete: (Postgres.sql, array<Types.id>) => promise<unit> = "batchDeleteCollect"

  @module("./DbFunctionsImplementation.js")
  external readEntitiesFromDb: (Postgres.sql, array<Types.id>) => promise<array<Js.Json.t>> =
    "readCollectEntities"

  let readEntities = async (sql: Postgres.sql, ids: array<Types.id>): array<collectEntity> => {
    let res = await readEntitiesFromDb(sql, ids)
    res->Belt.Array.map(entityJson => entityJson->decodeUnsafe)
  }
}
module Factory = {
  open Types

  let decodeUnsafe = (entityJson: Js.Json.t): factoryEntity => {
    let entityDecoded = switch entityJson->factoryEntity_decode {
    | Ok(v) => Ok(v)
    | Error(e) =>
      Logging.error({
        "err": e,
        "msg": "EE700: Unable to parse row from database of entity factory using spice",
        "raw_unparsed_object": entityJson,
      })
      Error(e)
    }->Belt.Result.getExn

    entityDecoded
  }

  @module("./DbFunctionsImplementation.js")
  external batchSet: (Postgres.sql, array<Js.Json.t>) => promise<unit> = "batchSetFactory"

  @module("./DbFunctionsImplementation.js")
  external batchDelete: (Postgres.sql, array<Types.id>) => promise<unit> = "batchDeleteFactory"

  @module("./DbFunctionsImplementation.js")
  external readEntitiesFromDb: (Postgres.sql, array<Types.id>) => promise<array<Js.Json.t>> =
    "readFactoryEntities"

  let readEntities = async (sql: Postgres.sql, ids: array<Types.id>): array<factoryEntity> => {
    let res = await readEntitiesFromDb(sql, ids)
    res->Belt.Array.map(entityJson => entityJson->decodeUnsafe)
  }
}
module Flash = {
  open Types

  let decodeUnsafe = (entityJson: Js.Json.t): flashEntity => {
    let entityDecoded = switch entityJson->flashEntity_decode {
    | Ok(v) => Ok(v)
    | Error(e) =>
      Logging.error({
        "err": e,
        "msg": "EE700: Unable to parse row from database of entity flash using spice",
        "raw_unparsed_object": entityJson,
      })
      Error(e)
    }->Belt.Result.getExn

    entityDecoded
  }

  @module("./DbFunctionsImplementation.js")
  external batchSet: (Postgres.sql, array<Js.Json.t>) => promise<unit> = "batchSetFlash"

  @module("./DbFunctionsImplementation.js")
  external batchDelete: (Postgres.sql, array<Types.id>) => promise<unit> = "batchDeleteFlash"

  @module("./DbFunctionsImplementation.js")
  external readEntitiesFromDb: (Postgres.sql, array<Types.id>) => promise<array<Js.Json.t>> =
    "readFlashEntities"

  let readEntities = async (sql: Postgres.sql, ids: array<Types.id>): array<flashEntity> => {
    let res = await readEntitiesFromDb(sql, ids)
    res->Belt.Array.map(entityJson => entityJson->decodeUnsafe)
  }
}
module Mint = {
  open Types

  let decodeUnsafe = (entityJson: Js.Json.t): mintEntity => {
    let entityDecoded = switch entityJson->mintEntity_decode {
    | Ok(v) => Ok(v)
    | Error(e) =>
      Logging.error({
        "err": e,
        "msg": "EE700: Unable to parse row from database of entity mint using spice",
        "raw_unparsed_object": entityJson,
      })
      Error(e)
    }->Belt.Result.getExn

    entityDecoded
  }

  @module("./DbFunctionsImplementation.js")
  external batchSet: (Postgres.sql, array<Js.Json.t>) => promise<unit> = "batchSetMint"

  @module("./DbFunctionsImplementation.js")
  external batchDelete: (Postgres.sql, array<Types.id>) => promise<unit> = "batchDeleteMint"

  @module("./DbFunctionsImplementation.js")
  external readEntitiesFromDb: (Postgres.sql, array<Types.id>) => promise<array<Js.Json.t>> =
    "readMintEntities"

  let readEntities = async (sql: Postgres.sql, ids: array<Types.id>): array<mintEntity> => {
    let res = await readEntitiesFromDb(sql, ids)
    res->Belt.Array.map(entityJson => entityJson->decodeUnsafe)
  }
}
module Pool = {
  open Types

  let decodeUnsafe = (entityJson: Js.Json.t): poolEntity => {
    let entityDecoded = switch entityJson->poolEntity_decode {
    | Ok(v) => Ok(v)
    | Error(e) =>
      Logging.error({
        "err": e,
        "msg": "EE700: Unable to parse row from database of entity pool using spice",
        "raw_unparsed_object": entityJson,
      })
      Error(e)
    }->Belt.Result.getExn

    entityDecoded
  }

  @module("./DbFunctionsImplementation.js")
  external batchSet: (Postgres.sql, array<Js.Json.t>) => promise<unit> = "batchSetPool"

  @module("./DbFunctionsImplementation.js")
  external batchDelete: (Postgres.sql, array<Types.id>) => promise<unit> = "batchDeletePool"

  @module("./DbFunctionsImplementation.js")
  external readEntitiesFromDb: (Postgres.sql, array<Types.id>) => promise<array<Js.Json.t>> =
    "readPoolEntities"

  let readEntities = async (sql: Postgres.sql, ids: array<Types.id>): array<poolEntity> => {
    let res = await readEntitiesFromDb(sql, ids)
    res->Belt.Array.map(entityJson => entityJson->decodeUnsafe)
  }
}
module PoolDayData = {
  open Types

  let decodeUnsafe = (entityJson: Js.Json.t): poolDayDataEntity => {
    let entityDecoded = switch entityJson->poolDayDataEntity_decode {
    | Ok(v) => Ok(v)
    | Error(e) =>
      Logging.error({
        "err": e,
        "msg": "EE700: Unable to parse row from database of entity poolDayData using spice",
        "raw_unparsed_object": entityJson,
      })
      Error(e)
    }->Belt.Result.getExn

    entityDecoded
  }

  @module("./DbFunctionsImplementation.js")
  external batchSet: (Postgres.sql, array<Js.Json.t>) => promise<unit> = "batchSetPoolDayData"

  @module("./DbFunctionsImplementation.js")
  external batchDelete: (Postgres.sql, array<Types.id>) => promise<unit> = "batchDeletePoolDayData"

  @module("./DbFunctionsImplementation.js")
  external readEntitiesFromDb: (Postgres.sql, array<Types.id>) => promise<array<Js.Json.t>> =
    "readPoolDayDataEntities"

  let readEntities = async (sql: Postgres.sql, ids: array<Types.id>): array<poolDayDataEntity> => {
    let res = await readEntitiesFromDb(sql, ids)
    res->Belt.Array.map(entityJson => entityJson->decodeUnsafe)
  }
}
module PoolHourData = {
  open Types

  let decodeUnsafe = (entityJson: Js.Json.t): poolHourDataEntity => {
    let entityDecoded = switch entityJson->poolHourDataEntity_decode {
    | Ok(v) => Ok(v)
    | Error(e) =>
      Logging.error({
        "err": e,
        "msg": "EE700: Unable to parse row from database of entity poolHourData using spice",
        "raw_unparsed_object": entityJson,
      })
      Error(e)
    }->Belt.Result.getExn

    entityDecoded
  }

  @module("./DbFunctionsImplementation.js")
  external batchSet: (Postgres.sql, array<Js.Json.t>) => promise<unit> = "batchSetPoolHourData"

  @module("./DbFunctionsImplementation.js")
  external batchDelete: (Postgres.sql, array<Types.id>) => promise<unit> = "batchDeletePoolHourData"

  @module("./DbFunctionsImplementation.js")
  external readEntitiesFromDb: (Postgres.sql, array<Types.id>) => promise<array<Js.Json.t>> =
    "readPoolHourDataEntities"

  let readEntities = async (sql: Postgres.sql, ids: array<Types.id>): array<poolHourDataEntity> => {
    let res = await readEntitiesFromDb(sql, ids)
    res->Belt.Array.map(entityJson => entityJson->decodeUnsafe)
  }
}
module Position = {
  open Types

  let decodeUnsafe = (entityJson: Js.Json.t): positionEntity => {
    let entityDecoded = switch entityJson->positionEntity_decode {
    | Ok(v) => Ok(v)
    | Error(e) =>
      Logging.error({
        "err": e,
        "msg": "EE700: Unable to parse row from database of entity position using spice",
        "raw_unparsed_object": entityJson,
      })
      Error(e)
    }->Belt.Result.getExn

    entityDecoded
  }

  @module("./DbFunctionsImplementation.js")
  external batchSet: (Postgres.sql, array<Js.Json.t>) => promise<unit> = "batchSetPosition"

  @module("./DbFunctionsImplementation.js")
  external batchDelete: (Postgres.sql, array<Types.id>) => promise<unit> = "batchDeletePosition"

  @module("./DbFunctionsImplementation.js")
  external readEntitiesFromDb: (Postgres.sql, array<Types.id>) => promise<array<Js.Json.t>> =
    "readPositionEntities"

  let readEntities = async (sql: Postgres.sql, ids: array<Types.id>): array<positionEntity> => {
    let res = await readEntitiesFromDb(sql, ids)
    res->Belt.Array.map(entityJson => entityJson->decodeUnsafe)
  }
}
module PositionSnapshot = {
  open Types

  let decodeUnsafe = (entityJson: Js.Json.t): positionSnapshotEntity => {
    let entityDecoded = switch entityJson->positionSnapshotEntity_decode {
    | Ok(v) => Ok(v)
    | Error(e) =>
      Logging.error({
        "err": e,
        "msg": "EE700: Unable to parse row from database of entity positionSnapshot using spice",
        "raw_unparsed_object": entityJson,
      })
      Error(e)
    }->Belt.Result.getExn

    entityDecoded
  }

  @module("./DbFunctionsImplementation.js")
  external batchSet: (Postgres.sql, array<Js.Json.t>) => promise<unit> = "batchSetPositionSnapshot"

  @module("./DbFunctionsImplementation.js")
  external batchDelete: (Postgres.sql, array<Types.id>) => promise<unit> =
    "batchDeletePositionSnapshot"

  @module("./DbFunctionsImplementation.js")
  external readEntitiesFromDb: (Postgres.sql, array<Types.id>) => promise<array<Js.Json.t>> =
    "readPositionSnapshotEntities"

  let readEntities = async (sql: Postgres.sql, ids: array<Types.id>): array<
    positionSnapshotEntity,
  > => {
    let res = await readEntitiesFromDb(sql, ids)
    res->Belt.Array.map(entityJson => entityJson->decodeUnsafe)
  }
}
module Swap = {
  open Types

  let decodeUnsafe = (entityJson: Js.Json.t): swapEntity => {
    let entityDecoded = switch entityJson->swapEntity_decode {
    | Ok(v) => Ok(v)
    | Error(e) =>
      Logging.error({
        "err": e,
        "msg": "EE700: Unable to parse row from database of entity swap using spice",
        "raw_unparsed_object": entityJson,
      })
      Error(e)
    }->Belt.Result.getExn

    entityDecoded
  }

  @module("./DbFunctionsImplementation.js")
  external batchSet: (Postgres.sql, array<Js.Json.t>) => promise<unit> = "batchSetSwap"

  @module("./DbFunctionsImplementation.js")
  external batchDelete: (Postgres.sql, array<Types.id>) => promise<unit> = "batchDeleteSwap"

  @module("./DbFunctionsImplementation.js")
  external readEntitiesFromDb: (Postgres.sql, array<Types.id>) => promise<array<Js.Json.t>> =
    "readSwapEntities"

  let readEntities = async (sql: Postgres.sql, ids: array<Types.id>): array<swapEntity> => {
    let res = await readEntitiesFromDb(sql, ids)
    res->Belt.Array.map(entityJson => entityJson->decodeUnsafe)
  }
}
module Tick = {
  open Types

  let decodeUnsafe = (entityJson: Js.Json.t): tickEntity => {
    let entityDecoded = switch entityJson->tickEntity_decode {
    | Ok(v) => Ok(v)
    | Error(e) =>
      Logging.error({
        "err": e,
        "msg": "EE700: Unable to parse row from database of entity tick using spice",
        "raw_unparsed_object": entityJson,
      })
      Error(e)
    }->Belt.Result.getExn

    entityDecoded
  }

  @module("./DbFunctionsImplementation.js")
  external batchSet: (Postgres.sql, array<Js.Json.t>) => promise<unit> = "batchSetTick"

  @module("./DbFunctionsImplementation.js")
  external batchDelete: (Postgres.sql, array<Types.id>) => promise<unit> = "batchDeleteTick"

  @module("./DbFunctionsImplementation.js")
  external readEntitiesFromDb: (Postgres.sql, array<Types.id>) => promise<array<Js.Json.t>> =
    "readTickEntities"

  let readEntities = async (sql: Postgres.sql, ids: array<Types.id>): array<tickEntity> => {
    let res = await readEntitiesFromDb(sql, ids)
    res->Belt.Array.map(entityJson => entityJson->decodeUnsafe)
  }
}
module TickDayData = {
  open Types

  let decodeUnsafe = (entityJson: Js.Json.t): tickDayDataEntity => {
    let entityDecoded = switch entityJson->tickDayDataEntity_decode {
    | Ok(v) => Ok(v)
    | Error(e) =>
      Logging.error({
        "err": e,
        "msg": "EE700: Unable to parse row from database of entity tickDayData using spice",
        "raw_unparsed_object": entityJson,
      })
      Error(e)
    }->Belt.Result.getExn

    entityDecoded
  }

  @module("./DbFunctionsImplementation.js")
  external batchSet: (Postgres.sql, array<Js.Json.t>) => promise<unit> = "batchSetTickDayData"

  @module("./DbFunctionsImplementation.js")
  external batchDelete: (Postgres.sql, array<Types.id>) => promise<unit> = "batchDeleteTickDayData"

  @module("./DbFunctionsImplementation.js")
  external readEntitiesFromDb: (Postgres.sql, array<Types.id>) => promise<array<Js.Json.t>> =
    "readTickDayDataEntities"

  let readEntities = async (sql: Postgres.sql, ids: array<Types.id>): array<tickDayDataEntity> => {
    let res = await readEntitiesFromDb(sql, ids)
    res->Belt.Array.map(entityJson => entityJson->decodeUnsafe)
  }
}
module TickHourData = {
  open Types

  let decodeUnsafe = (entityJson: Js.Json.t): tickHourDataEntity => {
    let entityDecoded = switch entityJson->tickHourDataEntity_decode {
    | Ok(v) => Ok(v)
    | Error(e) =>
      Logging.error({
        "err": e,
        "msg": "EE700: Unable to parse row from database of entity tickHourData using spice",
        "raw_unparsed_object": entityJson,
      })
      Error(e)
    }->Belt.Result.getExn

    entityDecoded
  }

  @module("./DbFunctionsImplementation.js")
  external batchSet: (Postgres.sql, array<Js.Json.t>) => promise<unit> = "batchSetTickHourData"

  @module("./DbFunctionsImplementation.js")
  external batchDelete: (Postgres.sql, array<Types.id>) => promise<unit> = "batchDeleteTickHourData"

  @module("./DbFunctionsImplementation.js")
  external readEntitiesFromDb: (Postgres.sql, array<Types.id>) => promise<array<Js.Json.t>> =
    "readTickHourDataEntities"

  let readEntities = async (sql: Postgres.sql, ids: array<Types.id>): array<tickHourDataEntity> => {
    let res = await readEntitiesFromDb(sql, ids)
    res->Belt.Array.map(entityJson => entityJson->decodeUnsafe)
  }
}
module Token = {
  open Types

  let decodeUnsafe = (entityJson: Js.Json.t): tokenEntity => {
    let entityDecoded = switch entityJson->tokenEntity_decode {
    | Ok(v) => Ok(v)
    | Error(e) =>
      Logging.error({
        "err": e,
        "msg": "EE700: Unable to parse row from database of entity token using spice",
        "raw_unparsed_object": entityJson,
      })
      Error(e)
    }->Belt.Result.getExn

    entityDecoded
  }

  @module("./DbFunctionsImplementation.js")
  external batchSet: (Postgres.sql, array<Js.Json.t>) => promise<unit> = "batchSetToken"

  @module("./DbFunctionsImplementation.js")
  external batchDelete: (Postgres.sql, array<Types.id>) => promise<unit> = "batchDeleteToken"

  @module("./DbFunctionsImplementation.js")
  external readEntitiesFromDb: (Postgres.sql, array<Types.id>) => promise<array<Js.Json.t>> =
    "readTokenEntities"

  let readEntities = async (sql: Postgres.sql, ids: array<Types.id>): array<tokenEntity> => {
    let res = await readEntitiesFromDb(sql, ids)
    res->Belt.Array.map(entityJson => entityJson->decodeUnsafe)
  }
}
module TokenDayData = {
  open Types

  let decodeUnsafe = (entityJson: Js.Json.t): tokenDayDataEntity => {
    let entityDecoded = switch entityJson->tokenDayDataEntity_decode {
    | Ok(v) => Ok(v)
    | Error(e) =>
      Logging.error({
        "err": e,
        "msg": "EE700: Unable to parse row from database of entity tokenDayData using spice",
        "raw_unparsed_object": entityJson,
      })
      Error(e)
    }->Belt.Result.getExn

    entityDecoded
  }

  @module("./DbFunctionsImplementation.js")
  external batchSet: (Postgres.sql, array<Js.Json.t>) => promise<unit> = "batchSetTokenDayData"

  @module("./DbFunctionsImplementation.js")
  external batchDelete: (Postgres.sql, array<Types.id>) => promise<unit> = "batchDeleteTokenDayData"

  @module("./DbFunctionsImplementation.js")
  external readEntitiesFromDb: (Postgres.sql, array<Types.id>) => promise<array<Js.Json.t>> =
    "readTokenDayDataEntities"

  let readEntities = async (sql: Postgres.sql, ids: array<Types.id>): array<tokenDayDataEntity> => {
    let res = await readEntitiesFromDb(sql, ids)
    res->Belt.Array.map(entityJson => entityJson->decodeUnsafe)
  }
}
module TokenHourData = {
  open Types

  let decodeUnsafe = (entityJson: Js.Json.t): tokenHourDataEntity => {
    let entityDecoded = switch entityJson->tokenHourDataEntity_decode {
    | Ok(v) => Ok(v)
    | Error(e) =>
      Logging.error({
        "err": e,
        "msg": "EE700: Unable to parse row from database of entity tokenHourData using spice",
        "raw_unparsed_object": entityJson,
      })
      Error(e)
    }->Belt.Result.getExn

    entityDecoded
  }

  @module("./DbFunctionsImplementation.js")
  external batchSet: (Postgres.sql, array<Js.Json.t>) => promise<unit> = "batchSetTokenHourData"

  @module("./DbFunctionsImplementation.js")
  external batchDelete: (Postgres.sql, array<Types.id>) => promise<unit> =
    "batchDeleteTokenHourData"

  @module("./DbFunctionsImplementation.js")
  external readEntitiesFromDb: (Postgres.sql, array<Types.id>) => promise<array<Js.Json.t>> =
    "readTokenHourDataEntities"

  let readEntities = async (sql: Postgres.sql, ids: array<Types.id>): array<
    tokenHourDataEntity,
  > => {
    let res = await readEntitiesFromDb(sql, ids)
    res->Belt.Array.map(entityJson => entityJson->decodeUnsafe)
  }
}
module TokenPoolWhitelist = {
  open Types

  let decodeUnsafe = (entityJson: Js.Json.t): tokenPoolWhitelistEntity => {
    let entityDecoded = switch entityJson->tokenPoolWhitelistEntity_decode {
    | Ok(v) => Ok(v)
    | Error(e) =>
      Logging.error({
        "err": e,
        "msg": "EE700: Unable to parse row from database of entity tokenPoolWhitelist using spice",
        "raw_unparsed_object": entityJson,
      })
      Error(e)
    }->Belt.Result.getExn

    entityDecoded
  }

  @module("./DbFunctionsImplementation.js")
  external batchSet: (Postgres.sql, array<Js.Json.t>) => promise<unit> =
    "batchSetTokenPoolWhitelist"

  @module("./DbFunctionsImplementation.js")
  external batchDelete: (Postgres.sql, array<Types.id>) => promise<unit> =
    "batchDeleteTokenPoolWhitelist"

  @module("./DbFunctionsImplementation.js")
  external readEntitiesFromDb: (Postgres.sql, array<Types.id>) => promise<array<Js.Json.t>> =
    "readTokenPoolWhitelistEntities"

  let readEntities = async (sql: Postgres.sql, ids: array<Types.id>): array<
    tokenPoolWhitelistEntity,
  > => {
    let res = await readEntitiesFromDb(sql, ids)
    res->Belt.Array.map(entityJson => entityJson->decodeUnsafe)
  }
}
module Transaction = {
  open Types

  let decodeUnsafe = (entityJson: Js.Json.t): transactionEntity => {
    let entityDecoded = switch entityJson->transactionEntity_decode {
    | Ok(v) => Ok(v)
    | Error(e) =>
      Logging.error({
        "err": e,
        "msg": "EE700: Unable to parse row from database of entity transaction using spice",
        "raw_unparsed_object": entityJson,
      })
      Error(e)
    }->Belt.Result.getExn

    entityDecoded
  }

  @module("./DbFunctionsImplementation.js")
  external batchSet: (Postgres.sql, array<Js.Json.t>) => promise<unit> = "batchSetTransaction"

  @module("./DbFunctionsImplementation.js")
  external batchDelete: (Postgres.sql, array<Types.id>) => promise<unit> = "batchDeleteTransaction"

  @module("./DbFunctionsImplementation.js")
  external readEntitiesFromDb: (Postgres.sql, array<Types.id>) => promise<array<Js.Json.t>> =
    "readTransactionEntities"

  let readEntities = async (sql: Postgres.sql, ids: array<Types.id>): array<transactionEntity> => {
    let res = await readEntitiesFromDb(sql, ids)
    res->Belt.Array.map(entityJson => entityJson->decodeUnsafe)
  }
}
module UniswapDayData = {
  open Types

  let decodeUnsafe = (entityJson: Js.Json.t): uniswapDayDataEntity => {
    let entityDecoded = switch entityJson->uniswapDayDataEntity_decode {
    | Ok(v) => Ok(v)
    | Error(e) =>
      Logging.error({
        "err": e,
        "msg": "EE700: Unable to parse row from database of entity uniswapDayData using spice",
        "raw_unparsed_object": entityJson,
      })
      Error(e)
    }->Belt.Result.getExn

    entityDecoded
  }

  @module("./DbFunctionsImplementation.js")
  external batchSet: (Postgres.sql, array<Js.Json.t>) => promise<unit> = "batchSetUniswapDayData"

  @module("./DbFunctionsImplementation.js")
  external batchDelete: (Postgres.sql, array<Types.id>) => promise<unit> =
    "batchDeleteUniswapDayData"

  @module("./DbFunctionsImplementation.js")
  external readEntitiesFromDb: (Postgres.sql, array<Types.id>) => promise<array<Js.Json.t>> =
    "readUniswapDayDataEntities"

  let readEntities = async (sql: Postgres.sql, ids: array<Types.id>): array<
    uniswapDayDataEntity,
  > => {
    let res = await readEntitiesFromDb(sql, ids)
    res->Belt.Array.map(entityJson => entityJson->decodeUnsafe)
  }
}
