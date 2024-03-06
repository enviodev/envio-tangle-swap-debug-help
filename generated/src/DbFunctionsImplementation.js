// db operations for raw_events:
const MAX_ITEMS_PER_QUERY = 500;

module.exports.readLatestSyncedEventOnChainId = (sql, chainId) => sql`
  SELECT *
  FROM public.event_sync_state
  WHERE chain_id = ${chainId}`;

module.exports.batchSetEventSyncState = (sql, entityDataArray) => {
  return sql`
    INSERT INTO public.event_sync_state
  ${sql(
    entityDataArray,
    "chain_id",
    "block_number",
    "log_index",
    "transaction_index",
    "block_timestamp"
  )}
    ON CONFLICT(chain_id) DO UPDATE
    SET
    "chain_id" = EXCLUDED."chain_id",
    "block_number" = EXCLUDED."block_number",
    "log_index" = EXCLUDED."log_index",
    "transaction_index" = EXCLUDED."transaction_index",
    "block_timestamp" = EXCLUDED."block_timestamp";
    `;
};

module.exports.setChainMetadata = (sql, entityDataArray) => {
  return (sql`
    INSERT INTO public.chain_metadata
  ${sql(
    entityDataArray,
    "chain_id",
    "start_block", // this is left out of the on conflict below as it only needs to be set once
    "block_height"
  )}
  ON CONFLICT(chain_id) DO UPDATE
  SET
  "chain_id" = EXCLUDED."chain_id",
  "block_height" = EXCLUDED."block_height";`).then(res => {
    
  }).catch(err => {
    console.log("errored", err)
  });
};

module.exports.readLatestRawEventsBlockNumberProcessedOnChainId = (
  sql,
  chainId
) => sql`
  SELECT block_number
  FROM "public"."raw_events"
  WHERE chain_id = ${chainId}
  ORDER BY event_id DESC
  LIMIT 1;`;

module.exports.readRawEventsEntities = (sql, entityIdArray) => sql`
  SELECT *
  FROM "public"."raw_events"
  WHERE (chain_id, event_id) IN ${sql(entityIdArray)}`;

module.exports.getRawEventsPageGtOrEqEventId = (
  sql,
  chainId,
  eventId,
  limit,
  contractAddresses
) => sql`
  SELECT *
  FROM "public"."raw_events"
  WHERE "chain_id" = ${chainId}
  AND "event_id" >= ${eventId}
  AND "src_address" IN ${sql(contractAddresses)}
  ORDER BY "event_id" ASC
  LIMIT ${limit}
`;

module.exports.getRawEventsPageWithinEventIdRangeInclusive = (
  sql,
  chainId,
  fromEventIdInclusive,
  toEventIdInclusive,
  limit,
  contractAddresses
) => sql`
  SELECT *
  FROM public.raw_events
  WHERE "chain_id" = ${chainId}
  AND "event_id" >= ${fromEventIdInclusive}
  AND "event_id" <= ${toEventIdInclusive}
  AND "src_address" IN ${sql(contractAddresses)}
  ORDER BY "event_id" ASC
  LIMIT ${limit}
`;

const batchSetRawEventsCore = (sql, entityDataArray) => {
  return sql`
    INSERT INTO "public"."raw_events"
  ${sql(
    entityDataArray,
    "chain_id",
    "event_id",
    "block_number",
    "log_index",
    "transaction_index",
    "transaction_hash",
    "src_address",
    "block_hash",
    "block_timestamp",
    "event_type",
    "params"
  )}
    ON CONFLICT(chain_id, event_id) DO UPDATE
    SET
    "chain_id" = EXCLUDED."chain_id",
    "event_id" = EXCLUDED."event_id",
    "block_number" = EXCLUDED."block_number",
    "log_index" = EXCLUDED."log_index",
    "transaction_index" = EXCLUDED."transaction_index",
    "transaction_hash" = EXCLUDED."transaction_hash",
    "src_address" = EXCLUDED."src_address",
    "block_hash" = EXCLUDED."block_hash",
    "block_timestamp" = EXCLUDED."block_timestamp",
    "event_type" = EXCLUDED."event_type",
    "params" = EXCLUDED."params";`;
};

const chunkBatchQuery = (
  sql,
  entityDataArray,
  queryToExecute
) => {
  const promises = [];

  // Split entityDataArray into chunks of MAX_ITEMS_PER_QUERY
  for (let i = 0; i < entityDataArray.length; i += MAX_ITEMS_PER_QUERY) {
    const chunk = entityDataArray.slice(i, i + MAX_ITEMS_PER_QUERY);

    promises.push(queryToExecute(sql, chunk));
  }

  // Execute all promises
  return Promise.all(promises).catch(e => {
    console.error("Sql query failed", e);
    throw e;
    });
};

module.exports.batchSetRawEvents = (sql, entityDataArray) => {
  return chunkBatchQuery(
    sql,
    entityDataArray,
    batchSetRawEventsCore
  );
};

module.exports.batchDeleteRawEvents = (sql, entityIdArray) => sql`
  DELETE
  FROM "public"."raw_events"
  WHERE (chain_id, event_id) IN ${sql(entityIdArray)};`;
// end db operations for raw_events

module.exports.readDynamicContractsOnChainIdAtOrBeforeBlock = (
  sql,
  chainId,
  block_number
) => sql`
  SELECT c.contract_address, c.contract_type, c.event_id
  FROM "public"."dynamic_contract_registry" as c
  JOIN raw_events e ON c.chain_id = e.chain_id
  AND c.event_id = e.event_id
  WHERE e.block_number <= ${block_number} AND e.chain_id = ${chainId};`;

//Start db operations dynamic_contract_registry
module.exports.readDynamicContractRegistryEntities = (
  sql,
  entityIdArray
) => sql`
  SELECT *
  FROM "public"."dynamic_contract_registry"
  WHERE (chain_id, contract_address) IN ${sql(entityIdArray)}`;

const batchSetDynamicContractRegistryCore = (sql, entityDataArray) => {
  return sql`
    INSERT INTO "public"."dynamic_contract_registry"
  ${sql(
    entityDataArray,
    "chain_id",
    "event_id",
    "contract_address",
    "contract_type"
  )}
    ON CONFLICT(chain_id, contract_address) DO UPDATE
    SET
    "chain_id" = EXCLUDED."chain_id",
    "event_id" = EXCLUDED."event_id",
    "contract_address" = EXCLUDED."contract_address",
    "contract_type" = EXCLUDED."contract_type";`;
};

module.exports.batchSetDynamicContractRegistry = (sql, entityDataArray) => {
  return chunkBatchQuery(
    sql,
    entityDataArray,
    batchSetDynamicContractRegistryCore
  );
};

module.exports.batchDeleteDynamicContractRegistry = (sql, entityIdArray) => sql`
  DELETE
  FROM "public"."dynamic_contract_registry"
  WHERE (chain_id, contract_address) IN ${sql(entityIdArray)};`;
// end db operations for dynamic_contract_registry

//////////////////////////////////////////////
// DB operations for Bundle:
//////////////////////////////////////////////

module.exports.readBundleEntities = (sql, entityIdArray) => sql`
SELECT 
"id",
"ethPriceUSD"
FROM "public"."Bundle"
WHERE id IN ${sql(entityIdArray)};`;

const batchSetBundleCore = (sql, entityDataArray) => {
  return sql`
    INSERT INTO "public"."Bundle"
${sql(entityDataArray,
    "id",
    "ethPriceUSD"
  )}
  ON CONFLICT(id) DO UPDATE
  SET
  "id" = EXCLUDED."id",
  "ethPriceUSD" = EXCLUDED."ethPriceUSD"
  `;
}

module.exports.batchSetBundle = (sql, entityDataArray) => {

  return chunkBatchQuery(
    sql, 
    entityDataArray, 
    batchSetBundleCore
  );
}

module.exports.batchDeleteBundle = (sql, entityIdArray) => sql`
DELETE
FROM "public"."Bundle"
WHERE id IN ${sql(entityIdArray)};`
// end db operations for Bundle

//////////////////////////////////////////////
// DB operations for Burn:
//////////////////////////////////////////////

module.exports.readBurnEntities = (sql, entityIdArray) => sql`
SELECT 
"timestamp",
"transaction_id",
"token0_id",
"tickLower",
"pool_id",
"amountUSD",
"amount0",
"tickUpper",
"amount1",
"id",
"owner",
"amount",
"token1_id",
"origin",
"logIndex"
FROM "public"."Burn"
WHERE id IN ${sql(entityIdArray)};`;

const batchSetBurnCore = (sql, entityDataArray) => {
  return sql`
    INSERT INTO "public"."Burn"
${sql(entityDataArray,
    "timestamp",
    "transaction_id",
    "token0_id",
    "tickLower",
    "pool_id",
    "amountUSD",
    "amount0",
    "tickUpper",
    "amount1",
    "id",
    "owner",
    "amount",
    "token1_id",
    "origin",
    "logIndex"
  )}
  ON CONFLICT(id) DO UPDATE
  SET
  "timestamp" = EXCLUDED."timestamp",
  "transaction_id" = EXCLUDED."transaction_id",
  "token0_id" = EXCLUDED."token0_id",
  "tickLower" = EXCLUDED."tickLower",
  "pool_id" = EXCLUDED."pool_id",
  "amountUSD" = EXCLUDED."amountUSD",
  "amount0" = EXCLUDED."amount0",
  "tickUpper" = EXCLUDED."tickUpper",
  "amount1" = EXCLUDED."amount1",
  "id" = EXCLUDED."id",
  "owner" = EXCLUDED."owner",
  "amount" = EXCLUDED."amount",
  "token1_id" = EXCLUDED."token1_id",
  "origin" = EXCLUDED."origin",
  "logIndex" = EXCLUDED."logIndex"
  `;
}

module.exports.batchSetBurn = (sql, entityDataArray) => {

  return chunkBatchQuery(
    sql, 
    entityDataArray, 
    batchSetBurnCore
  );
}

module.exports.batchDeleteBurn = (sql, entityIdArray) => sql`
DELETE
FROM "public"."Burn"
WHERE id IN ${sql(entityIdArray)};`
// end db operations for Burn

//////////////////////////////////////////////
// DB operations for Collect:
//////////////////////////////////////////////

module.exports.readCollectEntities = (sql, entityIdArray) => sql`
SELECT 
"amountUSD",
"owner",
"id",
"amount0",
"transaction_id",
"timestamp",
"pool_id",
"amount1",
"tickLower",
"tickUpper",
"logIndex"
FROM "public"."Collect"
WHERE id IN ${sql(entityIdArray)};`;

const batchSetCollectCore = (sql, entityDataArray) => {
  return sql`
    INSERT INTO "public"."Collect"
${sql(entityDataArray,
    "amountUSD",
    "owner",
    "id",
    "amount0",
    "transaction_id",
    "timestamp",
    "pool_id",
    "amount1",
    "tickLower",
    "tickUpper",
    "logIndex"
  )}
  ON CONFLICT(id) DO UPDATE
  SET
  "amountUSD" = EXCLUDED."amountUSD",
  "owner" = EXCLUDED."owner",
  "id" = EXCLUDED."id",
  "amount0" = EXCLUDED."amount0",
  "transaction_id" = EXCLUDED."transaction_id",
  "timestamp" = EXCLUDED."timestamp",
  "pool_id" = EXCLUDED."pool_id",
  "amount1" = EXCLUDED."amount1",
  "tickLower" = EXCLUDED."tickLower",
  "tickUpper" = EXCLUDED."tickUpper",
  "logIndex" = EXCLUDED."logIndex"
  `;
}

module.exports.batchSetCollect = (sql, entityDataArray) => {

  return chunkBatchQuery(
    sql, 
    entityDataArray, 
    batchSetCollectCore
  );
}

module.exports.batchDeleteCollect = (sql, entityIdArray) => sql`
DELETE
FROM "public"."Collect"
WHERE id IN ${sql(entityIdArray)};`
// end db operations for Collect

//////////////////////////////////////////////
// DB operations for Factory:
//////////////////////////////////////////////

module.exports.readFactoryEntities = (sql, entityIdArray) => sql`
SELECT 
"totalValueLockedUSD",
"id",
"totalFeesETH",
"totalValueLockedETHUntracked",
"totalValueLockedUSDUntracked",
"totalValueLockedETH",
"owner",
"totalVolumeUSD",
"txCount",
"totalFeesUSD",
"poolCount",
"untrackedVolumeUSD",
"totalVolumeETH"
FROM "public"."Factory"
WHERE id IN ${sql(entityIdArray)};`;

const batchSetFactoryCore = (sql, entityDataArray) => {
  return sql`
    INSERT INTO "public"."Factory"
${sql(entityDataArray,
    "totalValueLockedUSD",
    "id",
    "totalFeesETH",
    "totalValueLockedETHUntracked",
    "totalValueLockedUSDUntracked",
    "totalValueLockedETH",
    "owner",
    "totalVolumeUSD",
    "txCount",
    "totalFeesUSD",
    "poolCount",
    "untrackedVolumeUSD",
    "totalVolumeETH"
  )}
  ON CONFLICT(id) DO UPDATE
  SET
  "totalValueLockedUSD" = EXCLUDED."totalValueLockedUSD",
  "id" = EXCLUDED."id",
  "totalFeesETH" = EXCLUDED."totalFeesETH",
  "totalValueLockedETHUntracked" = EXCLUDED."totalValueLockedETHUntracked",
  "totalValueLockedUSDUntracked" = EXCLUDED."totalValueLockedUSDUntracked",
  "totalValueLockedETH" = EXCLUDED."totalValueLockedETH",
  "owner" = EXCLUDED."owner",
  "totalVolumeUSD" = EXCLUDED."totalVolumeUSD",
  "txCount" = EXCLUDED."txCount",
  "totalFeesUSD" = EXCLUDED."totalFeesUSD",
  "poolCount" = EXCLUDED."poolCount",
  "untrackedVolumeUSD" = EXCLUDED."untrackedVolumeUSD",
  "totalVolumeETH" = EXCLUDED."totalVolumeETH"
  `;
}

module.exports.batchSetFactory = (sql, entityDataArray) => {

  return chunkBatchQuery(
    sql, 
    entityDataArray, 
    batchSetFactoryCore
  );
}

module.exports.batchDeleteFactory = (sql, entityIdArray) => sql`
DELETE
FROM "public"."Factory"
WHERE id IN ${sql(entityIdArray)};`
// end db operations for Factory

//////////////////////////////////////////////
// DB operations for Flash:
//////////////////////////////////////////////

module.exports.readFlashEntities = (sql, entityIdArray) => sql`
SELECT 
"timestamp",
"sender",
"id",
"pool_id",
"amount1",
"amountUSD",
"amount0",
"amount0Paid",
"amount1Paid",
"logIndex",
"transaction_id",
"recipient"
FROM "public"."Flash"
WHERE id IN ${sql(entityIdArray)};`;

const batchSetFlashCore = (sql, entityDataArray) => {
  return sql`
    INSERT INTO "public"."Flash"
${sql(entityDataArray,
    "timestamp",
    "sender",
    "id",
    "pool_id",
    "amount1",
    "amountUSD",
    "amount0",
    "amount0Paid",
    "amount1Paid",
    "logIndex",
    "transaction_id",
    "recipient"
  )}
  ON CONFLICT(id) DO UPDATE
  SET
  "timestamp" = EXCLUDED."timestamp",
  "sender" = EXCLUDED."sender",
  "id" = EXCLUDED."id",
  "pool_id" = EXCLUDED."pool_id",
  "amount1" = EXCLUDED."amount1",
  "amountUSD" = EXCLUDED."amountUSD",
  "amount0" = EXCLUDED."amount0",
  "amount0Paid" = EXCLUDED."amount0Paid",
  "amount1Paid" = EXCLUDED."amount1Paid",
  "logIndex" = EXCLUDED."logIndex",
  "transaction_id" = EXCLUDED."transaction_id",
  "recipient" = EXCLUDED."recipient"
  `;
}

module.exports.batchSetFlash = (sql, entityDataArray) => {

  return chunkBatchQuery(
    sql, 
    entityDataArray, 
    batchSetFlashCore
  );
}

module.exports.batchDeleteFlash = (sql, entityIdArray) => sql`
DELETE
FROM "public"."Flash"
WHERE id IN ${sql(entityIdArray)};`
// end db operations for Flash

//////////////////////////////////////////////
// DB operations for Mint:
//////////////////////////////////////////////

module.exports.readMintEntities = (sql, entityIdArray) => sql`
SELECT 
"sender",
"origin",
"amount",
"amount0",
"tickUpper",
"logIndex",
"token0_id",
"amountUSD",
"transaction_id",
"pool_id",
"amount1",
"tickLower",
"id",
"timestamp",
"token1_id",
"owner"
FROM "public"."Mint"
WHERE id IN ${sql(entityIdArray)};`;

const batchSetMintCore = (sql, entityDataArray) => {
  return sql`
    INSERT INTO "public"."Mint"
${sql(entityDataArray,
    "sender",
    "origin",
    "amount",
    "amount0",
    "tickUpper",
    "logIndex",
    "token0_id",
    "amountUSD",
    "transaction_id",
    "pool_id",
    "amount1",
    "tickLower",
    "id",
    "timestamp",
    "token1_id",
    "owner"
  )}
  ON CONFLICT(id) DO UPDATE
  SET
  "sender" = EXCLUDED."sender",
  "origin" = EXCLUDED."origin",
  "amount" = EXCLUDED."amount",
  "amount0" = EXCLUDED."amount0",
  "tickUpper" = EXCLUDED."tickUpper",
  "logIndex" = EXCLUDED."logIndex",
  "token0_id" = EXCLUDED."token0_id",
  "amountUSD" = EXCLUDED."amountUSD",
  "transaction_id" = EXCLUDED."transaction_id",
  "pool_id" = EXCLUDED."pool_id",
  "amount1" = EXCLUDED."amount1",
  "tickLower" = EXCLUDED."tickLower",
  "id" = EXCLUDED."id",
  "timestamp" = EXCLUDED."timestamp",
  "token1_id" = EXCLUDED."token1_id",
  "owner" = EXCLUDED."owner"
  `;
}

module.exports.batchSetMint = (sql, entityDataArray) => {

  return chunkBatchQuery(
    sql, 
    entityDataArray, 
    batchSetMintCore
  );
}

module.exports.batchDeleteMint = (sql, entityIdArray) => sql`
DELETE
FROM "public"."Mint"
WHERE id IN ${sql(entityIdArray)};`
// end db operations for Mint

//////////////////////////////////////////////
// DB operations for Pool:
//////////////////////////////////////////////

module.exports.readPoolEntities = (sql, entityIdArray) => sql`
SELECT 
"token1_id",
"volumeToken1",
"id",
"token0_id",
"txCount",
"tick",
"liquidity",
"observationIndex",
"feeTier",
"untrackedVolumeUSD",
"collectedFeesUSD",
"volumeToken0",
"totalValueLockedUSD",
"token1Price",
"feeGrowthGlobal0X128",
"totalValueLockedToken1",
"liquidityProviderCount",
"collectedFeesToken1",
"volumeUSD",
"createdAtTimestamp",
"feeGrowthGlobal1X128",
"sqrtPrice",
"totalValueLockedToken0",
"totalValueLockedETH",
"totalValueLockedUSDUntracked",
"feesUSD",
"collectedFeesToken0",
"token0Price",
"createdAtBlockNumber"
FROM "public"."Pool"
WHERE id IN ${sql(entityIdArray)};`;

const batchSetPoolCore = (sql, entityDataArray) => {
  return sql`
    INSERT INTO "public"."Pool"
${sql(entityDataArray,
    "token1_id",
    "volumeToken1",
    "id",
    "token0_id",
    "txCount",
    "tick",
    "liquidity",
    "observationIndex",
    "feeTier",
    "untrackedVolumeUSD",
    "collectedFeesUSD",
    "volumeToken0",
    "totalValueLockedUSD",
    "token1Price",
    "feeGrowthGlobal0X128",
    "totalValueLockedToken1",
    "liquidityProviderCount",
    "collectedFeesToken1",
    "volumeUSD",
    "createdAtTimestamp",
    "feeGrowthGlobal1X128",
    "sqrtPrice",
    "totalValueLockedToken0",
    "totalValueLockedETH",
    "totalValueLockedUSDUntracked",
    "feesUSD",
    "collectedFeesToken0",
    "token0Price",
    "createdAtBlockNumber"
  )}
  ON CONFLICT(id) DO UPDATE
  SET
  "token1_id" = EXCLUDED."token1_id",
  "volumeToken1" = EXCLUDED."volumeToken1",
  "id" = EXCLUDED."id",
  "token0_id" = EXCLUDED."token0_id",
  "txCount" = EXCLUDED."txCount",
  "tick" = EXCLUDED."tick",
  "liquidity" = EXCLUDED."liquidity",
  "observationIndex" = EXCLUDED."observationIndex",
  "feeTier" = EXCLUDED."feeTier",
  "untrackedVolumeUSD" = EXCLUDED."untrackedVolumeUSD",
  "collectedFeesUSD" = EXCLUDED."collectedFeesUSD",
  "volumeToken0" = EXCLUDED."volumeToken0",
  "totalValueLockedUSD" = EXCLUDED."totalValueLockedUSD",
  "token1Price" = EXCLUDED."token1Price",
  "feeGrowthGlobal0X128" = EXCLUDED."feeGrowthGlobal0X128",
  "totalValueLockedToken1" = EXCLUDED."totalValueLockedToken1",
  "liquidityProviderCount" = EXCLUDED."liquidityProviderCount",
  "collectedFeesToken1" = EXCLUDED."collectedFeesToken1",
  "volumeUSD" = EXCLUDED."volumeUSD",
  "createdAtTimestamp" = EXCLUDED."createdAtTimestamp",
  "feeGrowthGlobal1X128" = EXCLUDED."feeGrowthGlobal1X128",
  "sqrtPrice" = EXCLUDED."sqrtPrice",
  "totalValueLockedToken0" = EXCLUDED."totalValueLockedToken0",
  "totalValueLockedETH" = EXCLUDED."totalValueLockedETH",
  "totalValueLockedUSDUntracked" = EXCLUDED."totalValueLockedUSDUntracked",
  "feesUSD" = EXCLUDED."feesUSD",
  "collectedFeesToken0" = EXCLUDED."collectedFeesToken0",
  "token0Price" = EXCLUDED."token0Price",
  "createdAtBlockNumber" = EXCLUDED."createdAtBlockNumber"
  `;
}

module.exports.batchSetPool = (sql, entityDataArray) => {

  return chunkBatchQuery(
    sql, 
    entityDataArray, 
    batchSetPoolCore
  );
}

module.exports.batchDeletePool = (sql, entityIdArray) => sql`
DELETE
FROM "public"."Pool"
WHERE id IN ${sql(entityIdArray)};`
// end db operations for Pool

//////////////////////////////////////////////
// DB operations for PoolDayData:
//////////////////////////////////////////////

module.exports.readPoolDayDataEntities = (sql, entityIdArray) => sql`
SELECT 
"tick",
"feeGrowthGlobal1X128",
"volumeUSD",
"sqrtPrice",
"feesUSD",
"liquidity",
"txCount",
"openPrice0",
"volumeToken0",
"high",
"low",
"tvlUSD",
"date",
"token1Price",
"close",
"token0Price",
"pool_id",
"feeGrowthGlobal0X128",
"volumeToken1",
"id"
FROM "public"."PoolDayData"
WHERE id IN ${sql(entityIdArray)};`;

const batchSetPoolDayDataCore = (sql, entityDataArray) => {
  return sql`
    INSERT INTO "public"."PoolDayData"
${sql(entityDataArray,
    "tick",
    "feeGrowthGlobal1X128",
    "volumeUSD",
    "sqrtPrice",
    "feesUSD",
    "liquidity",
    "txCount",
    "openPrice0",
    "volumeToken0",
    "high",
    "low",
    "tvlUSD",
    "date",
    "token1Price",
    "close",
    "token0Price",
    "pool_id",
    "feeGrowthGlobal0X128",
    "volumeToken1",
    "id"
  )}
  ON CONFLICT(id) DO UPDATE
  SET
  "tick" = EXCLUDED."tick",
  "feeGrowthGlobal1X128" = EXCLUDED."feeGrowthGlobal1X128",
  "volumeUSD" = EXCLUDED."volumeUSD",
  "sqrtPrice" = EXCLUDED."sqrtPrice",
  "feesUSD" = EXCLUDED."feesUSD",
  "liquidity" = EXCLUDED."liquidity",
  "txCount" = EXCLUDED."txCount",
  "openPrice0" = EXCLUDED."openPrice0",
  "volumeToken0" = EXCLUDED."volumeToken0",
  "high" = EXCLUDED."high",
  "low" = EXCLUDED."low",
  "tvlUSD" = EXCLUDED."tvlUSD",
  "date" = EXCLUDED."date",
  "token1Price" = EXCLUDED."token1Price",
  "close" = EXCLUDED."close",
  "token0Price" = EXCLUDED."token0Price",
  "pool_id" = EXCLUDED."pool_id",
  "feeGrowthGlobal0X128" = EXCLUDED."feeGrowthGlobal0X128",
  "volumeToken1" = EXCLUDED."volumeToken1",
  "id" = EXCLUDED."id"
  `;
}

module.exports.batchSetPoolDayData = (sql, entityDataArray) => {

  return chunkBatchQuery(
    sql, 
    entityDataArray, 
    batchSetPoolDayDataCore
  );
}

module.exports.batchDeletePoolDayData = (sql, entityIdArray) => sql`
DELETE
FROM "public"."PoolDayData"
WHERE id IN ${sql(entityIdArray)};`
// end db operations for PoolDayData

//////////////////////////////////////////////
// DB operations for PoolHourData:
//////////////////////////////////////////////

module.exports.readPoolHourDataEntities = (sql, entityIdArray) => sql`
SELECT 
"token1Price",
"feesUSD",
"liquidity",
"sqrtPrice",
"volumeToken1",
"pool_id",
"tick",
"feeGrowthGlobal1X128",
"volumeUSD",
"high",
"openPrice0",
"token0Price",
"feeGrowthGlobal0X128",
"txCount",
"close",
"tvlUSD",
"volumeToken0",
"periodStartUnix",
"id",
"low"
FROM "public"."PoolHourData"
WHERE id IN ${sql(entityIdArray)};`;

const batchSetPoolHourDataCore = (sql, entityDataArray) => {
  return sql`
    INSERT INTO "public"."PoolHourData"
${sql(entityDataArray,
    "token1Price",
    "feesUSD",
    "liquidity",
    "sqrtPrice",
    "volumeToken1",
    "pool_id",
    "tick",
    "feeGrowthGlobal1X128",
    "volumeUSD",
    "high",
    "openPrice0",
    "token0Price",
    "feeGrowthGlobal0X128",
    "txCount",
    "close",
    "tvlUSD",
    "volumeToken0",
    "periodStartUnix",
    "id",
    "low"
  )}
  ON CONFLICT(id) DO UPDATE
  SET
  "token1Price" = EXCLUDED."token1Price",
  "feesUSD" = EXCLUDED."feesUSD",
  "liquidity" = EXCLUDED."liquidity",
  "sqrtPrice" = EXCLUDED."sqrtPrice",
  "volumeToken1" = EXCLUDED."volumeToken1",
  "pool_id" = EXCLUDED."pool_id",
  "tick" = EXCLUDED."tick",
  "feeGrowthGlobal1X128" = EXCLUDED."feeGrowthGlobal1X128",
  "volumeUSD" = EXCLUDED."volumeUSD",
  "high" = EXCLUDED."high",
  "openPrice0" = EXCLUDED."openPrice0",
  "token0Price" = EXCLUDED."token0Price",
  "feeGrowthGlobal0X128" = EXCLUDED."feeGrowthGlobal0X128",
  "txCount" = EXCLUDED."txCount",
  "close" = EXCLUDED."close",
  "tvlUSD" = EXCLUDED."tvlUSD",
  "volumeToken0" = EXCLUDED."volumeToken0",
  "periodStartUnix" = EXCLUDED."periodStartUnix",
  "id" = EXCLUDED."id",
  "low" = EXCLUDED."low"
  `;
}

module.exports.batchSetPoolHourData = (sql, entityDataArray) => {

  return chunkBatchQuery(
    sql, 
    entityDataArray, 
    batchSetPoolHourDataCore
  );
}

module.exports.batchDeletePoolHourData = (sql, entityIdArray) => sql`
DELETE
FROM "public"."PoolHourData"
WHERE id IN ${sql(entityIdArray)};`
// end db operations for PoolHourData

//////////////////////////////////////////////
// DB operations for Position:
//////////////////////////////////////////////

module.exports.readPositionEntities = (sql, entityIdArray) => sql`
SELECT 
"owner",
"feeGrowthInside0LastX128",
"liquidity",
"token1_id",
"token0_id",
"tickLower_id",
"transaction_id",
"collectedFeesToken1",
"feeGrowthInside1LastX128",
"id",
"pool_id",
"withdrawnToken1",
"collectedToken1",
"depositedToken0",
"withdrawnToken0",
"depositedToken1",
"collectedToken0",
"tickUpper_id",
"collectedFeesToken0"
FROM "public"."Position"
WHERE id IN ${sql(entityIdArray)};`;

const batchSetPositionCore = (sql, entityDataArray) => {
  return sql`
    INSERT INTO "public"."Position"
${sql(entityDataArray,
    "owner",
    "feeGrowthInside0LastX128",
    "liquidity",
    "token1_id",
    "token0_id",
    "tickLower_id",
    "transaction_id",
    "collectedFeesToken1",
    "feeGrowthInside1LastX128",
    "id",
    "pool_id",
    "withdrawnToken1",
    "collectedToken1",
    "depositedToken0",
    "withdrawnToken0",
    "depositedToken1",
    "collectedToken0",
    "tickUpper_id",
    "collectedFeesToken0"
  )}
  ON CONFLICT(id) DO UPDATE
  SET
  "owner" = EXCLUDED."owner",
  "feeGrowthInside0LastX128" = EXCLUDED."feeGrowthInside0LastX128",
  "liquidity" = EXCLUDED."liquidity",
  "token1_id" = EXCLUDED."token1_id",
  "token0_id" = EXCLUDED."token0_id",
  "tickLower_id" = EXCLUDED."tickLower_id",
  "transaction_id" = EXCLUDED."transaction_id",
  "collectedFeesToken1" = EXCLUDED."collectedFeesToken1",
  "feeGrowthInside1LastX128" = EXCLUDED."feeGrowthInside1LastX128",
  "id" = EXCLUDED."id",
  "pool_id" = EXCLUDED."pool_id",
  "withdrawnToken1" = EXCLUDED."withdrawnToken1",
  "collectedToken1" = EXCLUDED."collectedToken1",
  "depositedToken0" = EXCLUDED."depositedToken0",
  "withdrawnToken0" = EXCLUDED."withdrawnToken0",
  "depositedToken1" = EXCLUDED."depositedToken1",
  "collectedToken0" = EXCLUDED."collectedToken0",
  "tickUpper_id" = EXCLUDED."tickUpper_id",
  "collectedFeesToken0" = EXCLUDED."collectedFeesToken0"
  `;
}

module.exports.batchSetPosition = (sql, entityDataArray) => {

  return chunkBatchQuery(
    sql, 
    entityDataArray, 
    batchSetPositionCore
  );
}

module.exports.batchDeletePosition = (sql, entityIdArray) => sql`
DELETE
FROM "public"."Position"
WHERE id IN ${sql(entityIdArray)};`
// end db operations for Position

//////////////////////////////////////////////
// DB operations for PositionSnapshot:
//////////////////////////////////////////////

module.exports.readPositionSnapshotEntities = (sql, entityIdArray) => sql`
SELECT 
"owner",
"depositedToken1",
"feeGrowthInside0LastX128",
"withdrawnToken1",
"id",
"timestamp",
"pool_id",
"position_id",
"liquidity",
"collectedFeesToken0",
"transaction_id",
"depositedToken0",
"feeGrowthInside1LastX128",
"collectedFeesToken1",
"blockNumber",
"withdrawnToken0"
FROM "public"."PositionSnapshot"
WHERE id IN ${sql(entityIdArray)};`;

const batchSetPositionSnapshotCore = (sql, entityDataArray) => {
  return sql`
    INSERT INTO "public"."PositionSnapshot"
${sql(entityDataArray,
    "owner",
    "depositedToken1",
    "feeGrowthInside0LastX128",
    "withdrawnToken1",
    "id",
    "timestamp",
    "pool_id",
    "position_id",
    "liquidity",
    "collectedFeesToken0",
    "transaction_id",
    "depositedToken0",
    "feeGrowthInside1LastX128",
    "collectedFeesToken1",
    "blockNumber",
    "withdrawnToken0"
  )}
  ON CONFLICT(id) DO UPDATE
  SET
  "owner" = EXCLUDED."owner",
  "depositedToken1" = EXCLUDED."depositedToken1",
  "feeGrowthInside0LastX128" = EXCLUDED."feeGrowthInside0LastX128",
  "withdrawnToken1" = EXCLUDED."withdrawnToken1",
  "id" = EXCLUDED."id",
  "timestamp" = EXCLUDED."timestamp",
  "pool_id" = EXCLUDED."pool_id",
  "position_id" = EXCLUDED."position_id",
  "liquidity" = EXCLUDED."liquidity",
  "collectedFeesToken0" = EXCLUDED."collectedFeesToken0",
  "transaction_id" = EXCLUDED."transaction_id",
  "depositedToken0" = EXCLUDED."depositedToken0",
  "feeGrowthInside1LastX128" = EXCLUDED."feeGrowthInside1LastX128",
  "collectedFeesToken1" = EXCLUDED."collectedFeesToken1",
  "blockNumber" = EXCLUDED."blockNumber",
  "withdrawnToken0" = EXCLUDED."withdrawnToken0"
  `;
}

module.exports.batchSetPositionSnapshot = (sql, entityDataArray) => {

  return chunkBatchQuery(
    sql, 
    entityDataArray, 
    batchSetPositionSnapshotCore
  );
}

module.exports.batchDeletePositionSnapshot = (sql, entityIdArray) => sql`
DELETE
FROM "public"."PositionSnapshot"
WHERE id IN ${sql(entityIdArray)};`
// end db operations for PositionSnapshot

//////////////////////////////////////////////
// DB operations for Swap:
//////////////////////////////////////////////

module.exports.readSwapEntities = (sql, entityIdArray) => sql`
SELECT 
"origin",
"sqrtPriceX96",
"tick_id",
"amount0",
"transaction_id",
"timestamp",
"amount1",
"token1_id",
"logIndex",
"sender",
"recipient",
"amountUSD",
"token0_id",
"id",
"pool_id"
FROM "public"."Swap"
WHERE id IN ${sql(entityIdArray)};`;

const batchSetSwapCore = (sql, entityDataArray) => {
  return sql`
    INSERT INTO "public"."Swap"
${sql(entityDataArray,
    "origin",
    "sqrtPriceX96",
    "tick_id",
    "amount0",
    "transaction_id",
    "timestamp",
    "amount1",
    "token1_id",
    "logIndex",
    "sender",
    "recipient",
    "amountUSD",
    "token0_id",
    "id",
    "pool_id"
  )}
  ON CONFLICT(id) DO UPDATE
  SET
  "origin" = EXCLUDED."origin",
  "sqrtPriceX96" = EXCLUDED."sqrtPriceX96",
  "tick_id" = EXCLUDED."tick_id",
  "amount0" = EXCLUDED."amount0",
  "transaction_id" = EXCLUDED."transaction_id",
  "timestamp" = EXCLUDED."timestamp",
  "amount1" = EXCLUDED."amount1",
  "token1_id" = EXCLUDED."token1_id",
  "logIndex" = EXCLUDED."logIndex",
  "sender" = EXCLUDED."sender",
  "recipient" = EXCLUDED."recipient",
  "amountUSD" = EXCLUDED."amountUSD",
  "token0_id" = EXCLUDED."token0_id",
  "id" = EXCLUDED."id",
  "pool_id" = EXCLUDED."pool_id"
  `;
}

module.exports.batchSetSwap = (sql, entityDataArray) => {

  return chunkBatchQuery(
    sql, 
    entityDataArray, 
    batchSetSwapCore
  );
}

module.exports.batchDeleteSwap = (sql, entityIdArray) => sql`
DELETE
FROM "public"."Swap"
WHERE id IN ${sql(entityIdArray)};`
// end db operations for Swap

//////////////////////////////////////////////
// DB operations for Tick:
//////////////////////////////////////////////

module.exports.readTickEntities = (sql, entityIdArray) => sql`
SELECT 
"collectedFeesToken1",
"createdAtTimestamp",
"createdAtBlockNumber",
"id",
"liquidityNet",
"volumeToken0",
"volumeToken1",
"collectedFeesToken0",
"collectedFeesUSD",
"feeGrowthOutside1X128",
"price1",
"liquidityProviderCount",
"feeGrowthOutside0X128",
"liquidityGross",
"volumeUSD",
"price0",
"untrackedVolumeUSD",
"poolAddress",
"feesUSD",
"pool_id",
"tickIdx"
FROM "public"."Tick"
WHERE id IN ${sql(entityIdArray)};`;

const batchSetTickCore = (sql, entityDataArray) => {
  return sql`
    INSERT INTO "public"."Tick"
${sql(entityDataArray,
    "collectedFeesToken1",
    "createdAtTimestamp",
    "createdAtBlockNumber",
    "id",
    "liquidityNet",
    "volumeToken0",
    "volumeToken1",
    "collectedFeesToken0",
    "collectedFeesUSD",
    "feeGrowthOutside1X128",
    "price1",
    "liquidityProviderCount",
    "feeGrowthOutside0X128",
    "liquidityGross",
    "volumeUSD",
    "price0",
    "untrackedVolumeUSD",
    "poolAddress",
    "feesUSD",
    "pool_id",
    "tickIdx"
  )}
  ON CONFLICT(id) DO UPDATE
  SET
  "collectedFeesToken1" = EXCLUDED."collectedFeesToken1",
  "createdAtTimestamp" = EXCLUDED."createdAtTimestamp",
  "createdAtBlockNumber" = EXCLUDED."createdAtBlockNumber",
  "id" = EXCLUDED."id",
  "liquidityNet" = EXCLUDED."liquidityNet",
  "volumeToken0" = EXCLUDED."volumeToken0",
  "volumeToken1" = EXCLUDED."volumeToken1",
  "collectedFeesToken0" = EXCLUDED."collectedFeesToken0",
  "collectedFeesUSD" = EXCLUDED."collectedFeesUSD",
  "feeGrowthOutside1X128" = EXCLUDED."feeGrowthOutside1X128",
  "price1" = EXCLUDED."price1",
  "liquidityProviderCount" = EXCLUDED."liquidityProviderCount",
  "feeGrowthOutside0X128" = EXCLUDED."feeGrowthOutside0X128",
  "liquidityGross" = EXCLUDED."liquidityGross",
  "volumeUSD" = EXCLUDED."volumeUSD",
  "price0" = EXCLUDED."price0",
  "untrackedVolumeUSD" = EXCLUDED."untrackedVolumeUSD",
  "poolAddress" = EXCLUDED."poolAddress",
  "feesUSD" = EXCLUDED."feesUSD",
  "pool_id" = EXCLUDED."pool_id",
  "tickIdx" = EXCLUDED."tickIdx"
  `;
}

module.exports.batchSetTick = (sql, entityDataArray) => {

  return chunkBatchQuery(
    sql, 
    entityDataArray, 
    batchSetTickCore
  );
}

module.exports.batchDeleteTick = (sql, entityIdArray) => sql`
DELETE
FROM "public"."Tick"
WHERE id IN ${sql(entityIdArray)};`
// end db operations for Tick

//////////////////////////////////////////////
// DB operations for TickDayData:
//////////////////////////////////////////////

module.exports.readTickDayDataEntities = (sql, entityIdArray) => sql`
SELECT 
"feesUSD",
"pool_id",
"tick_id",
"date",
"liquidityNet",
"feeGrowthOutside0X128",
"volumeUSD",
"feeGrowthOutside1X128",
"volumeToken1",
"id",
"volumeToken0",
"liquidityGross"
FROM "public"."TickDayData"
WHERE id IN ${sql(entityIdArray)};`;

const batchSetTickDayDataCore = (sql, entityDataArray) => {
  return sql`
    INSERT INTO "public"."TickDayData"
${sql(entityDataArray,
    "feesUSD",
    "pool_id",
    "tick_id",
    "date",
    "liquidityNet",
    "feeGrowthOutside0X128",
    "volumeUSD",
    "feeGrowthOutside1X128",
    "volumeToken1",
    "id",
    "volumeToken0",
    "liquidityGross"
  )}
  ON CONFLICT(id) DO UPDATE
  SET
  "feesUSD" = EXCLUDED."feesUSD",
  "pool_id" = EXCLUDED."pool_id",
  "tick_id" = EXCLUDED."tick_id",
  "date" = EXCLUDED."date",
  "liquidityNet" = EXCLUDED."liquidityNet",
  "feeGrowthOutside0X128" = EXCLUDED."feeGrowthOutside0X128",
  "volumeUSD" = EXCLUDED."volumeUSD",
  "feeGrowthOutside1X128" = EXCLUDED."feeGrowthOutside1X128",
  "volumeToken1" = EXCLUDED."volumeToken1",
  "id" = EXCLUDED."id",
  "volumeToken0" = EXCLUDED."volumeToken0",
  "liquidityGross" = EXCLUDED."liquidityGross"
  `;
}

module.exports.batchSetTickDayData = (sql, entityDataArray) => {

  return chunkBatchQuery(
    sql, 
    entityDataArray, 
    batchSetTickDayDataCore
  );
}

module.exports.batchDeleteTickDayData = (sql, entityIdArray) => sql`
DELETE
FROM "public"."TickDayData"
WHERE id IN ${sql(entityIdArray)};`
// end db operations for TickDayData

//////////////////////////////////////////////
// DB operations for TickHourData:
//////////////////////////////////////////////

module.exports.readTickHourDataEntities = (sql, entityIdArray) => sql`
SELECT 
"id",
"tick_id",
"liquidityGross",
"volumeToken0",
"liquidityNet",
"volumeUSD",
"pool_id",
"feesUSD",
"periodStartUnix",
"volumeToken1"
FROM "public"."TickHourData"
WHERE id IN ${sql(entityIdArray)};`;

const batchSetTickHourDataCore = (sql, entityDataArray) => {
  return sql`
    INSERT INTO "public"."TickHourData"
${sql(entityDataArray,
    "id",
    "tick_id",
    "liquidityGross",
    "volumeToken0",
    "liquidityNet",
    "volumeUSD",
    "pool_id",
    "feesUSD",
    "periodStartUnix",
    "volumeToken1"
  )}
  ON CONFLICT(id) DO UPDATE
  SET
  "id" = EXCLUDED."id",
  "tick_id" = EXCLUDED."tick_id",
  "liquidityGross" = EXCLUDED."liquidityGross",
  "volumeToken0" = EXCLUDED."volumeToken0",
  "liquidityNet" = EXCLUDED."liquidityNet",
  "volumeUSD" = EXCLUDED."volumeUSD",
  "pool_id" = EXCLUDED."pool_id",
  "feesUSD" = EXCLUDED."feesUSD",
  "periodStartUnix" = EXCLUDED."periodStartUnix",
  "volumeToken1" = EXCLUDED."volumeToken1"
  `;
}

module.exports.batchSetTickHourData = (sql, entityDataArray) => {

  return chunkBatchQuery(
    sql, 
    entityDataArray, 
    batchSetTickHourDataCore
  );
}

module.exports.batchDeleteTickHourData = (sql, entityIdArray) => sql`
DELETE
FROM "public"."TickHourData"
WHERE id IN ${sql(entityIdArray)};`
// end db operations for TickHourData

//////////////////////////////////////////////
// DB operations for Token:
//////////////////////////////////////////////

module.exports.readTokenEntities = (sql, entityIdArray) => sql`
SELECT 
"txCount",
"untrackedVolumeUSD",
"derivedETH",
"name",
"symbol",
"feesUSD",
"totalValueLocked",
"id",
"volumeUSD",
"totalSupply",
"poolCount",
"decimals",
"volume",
"totalValueLockedUSDUntracked",
"totalValueLockedUSD"
FROM "public"."Token"
WHERE id IN ${sql(entityIdArray)};`;

const batchSetTokenCore = (sql, entityDataArray) => {
  return sql`
    INSERT INTO "public"."Token"
${sql(entityDataArray,
    "txCount",
    "untrackedVolumeUSD",
    "derivedETH",
    "name",
    "symbol",
    "feesUSD",
    "totalValueLocked",
    "id",
    "volumeUSD",
    "totalSupply",
    "poolCount",
    "decimals",
    "volume",
    "totalValueLockedUSDUntracked",
    "totalValueLockedUSD"
  )}
  ON CONFLICT(id) DO UPDATE
  SET
  "txCount" = EXCLUDED."txCount",
  "untrackedVolumeUSD" = EXCLUDED."untrackedVolumeUSD",
  "derivedETH" = EXCLUDED."derivedETH",
  "name" = EXCLUDED."name",
  "symbol" = EXCLUDED."symbol",
  "feesUSD" = EXCLUDED."feesUSD",
  "totalValueLocked" = EXCLUDED."totalValueLocked",
  "id" = EXCLUDED."id",
  "volumeUSD" = EXCLUDED."volumeUSD",
  "totalSupply" = EXCLUDED."totalSupply",
  "poolCount" = EXCLUDED."poolCount",
  "decimals" = EXCLUDED."decimals",
  "volume" = EXCLUDED."volume",
  "totalValueLockedUSDUntracked" = EXCLUDED."totalValueLockedUSDUntracked",
  "totalValueLockedUSD" = EXCLUDED."totalValueLockedUSD"
  `;
}

module.exports.batchSetToken = (sql, entityDataArray) => {

  return chunkBatchQuery(
    sql, 
    entityDataArray, 
    batchSetTokenCore
  );
}

module.exports.batchDeleteToken = (sql, entityIdArray) => sql`
DELETE
FROM "public"."Token"
WHERE id IN ${sql(entityIdArray)};`
// end db operations for Token

//////////////////////////////////////////////
// DB operations for TokenDayData:
//////////////////////////////////////////////

module.exports.readTokenDayDataEntities = (sql, entityIdArray) => sql`
SELECT 
"high",
"totalValueLocked",
"low",
"feesUSD",
"close",
"volumeUSD",
"volume",
"untrackedVolumeUSD",
"totalValueLockedUSD",
"priceUSD",
"date",
"token_id",
"openPrice",
"id"
FROM "public"."TokenDayData"
WHERE id IN ${sql(entityIdArray)};`;

const batchSetTokenDayDataCore = (sql, entityDataArray) => {
  return sql`
    INSERT INTO "public"."TokenDayData"
${sql(entityDataArray,
    "high",
    "totalValueLocked",
    "low",
    "feesUSD",
    "close",
    "volumeUSD",
    "volume",
    "untrackedVolumeUSD",
    "totalValueLockedUSD",
    "priceUSD",
    "date",
    "token_id",
    "openPrice",
    "id"
  )}
  ON CONFLICT(id) DO UPDATE
  SET
  "high" = EXCLUDED."high",
  "totalValueLocked" = EXCLUDED."totalValueLocked",
  "low" = EXCLUDED."low",
  "feesUSD" = EXCLUDED."feesUSD",
  "close" = EXCLUDED."close",
  "volumeUSD" = EXCLUDED."volumeUSD",
  "volume" = EXCLUDED."volume",
  "untrackedVolumeUSD" = EXCLUDED."untrackedVolumeUSD",
  "totalValueLockedUSD" = EXCLUDED."totalValueLockedUSD",
  "priceUSD" = EXCLUDED."priceUSD",
  "date" = EXCLUDED."date",
  "token_id" = EXCLUDED."token_id",
  "openPrice" = EXCLUDED."openPrice",
  "id" = EXCLUDED."id"
  `;
}

module.exports.batchSetTokenDayData = (sql, entityDataArray) => {

  return chunkBatchQuery(
    sql, 
    entityDataArray, 
    batchSetTokenDayDataCore
  );
}

module.exports.batchDeleteTokenDayData = (sql, entityIdArray) => sql`
DELETE
FROM "public"."TokenDayData"
WHERE id IN ${sql(entityIdArray)};`
// end db operations for TokenDayData

//////////////////////////////////////////////
// DB operations for TokenHourData:
//////////////////////////////////////////////

module.exports.readTokenHourDataEntities = (sql, entityIdArray) => sql`
SELECT 
"untrackedVolumeUSD",
"token_id",
"priceUSD",
"openPrice",
"totalValueLockedUSD",
"volume",
"id",
"feesUSD",
"close",
"low",
"high",
"periodStartUnix",
"totalValueLocked",
"volumeUSD"
FROM "public"."TokenHourData"
WHERE id IN ${sql(entityIdArray)};`;

const batchSetTokenHourDataCore = (sql, entityDataArray) => {
  return sql`
    INSERT INTO "public"."TokenHourData"
${sql(entityDataArray,
    "untrackedVolumeUSD",
    "token_id",
    "priceUSD",
    "openPrice",
    "totalValueLockedUSD",
    "volume",
    "id",
    "feesUSD",
    "close",
    "low",
    "high",
    "periodStartUnix",
    "totalValueLocked",
    "volumeUSD"
  )}
  ON CONFLICT(id) DO UPDATE
  SET
  "untrackedVolumeUSD" = EXCLUDED."untrackedVolumeUSD",
  "token_id" = EXCLUDED."token_id",
  "priceUSD" = EXCLUDED."priceUSD",
  "openPrice" = EXCLUDED."openPrice",
  "totalValueLockedUSD" = EXCLUDED."totalValueLockedUSD",
  "volume" = EXCLUDED."volume",
  "id" = EXCLUDED."id",
  "feesUSD" = EXCLUDED."feesUSD",
  "close" = EXCLUDED."close",
  "low" = EXCLUDED."low",
  "high" = EXCLUDED."high",
  "periodStartUnix" = EXCLUDED."periodStartUnix",
  "totalValueLocked" = EXCLUDED."totalValueLocked",
  "volumeUSD" = EXCLUDED."volumeUSD"
  `;
}

module.exports.batchSetTokenHourData = (sql, entityDataArray) => {

  return chunkBatchQuery(
    sql, 
    entityDataArray, 
    batchSetTokenHourDataCore
  );
}

module.exports.batchDeleteTokenHourData = (sql, entityIdArray) => sql`
DELETE
FROM "public"."TokenHourData"
WHERE id IN ${sql(entityIdArray)};`
// end db operations for TokenHourData

//////////////////////////////////////////////
// DB operations for TokenPoolWhitelist:
//////////////////////////////////////////////

module.exports.readTokenPoolWhitelistEntities = (sql, entityIdArray) => sql`
SELECT 
"token_id",
"pool_id",
"id"
FROM "public"."TokenPoolWhitelist"
WHERE id IN ${sql(entityIdArray)};`;

const batchSetTokenPoolWhitelistCore = (sql, entityDataArray) => {
  return sql`
    INSERT INTO "public"."TokenPoolWhitelist"
${sql(entityDataArray,
    "token_id",
    "pool_id",
    "id"
  )}
  ON CONFLICT(id) DO UPDATE
  SET
  "token_id" = EXCLUDED."token_id",
  "pool_id" = EXCLUDED."pool_id",
  "id" = EXCLUDED."id"
  `;
}

module.exports.batchSetTokenPoolWhitelist = (sql, entityDataArray) => {

  return chunkBatchQuery(
    sql, 
    entityDataArray, 
    batchSetTokenPoolWhitelistCore
  );
}

module.exports.batchDeleteTokenPoolWhitelist = (sql, entityIdArray) => sql`
DELETE
FROM "public"."TokenPoolWhitelist"
WHERE id IN ${sql(entityIdArray)};`
// end db operations for TokenPoolWhitelist

//////////////////////////////////////////////
// DB operations for Transaction:
//////////////////////////////////////////////

module.exports.readTransactionEntities = (sql, entityIdArray) => sql`
SELECT 
"blockNumber",
"id",
"timestamp",
"gasPrice",
"gasUsed"
FROM "public"."Transaction"
WHERE id IN ${sql(entityIdArray)};`;

const batchSetTransactionCore = (sql, entityDataArray) => {
  return sql`
    INSERT INTO "public"."Transaction"
${sql(entityDataArray,
    "blockNumber",
    "id",
    "timestamp",
    "gasPrice",
    "gasUsed"
  )}
  ON CONFLICT(id) DO UPDATE
  SET
  "blockNumber" = EXCLUDED."blockNumber",
  "id" = EXCLUDED."id",
  "timestamp" = EXCLUDED."timestamp",
  "gasPrice" = EXCLUDED."gasPrice",
  "gasUsed" = EXCLUDED."gasUsed"
  `;
}

module.exports.batchSetTransaction = (sql, entityDataArray) => {

  return chunkBatchQuery(
    sql, 
    entityDataArray, 
    batchSetTransactionCore
  );
}

module.exports.batchDeleteTransaction = (sql, entityIdArray) => sql`
DELETE
FROM "public"."Transaction"
WHERE id IN ${sql(entityIdArray)};`
// end db operations for Transaction

//////////////////////////////////////////////
// DB operations for UniswapDayData:
//////////////////////////////////////////////

module.exports.readUniswapDayDataEntities = (sql, entityIdArray) => sql`
SELECT 
"volumeUSD",
"feesUSD",
"id",
"tvlUSD",
"txCount",
"volumeETH",
"volumeUSDUntracked",
"date"
FROM "public"."UniswapDayData"
WHERE id IN ${sql(entityIdArray)};`;

const batchSetUniswapDayDataCore = (sql, entityDataArray) => {
  return sql`
    INSERT INTO "public"."UniswapDayData"
${sql(entityDataArray,
    "volumeUSD",
    "feesUSD",
    "id",
    "tvlUSD",
    "txCount",
    "volumeETH",
    "volumeUSDUntracked",
    "date"
  )}
  ON CONFLICT(id) DO UPDATE
  SET
  "volumeUSD" = EXCLUDED."volumeUSD",
  "feesUSD" = EXCLUDED."feesUSD",
  "id" = EXCLUDED."id",
  "tvlUSD" = EXCLUDED."tvlUSD",
  "txCount" = EXCLUDED."txCount",
  "volumeETH" = EXCLUDED."volumeETH",
  "volumeUSDUntracked" = EXCLUDED."volumeUSDUntracked",
  "date" = EXCLUDED."date"
  `;
}

module.exports.batchSetUniswapDayData = (sql, entityDataArray) => {

  return chunkBatchQuery(
    sql, 
    entityDataArray, 
    batchSetUniswapDayDataCore
  );
}

module.exports.batchDeleteUniswapDayData = (sql, entityIdArray) => sql`
DELETE
FROM "public"."UniswapDayData"
WHERE id IN ${sql(entityIdArray)};`
// end db operations for UniswapDayData

