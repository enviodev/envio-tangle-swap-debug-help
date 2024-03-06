let sql = Postgres.makeSql(~config=Config.db->Obj.magic /* TODO: make this have the correct type */)

module EventSyncState = {
  let createEventSyncStateTable: unit => promise<unit> = async () => {
    let _ = await %raw("sql`
      CREATE TABLE IF NOT EXISTS public.event_sync_state (
        chain_id INTEGER NOT NULL,
        block_number INTEGER NOT NULL,
        log_index INTEGER NOT NULL,
        transaction_index INTEGER NOT NULL,
        block_timestamp INTEGER NOT NULL,
        PRIMARY KEY (chain_id)
      );
      `")
  }

  let dropEventSyncStateTable = async () => {
    let _ = await %raw("sql`
      DROP TABLE IF EXISTS public.event_sync_state;
    `")
  }
}

module ChainMetadata = {
  let createChainMetadataTable: unit => promise<unit> = async () => {
    let _ = await %raw("sql`
      CREATE TABLE IF NOT EXISTS public.chain_metadata (
        chain_id INTEGER NOT NULL,
        start_block INTEGER NOT NULL,
        block_height INTEGER NOT NULL,
        PRIMARY KEY (chain_id)
      );
      `")
  }

  let dropChainMetadataTable = async () => {
    let _ = await %raw("sql`
      DROP TABLE IF EXISTS public.chain_metadata;
    `")
  }
}

module PersistedState = {
  let createPersistedStateTable: unit => promise<unit> = async () => {
    let _ = await %raw("sql`
      CREATE TABLE IF NOT EXISTS public.persisted_state (
        id SERIAL PRIMARY KEY,
        envio_version TEXT NOT NULL, 
        config_hash TEXT NOT NULL,
        schema_hash TEXT NOT NULL,
        handler_files_hash TEXT NOT NULL,
        abi_files_hash TEXT NOT NULL
      );
      `")
  }

  let dropPersistedStateTable = async () => {
    let _ = await %raw("sql`
      DROP TABLE IF EXISTS public.persisted_state;
    `")
  }
}

module SyncBatchMetadata = {
  let createSyncBatchTable: unit => promise<unit> = async () => {
    @warning("-21")
    let _ = await %raw("sql`
      CREATE TABLE IF NOT EXISTS public.sync_batch (
        chain_id INTEGER NOT NULL,
        block_timestamp_range_end INTEGER NOT NULL,
        block_number_range_end INTEGER NOT NULL,
        block_hash_range_end TEXT NOT NULL,
        PRIMARY KEY (chain_id, block_number_range_end)
      );
      `")
  }

  @@warning("-21")
  let dropSyncStateTable = async () => {
    let _ = await %raw("sql`
      DROP TABLE IF EXISTS public.sync_batch;
    `")
  }
  @@warning("+21")
}

module RawEventsTable = {
  let createEventTypeEnum: unit => promise<unit> = async () => {
    @warning("-21")
    let _ = await %raw("sql`
      DO $$ BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'event_type') THEN
          CREATE TYPE EVENT_TYPE AS ENUM(
          'Factory_PoolCreated',
          'NonfungiblePositionManager_IncreaseLiquidity',
          'NonfungiblePositionManager_DecreaseLiquidity',
          'NonfungiblePositionManager_Transfer',
          'Pool_Swap'
          );
        END IF;
      END $$;
      `")
  }

  let createRawEventsTable: unit => promise<unit> = async () => {
    let _ = await createEventTypeEnum()

    @warning("-21")
    let _ = await %raw("sql`
      CREATE TABLE IF NOT EXISTS public.raw_events (
        chain_id INTEGER NOT NULL,
        event_id NUMERIC NOT NULL,
        block_number INTEGER NOT NULL,
        log_index INTEGER NOT NULL,
        transaction_index INTEGER NOT NULL,
        transaction_hash TEXT NOT NULL,
        src_address TEXT NOT NULL,
        block_hash TEXT NOT NULL,
        block_timestamp INTEGER NOT NULL,
        event_type EVENT_TYPE NOT NULL,
        params JSON NOT NULL,
        db_write_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        PRIMARY KEY (chain_id, event_id)
      );
      `")
  }

  @@warning("-21")
  let dropRawEventsTable = async () => {
    let _ = await %raw("sql`
      DROP TABLE IF EXISTS public.raw_events;
    `")
    let _ = await %raw("sql`
      DROP TYPE IF EXISTS EVENT_TYPE CASCADE;
    `")
  }
  @@warning("+21")
}

module DynamicContractRegistryTable = {
  let createDynamicContractRegistryTable: unit => promise<unit> = async () => {
    @warning("-21")
    let _ = await %raw("sql`
      DO $$ BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'contract_type') THEN
          CREATE TYPE CONTRACT_TYPE AS ENUM (
          'Factory',
          'NonfungiblePositionManager',
          'Pool'
          );
        END IF;
      END $$;
      `")

    @warning("-21")
    let _ = await %raw("sql`
      CREATE TABLE IF NOT EXISTS public.dynamic_contract_registry (
        chain_id INTEGER NOT NULL,
        event_id NUMERIC NOT NULL,
        contract_address TEXT NOT NULL,
        contract_type CONTRACT_TYPE NOT NULL,
        PRIMARY KEY (chain_id, contract_address)
      );
      `")
  }

  @@warning("-21")
  let dropDynamicContractRegistryTable = async () => {
    let _ = await %raw("sql`
      DROP TABLE IF EXISTS public.dynamic_contract_registry;
    `")
    let _ = await %raw("sql`
      DROP TYPE IF EXISTS EVENT_TYPE CASCADE;
    `")
  }
  @@warning("+21")
}

module EnumTypes = {}

module EntityHistory = {
  let createEntityTypeEnum: unit => promise<unit> = async () => {
    @warning("-21")
    let _ = await %raw("sql`
      DO $$ BEGIN
        IF NOT EXISTS (SELECT 1 FROM pg_type WHERE typname = 'entity_type') THEN
          CREATE TYPE ENTITY_TYPE AS ENUM(
            'Bundle',
            'Burn',
            'Collect',
            'Factory',
            'Flash',
            'Mint',
            'Pool',
            'PoolDayData',
            'PoolHourData',
            'Position',
            'PositionSnapshot',
            'Swap',
            'Tick',
            'TickDayData',
            'TickHourData',
            'Token',
            'TokenDayData',
            'TokenHourData',
            'TokenPoolWhitelist',
            'Transaction',
            'UniswapDayData'
          );
        END IF;
      END $$;
      `")
  }

  let createEntityHistoryTable: unit => promise<unit> = async () => {
    let _ = await createEntityTypeEnum()

    // NULL for an `entity_id` means that the entity was deleted.
    await %raw("sql`
      CREATE TABLE \"public\".\"A\" (
        chain_id INTEGER NOT NULL,
        block_number INTEGER NOT NULL,
        log_index INTEGER NOT NULL,
        transaction_hash BYTEA NOT NULL,
        entity_type ENTITY_TYPE NOT NULL,
        entity_id TEXT,
        PRIMARY KEY (entity_id, chain_id, block_number, log_index));
      `")
  }

  // NOTE: didn't add 'delete' functions here - delete functions aren't being used currently.
}

module Bundle = {
  let createBundleTable: unit => promise<unit> = async () => {
    await %raw("sql`
      CREATE TABLE \"public\".\"Bundle\" (\"id\" text NOT NULL,\"ethPriceUSD\" numeric NOT NULL, 
        db_write_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
        PRIMARY KEY (\"id\"));`")
  }

  let createBundleHistoryTable: unit => promise<unit> = async () => {
    // Rather using chain_id + log_index + block_number and not also "transaction_hash TEXT NOT NULL"
    await %raw("sql`
      CREATE TABLE \"public\".\"Bundle_history\" (
        chain_id INTEGER NOT NULL,
        block_number INTEGER NOT NULL,
        log_index INTEGER NOT NULL,
        \"id\" text NOT NULL,
        \"ethPriceUSD\" numeric NOT NULL,
        db_write_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
        PRIMARY KEY (\"id\", chain_id, block_number, log_index));`")
  }

  let deleteBundleTable: unit => promise<unit> = async () => {
    // NOTE: we can refine the `IF EXISTS` part because this now prints to the terminal if the table doesn't exist (which isn't nice for the developer).
    await %raw("sql`DROP TABLE IF EXISTS \"public\".\"Bundle\";`")
  }
}

module Burn = {
  let createBurnTable: unit => promise<unit> = async () => {
    await %raw("sql`
      CREATE TABLE \"public\".\"Burn\" (\"timestamp\" numeric NOT NULL,\"transaction_id\" text NOT NULL,\"token0_id\" text NOT NULL,\"tickLower\" numeric NOT NULL,\"pool_id\" text NOT NULL,\"amountUSD\" numeric,\"amount0\" numeric NOT NULL,\"tickUpper\" numeric NOT NULL,\"amount1\" numeric NOT NULL,\"id\" text NOT NULL,\"owner\" text,\"amount\" numeric NOT NULL,\"token1_id\" text NOT NULL,\"origin\" text NOT NULL,\"logIndex\" numeric, 
        db_write_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
        PRIMARY KEY (\"id\"));`")
  }

  let createBurnHistoryTable: unit => promise<unit> = async () => {
    // Rather using chain_id + log_index + block_number and not also "transaction_hash TEXT NOT NULL"
    await %raw("sql`
      CREATE TABLE \"public\".\"Burn_history\" (
        chain_id INTEGER NOT NULL,
        block_number INTEGER NOT NULL,
        log_index INTEGER NOT NULL,
        \"timestamp\" numeric NOT NULL,
        \"transaction\" text NOT NULL,
        \"token0\" text NOT NULL,
        \"tickLower\" numeric NOT NULL,
        \"pool\" text NOT NULL,
        \"amountUSD\" numeric,
        \"amount0\" numeric NOT NULL,
        \"tickUpper\" numeric NOT NULL,
        \"amount1\" numeric NOT NULL,
        \"id\" text NOT NULL,
        \"owner\" text,
        \"amount\" numeric NOT NULL,
        \"token1\" text NOT NULL,
        \"origin\" text NOT NULL,
        \"logIndex\" numeric,
        db_write_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
        PRIMARY KEY (\"id\", chain_id, block_number, log_index));`")
  }

  let deleteBurnTable: unit => promise<unit> = async () => {
    // NOTE: we can refine the `IF EXISTS` part because this now prints to the terminal if the table doesn't exist (which isn't nice for the developer).
    await %raw("sql`DROP TABLE IF EXISTS \"public\".\"Burn\";`")
  }
}

module Collect = {
  let createCollectTable: unit => promise<unit> = async () => {
    await %raw("sql`
      CREATE TABLE \"public\".\"Collect\" (\"amountUSD\" numeric,\"owner\" text,\"id\" text NOT NULL,\"amount0\" numeric NOT NULL,\"transaction_id\" text NOT NULL,\"timestamp\" numeric NOT NULL,\"pool_id\" text NOT NULL,\"amount1\" numeric NOT NULL,\"tickLower\" numeric NOT NULL,\"tickUpper\" numeric NOT NULL,\"logIndex\" numeric, 
        db_write_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
        PRIMARY KEY (\"id\"));`")
  }

  let createCollectHistoryTable: unit => promise<unit> = async () => {
    // Rather using chain_id + log_index + block_number and not also "transaction_hash TEXT NOT NULL"
    await %raw("sql`
      CREATE TABLE \"public\".\"Collect_history\" (
        chain_id INTEGER NOT NULL,
        block_number INTEGER NOT NULL,
        log_index INTEGER NOT NULL,
        \"amountUSD\" numeric,
        \"owner\" text,
        \"id\" text NOT NULL,
        \"amount0\" numeric NOT NULL,
        \"transaction\" text NOT NULL,
        \"timestamp\" numeric NOT NULL,
        \"pool\" text NOT NULL,
        \"amount1\" numeric NOT NULL,
        \"tickLower\" numeric NOT NULL,
        \"tickUpper\" numeric NOT NULL,
        \"logIndex\" numeric,
        db_write_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
        PRIMARY KEY (\"id\", chain_id, block_number, log_index));`")
  }

  let deleteCollectTable: unit => promise<unit> = async () => {
    // NOTE: we can refine the `IF EXISTS` part because this now prints to the terminal if the table doesn't exist (which isn't nice for the developer).
    await %raw("sql`DROP TABLE IF EXISTS \"public\".\"Collect\";`")
  }
}

module Factory = {
  let createFactoryTable: unit => promise<unit> = async () => {
    await %raw("sql`
      CREATE TABLE \"public\".\"Factory\" (\"totalValueLockedUSD\" numeric NOT NULL,\"id\" text NOT NULL,\"totalFeesETH\" numeric NOT NULL,\"totalValueLockedETHUntracked\" numeric NOT NULL,\"totalValueLockedUSDUntracked\" numeric NOT NULL,\"totalValueLockedETH\" numeric NOT NULL,\"owner\" text NOT NULL,\"totalVolumeUSD\" numeric NOT NULL,\"txCount\" numeric NOT NULL,\"totalFeesUSD\" numeric NOT NULL,\"poolCount\" numeric NOT NULL,\"untrackedVolumeUSD\" numeric NOT NULL,\"totalVolumeETH\" numeric NOT NULL, 
        db_write_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
        PRIMARY KEY (\"id\"));`")
  }

  let createFactoryHistoryTable: unit => promise<unit> = async () => {
    // Rather using chain_id + log_index + block_number and not also "transaction_hash TEXT NOT NULL"
    await %raw("sql`
      CREATE TABLE \"public\".\"Factory_history\" (
        chain_id INTEGER NOT NULL,
        block_number INTEGER NOT NULL,
        log_index INTEGER NOT NULL,
        \"totalValueLockedUSD\" numeric NOT NULL,
        \"id\" text NOT NULL,
        \"totalFeesETH\" numeric NOT NULL,
        \"totalValueLockedETHUntracked\" numeric NOT NULL,
        \"totalValueLockedUSDUntracked\" numeric NOT NULL,
        \"totalValueLockedETH\" numeric NOT NULL,
        \"owner\" text NOT NULL,
        \"totalVolumeUSD\" numeric NOT NULL,
        \"txCount\" numeric NOT NULL,
        \"totalFeesUSD\" numeric NOT NULL,
        \"poolCount\" numeric NOT NULL,
        \"untrackedVolumeUSD\" numeric NOT NULL,
        \"totalVolumeETH\" numeric NOT NULL,
        db_write_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
        PRIMARY KEY (\"id\", chain_id, block_number, log_index));`")
  }

  let deleteFactoryTable: unit => promise<unit> = async () => {
    // NOTE: we can refine the `IF EXISTS` part because this now prints to the terminal if the table doesn't exist (which isn't nice for the developer).
    await %raw("sql`DROP TABLE IF EXISTS \"public\".\"Factory\";`")
  }
}

module Flash = {
  let createFlashTable: unit => promise<unit> = async () => {
    await %raw("sql`
      CREATE TABLE \"public\".\"Flash\" (\"timestamp\" numeric NOT NULL,\"sender\" text NOT NULL,\"id\" text NOT NULL,\"pool_id\" text NOT NULL,\"amount1\" numeric NOT NULL,\"amountUSD\" numeric NOT NULL,\"amount0\" numeric NOT NULL,\"amount0Paid\" numeric NOT NULL,\"amount1Paid\" numeric NOT NULL,\"logIndex\" numeric,\"transaction_id\" text NOT NULL,\"recipient\" text NOT NULL, 
        db_write_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
        PRIMARY KEY (\"id\"));`")
  }

  let createFlashHistoryTable: unit => promise<unit> = async () => {
    // Rather using chain_id + log_index + block_number and not also "transaction_hash TEXT NOT NULL"
    await %raw("sql`
      CREATE TABLE \"public\".\"Flash_history\" (
        chain_id INTEGER NOT NULL,
        block_number INTEGER NOT NULL,
        log_index INTEGER NOT NULL,
        \"timestamp\" numeric NOT NULL,
        \"sender\" text NOT NULL,
        \"id\" text NOT NULL,
        \"pool\" text NOT NULL,
        \"amount1\" numeric NOT NULL,
        \"amountUSD\" numeric NOT NULL,
        \"amount0\" numeric NOT NULL,
        \"amount0Paid\" numeric NOT NULL,
        \"amount1Paid\" numeric NOT NULL,
        \"logIndex\" numeric,
        \"transaction\" text NOT NULL,
        \"recipient\" text NOT NULL,
        db_write_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
        PRIMARY KEY (\"id\", chain_id, block_number, log_index));`")
  }

  let deleteFlashTable: unit => promise<unit> = async () => {
    // NOTE: we can refine the `IF EXISTS` part because this now prints to the terminal if the table doesn't exist (which isn't nice for the developer).
    await %raw("sql`DROP TABLE IF EXISTS \"public\".\"Flash\";`")
  }
}

module Mint = {
  let createMintTable: unit => promise<unit> = async () => {
    await %raw("sql`
      CREATE TABLE \"public\".\"Mint\" (\"sender\" text,\"origin\" text NOT NULL,\"amount\" numeric NOT NULL,\"amount0\" numeric NOT NULL,\"tickUpper\" numeric NOT NULL,\"logIndex\" numeric,\"token0_id\" text NOT NULL,\"amountUSD\" numeric,\"transaction_id\" text NOT NULL,\"pool_id\" text NOT NULL,\"amount1\" numeric NOT NULL,\"tickLower\" numeric NOT NULL,\"id\" text NOT NULL,\"timestamp\" numeric NOT NULL,\"token1_id\" text NOT NULL,\"owner\" text NOT NULL, 
        db_write_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
        PRIMARY KEY (\"id\"));`")
  }

  let createMintHistoryTable: unit => promise<unit> = async () => {
    // Rather using chain_id + log_index + block_number and not also "transaction_hash TEXT NOT NULL"
    await %raw("sql`
      CREATE TABLE \"public\".\"Mint_history\" (
        chain_id INTEGER NOT NULL,
        block_number INTEGER NOT NULL,
        log_index INTEGER NOT NULL,
        \"sender\" text,
        \"origin\" text NOT NULL,
        \"amount\" numeric NOT NULL,
        \"amount0\" numeric NOT NULL,
        \"tickUpper\" numeric NOT NULL,
        \"logIndex\" numeric,
        \"token0\" text NOT NULL,
        \"amountUSD\" numeric,
        \"transaction\" text NOT NULL,
        \"pool\" text NOT NULL,
        \"amount1\" numeric NOT NULL,
        \"tickLower\" numeric NOT NULL,
        \"id\" text NOT NULL,
        \"timestamp\" numeric NOT NULL,
        \"token1\" text NOT NULL,
        \"owner\" text NOT NULL,
        db_write_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
        PRIMARY KEY (\"id\", chain_id, block_number, log_index));`")
  }

  let deleteMintTable: unit => promise<unit> = async () => {
    // NOTE: we can refine the `IF EXISTS` part because this now prints to the terminal if the table doesn't exist (which isn't nice for the developer).
    await %raw("sql`DROP TABLE IF EXISTS \"public\".\"Mint\";`")
  }
}

module Pool = {
  let createPoolTable: unit => promise<unit> = async () => {
    await %raw("sql`
      CREATE TABLE \"public\".\"Pool\" (\"token1_id\" text NOT NULL,\"volumeToken1\" numeric NOT NULL,\"id\" text NOT NULL,\"token0_id\" text NOT NULL,\"txCount\" numeric NOT NULL,\"tick\" numeric,\"liquidity\" numeric NOT NULL,\"observationIndex\" numeric NOT NULL,\"feeTier\" numeric NOT NULL,\"untrackedVolumeUSD\" numeric NOT NULL,\"collectedFeesUSD\" numeric NOT NULL,\"volumeToken0\" numeric NOT NULL,\"totalValueLockedUSD\" numeric NOT NULL,\"token1Price\" numeric NOT NULL,\"feeGrowthGlobal0X128\" numeric NOT NULL,\"totalValueLockedToken1\" numeric NOT NULL,\"liquidityProviderCount\" numeric NOT NULL,\"collectedFeesToken1\" numeric NOT NULL,\"volumeUSD\" numeric NOT NULL,\"createdAtTimestamp\" numeric NOT NULL,\"feeGrowthGlobal1X128\" numeric NOT NULL,\"sqrtPrice\" numeric NOT NULL,\"totalValueLockedToken0\" numeric NOT NULL,\"totalValueLockedETH\" numeric NOT NULL,\"totalValueLockedUSDUntracked\" numeric NOT NULL,\"feesUSD\" numeric NOT NULL,\"collectedFeesToken0\" numeric NOT NULL,\"token0Price\" numeric NOT NULL,\"createdAtBlockNumber\" numeric NOT NULL, 
        db_write_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
        PRIMARY KEY (\"id\"));`")
  }

  let createPoolHistoryTable: unit => promise<unit> = async () => {
    // Rather using chain_id + log_index + block_number and not also "transaction_hash TEXT NOT NULL"
    await %raw("sql`
      CREATE TABLE \"public\".\"Pool_history\" (
        chain_id INTEGER NOT NULL,
        block_number INTEGER NOT NULL,
        log_index INTEGER NOT NULL,
        \"token1\" text NOT NULL,
        \"volumeToken1\" numeric NOT NULL,
        \"id\" text NOT NULL,
        \"token0\" text NOT NULL,
        \"txCount\" numeric NOT NULL,
        \"tick\" numeric,
        \"liquidity\" numeric NOT NULL,
        \"observationIndex\" numeric NOT NULL,
        \"feeTier\" numeric NOT NULL,
        \"untrackedVolumeUSD\" numeric NOT NULL,
        
        
        \"collectedFeesUSD\" numeric NOT NULL,
        \"volumeToken0\" numeric NOT NULL,
        
        \"totalValueLockedUSD\" numeric NOT NULL,
        \"token1Price\" numeric NOT NULL,
        \"feeGrowthGlobal0X128\" numeric NOT NULL,
        \"totalValueLockedToken1\" numeric NOT NULL,
        \"liquidityProviderCount\" numeric NOT NULL,
        \"collectedFeesToken1\" numeric NOT NULL,
        \"volumeUSD\" numeric NOT NULL,
        
        \"createdAtTimestamp\" numeric NOT NULL,
        
        \"feeGrowthGlobal1X128\" numeric NOT NULL,
        
        \"sqrtPrice\" numeric NOT NULL,
        \"totalValueLockedToken0\" numeric NOT NULL,
        \"totalValueLockedETH\" numeric NOT NULL,
        \"totalValueLockedUSDUntracked\" numeric NOT NULL,
        \"feesUSD\" numeric NOT NULL,
        \"collectedFeesToken0\" numeric NOT NULL,
        
        
        \"token0Price\" numeric NOT NULL,
        \"createdAtBlockNumber\" numeric NOT NULL,
        db_write_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
        PRIMARY KEY (\"id\", chain_id, block_number, log_index));`")
  }

  let deletePoolTable: unit => promise<unit> = async () => {
    // NOTE: we can refine the `IF EXISTS` part because this now prints to the terminal if the table doesn't exist (which isn't nice for the developer).
    await %raw("sql`DROP TABLE IF EXISTS \"public\".\"Pool\";`")
  }
}

module PoolDayData = {
  let createPoolDayDataTable: unit => promise<unit> = async () => {
    await %raw("sql`
      CREATE TABLE \"public\".\"PoolDayData\" (\"tick\" numeric,\"feeGrowthGlobal1X128\" numeric NOT NULL,\"volumeUSD\" numeric NOT NULL,\"sqrtPrice\" numeric NOT NULL,\"feesUSD\" numeric NOT NULL,\"liquidity\" numeric NOT NULL,\"txCount\" numeric NOT NULL,\"openPrice0\" numeric NOT NULL,\"volumeToken0\" numeric NOT NULL,\"high\" numeric NOT NULL,\"low\" numeric NOT NULL,\"tvlUSD\" numeric NOT NULL,\"date\" integer NOT NULL,\"token1Price\" numeric NOT NULL,\"close\" numeric NOT NULL,\"token0Price\" numeric NOT NULL,\"pool_id\" text NOT NULL,\"feeGrowthGlobal0X128\" numeric NOT NULL,\"volumeToken1\" numeric NOT NULL,\"id\" text NOT NULL, 
        db_write_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
        PRIMARY KEY (\"id\"));`")
  }

  let createPoolDayDataHistoryTable: unit => promise<unit> = async () => {
    // Rather using chain_id + log_index + block_number and not also "transaction_hash TEXT NOT NULL"
    await %raw("sql`
      CREATE TABLE \"public\".\"PoolDayData_history\" (
        chain_id INTEGER NOT NULL,
        block_number INTEGER NOT NULL,
        log_index INTEGER NOT NULL,
        \"tick\" numeric,
        \"feeGrowthGlobal1X128\" numeric NOT NULL,
        \"volumeUSD\" numeric NOT NULL,
        \"sqrtPrice\" numeric NOT NULL,
        \"feesUSD\" numeric NOT NULL,
        \"liquidity\" numeric NOT NULL,
        \"txCount\" numeric NOT NULL,
        \"openPrice0\" numeric NOT NULL,
        \"volumeToken0\" numeric NOT NULL,
        \"high\" numeric NOT NULL,
        \"low\" numeric NOT NULL,
        \"tvlUSD\" numeric NOT NULL,
        \"date\" integer NOT NULL,
        \"token1Price\" numeric NOT NULL,
        \"close\" numeric NOT NULL,
        \"token0Price\" numeric NOT NULL,
        \"pool\" text NOT NULL,
        \"feeGrowthGlobal0X128\" numeric NOT NULL,
        \"volumeToken1\" numeric NOT NULL,
        \"id\" text NOT NULL,
        db_write_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
        PRIMARY KEY (\"id\", chain_id, block_number, log_index));`")
  }

  let deletePoolDayDataTable: unit => promise<unit> = async () => {
    // NOTE: we can refine the `IF EXISTS` part because this now prints to the terminal if the table doesn't exist (which isn't nice for the developer).
    await %raw("sql`DROP TABLE IF EXISTS \"public\".\"PoolDayData\";`")
  }
}

module PoolHourData = {
  let createPoolHourDataTable: unit => promise<unit> = async () => {
    await %raw("sql`
      CREATE TABLE \"public\".\"PoolHourData\" (\"token1Price\" numeric NOT NULL,\"feesUSD\" numeric NOT NULL,\"liquidity\" numeric NOT NULL,\"sqrtPrice\" numeric NOT NULL,\"volumeToken1\" numeric NOT NULL,\"pool_id\" text NOT NULL,\"tick\" numeric,\"feeGrowthGlobal1X128\" numeric NOT NULL,\"volumeUSD\" numeric NOT NULL,\"high\" numeric NOT NULL,\"openPrice0\" numeric NOT NULL,\"token0Price\" numeric NOT NULL,\"feeGrowthGlobal0X128\" numeric NOT NULL,\"txCount\" numeric NOT NULL,\"close\" numeric NOT NULL,\"tvlUSD\" numeric NOT NULL,\"volumeToken0\" numeric NOT NULL,\"periodStartUnix\" integer NOT NULL,\"id\" text NOT NULL,\"low\" numeric NOT NULL, 
        db_write_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
        PRIMARY KEY (\"id\"));`")
  }

  let createPoolHourDataHistoryTable: unit => promise<unit> = async () => {
    // Rather using chain_id + log_index + block_number and not also "transaction_hash TEXT NOT NULL"
    await %raw("sql`
      CREATE TABLE \"public\".\"PoolHourData_history\" (
        chain_id INTEGER NOT NULL,
        block_number INTEGER NOT NULL,
        log_index INTEGER NOT NULL,
        \"token1Price\" numeric NOT NULL,
        \"feesUSD\" numeric NOT NULL,
        \"liquidity\" numeric NOT NULL,
        \"sqrtPrice\" numeric NOT NULL,
        \"volumeToken1\" numeric NOT NULL,
        \"pool\" text NOT NULL,
        \"tick\" numeric,
        \"feeGrowthGlobal1X128\" numeric NOT NULL,
        \"volumeUSD\" numeric NOT NULL,
        \"high\" numeric NOT NULL,
        \"openPrice0\" numeric NOT NULL,
        \"token0Price\" numeric NOT NULL,
        \"feeGrowthGlobal0X128\" numeric NOT NULL,
        \"txCount\" numeric NOT NULL,
        \"close\" numeric NOT NULL,
        \"tvlUSD\" numeric NOT NULL,
        \"volumeToken0\" numeric NOT NULL,
        \"periodStartUnix\" integer NOT NULL,
        \"id\" text NOT NULL,
        \"low\" numeric NOT NULL,
        db_write_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
        PRIMARY KEY (\"id\", chain_id, block_number, log_index));`")
  }

  let deletePoolHourDataTable: unit => promise<unit> = async () => {
    // NOTE: we can refine the `IF EXISTS` part because this now prints to the terminal if the table doesn't exist (which isn't nice for the developer).
    await %raw("sql`DROP TABLE IF EXISTS \"public\".\"PoolHourData\";`")
  }
}

module Position = {
  let createPositionTable: unit => promise<unit> = async () => {
    await %raw("sql`
      CREATE TABLE \"public\".\"Position\" (\"owner\" text NOT NULL,\"feeGrowthInside0LastX128\" numeric NOT NULL,\"liquidity\" numeric NOT NULL,\"token1_id\" text NOT NULL,\"token0_id\" text NOT NULL,\"tickLower_id\" text NOT NULL,\"transaction_id\" text NOT NULL,\"collectedFeesToken1\" numeric NOT NULL,\"feeGrowthInside1LastX128\" numeric NOT NULL,\"id\" text NOT NULL,\"pool_id\" text NOT NULL,\"withdrawnToken1\" numeric NOT NULL,\"collectedToken1\" numeric NOT NULL,\"depositedToken0\" numeric NOT NULL,\"withdrawnToken0\" numeric NOT NULL,\"depositedToken1\" numeric NOT NULL,\"collectedToken0\" numeric NOT NULL,\"tickUpper_id\" text NOT NULL,\"collectedFeesToken0\" numeric NOT NULL, 
        db_write_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
        PRIMARY KEY (\"id\"));`")
  }

  let createPositionHistoryTable: unit => promise<unit> = async () => {
    // Rather using chain_id + log_index + block_number and not also "transaction_hash TEXT NOT NULL"
    await %raw("sql`
      CREATE TABLE \"public\".\"Position_history\" (
        chain_id INTEGER NOT NULL,
        block_number INTEGER NOT NULL,
        log_index INTEGER NOT NULL,
        \"owner\" text NOT NULL,
        \"feeGrowthInside0LastX128\" numeric NOT NULL,
        \"liquidity\" numeric NOT NULL,
        \"token1\" text NOT NULL,
        \"token0\" text NOT NULL,
        \"tickLower\" text NOT NULL,
        \"transaction\" text NOT NULL,
        \"collectedFeesToken1\" numeric NOT NULL,
        \"feeGrowthInside1LastX128\" numeric NOT NULL,
        \"id\" text NOT NULL,
        \"pool\" text NOT NULL,
        \"withdrawnToken1\" numeric NOT NULL,
        \"collectedToken1\" numeric NOT NULL,
        \"depositedToken0\" numeric NOT NULL,
        \"withdrawnToken0\" numeric NOT NULL,
        \"depositedToken1\" numeric NOT NULL,
        \"collectedToken0\" numeric NOT NULL,
        \"tickUpper\" text NOT NULL,
        \"collectedFeesToken0\" numeric NOT NULL,
        db_write_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
        PRIMARY KEY (\"id\", chain_id, block_number, log_index));`")
  }

  let deletePositionTable: unit => promise<unit> = async () => {
    // NOTE: we can refine the `IF EXISTS` part because this now prints to the terminal if the table doesn't exist (which isn't nice for the developer).
    await %raw("sql`DROP TABLE IF EXISTS \"public\".\"Position\";`")
  }
}

module PositionSnapshot = {
  let createPositionSnapshotTable: unit => promise<unit> = async () => {
    await %raw("sql`
      CREATE TABLE \"public\".\"PositionSnapshot\" (\"owner\" text NOT NULL,\"depositedToken1\" numeric NOT NULL,\"feeGrowthInside0LastX128\" numeric NOT NULL,\"withdrawnToken1\" numeric NOT NULL,\"id\" text NOT NULL,\"timestamp\" numeric NOT NULL,\"pool_id\" text NOT NULL,\"position_id\" text NOT NULL,\"liquidity\" numeric NOT NULL,\"collectedFeesToken0\" numeric NOT NULL,\"transaction_id\" text NOT NULL,\"depositedToken0\" numeric NOT NULL,\"feeGrowthInside1LastX128\" numeric NOT NULL,\"collectedFeesToken1\" numeric NOT NULL,\"blockNumber\" numeric NOT NULL,\"withdrawnToken0\" numeric NOT NULL, 
        db_write_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
        PRIMARY KEY (\"id\"));`")
  }

  let createPositionSnapshotHistoryTable: unit => promise<unit> = async () => {
    // Rather using chain_id + log_index + block_number and not also "transaction_hash TEXT NOT NULL"
    await %raw("sql`
      CREATE TABLE \"public\".\"PositionSnapshot_history\" (
        chain_id INTEGER NOT NULL,
        block_number INTEGER NOT NULL,
        log_index INTEGER NOT NULL,
        \"owner\" text NOT NULL,
        \"depositedToken1\" numeric NOT NULL,
        \"feeGrowthInside0LastX128\" numeric NOT NULL,
        \"withdrawnToken1\" numeric NOT NULL,
        \"id\" text NOT NULL,
        \"timestamp\" numeric NOT NULL,
        \"pool\" text NOT NULL,
        \"position\" text NOT NULL,
        \"liquidity\" numeric NOT NULL,
        \"collectedFeesToken0\" numeric NOT NULL,
        \"transaction\" text NOT NULL,
        \"depositedToken0\" numeric NOT NULL,
        \"feeGrowthInside1LastX128\" numeric NOT NULL,
        \"collectedFeesToken1\" numeric NOT NULL,
        \"blockNumber\" numeric NOT NULL,
        \"withdrawnToken0\" numeric NOT NULL,
        db_write_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
        PRIMARY KEY (\"id\", chain_id, block_number, log_index));`")
  }

  let deletePositionSnapshotTable: unit => promise<unit> = async () => {
    // NOTE: we can refine the `IF EXISTS` part because this now prints to the terminal if the table doesn't exist (which isn't nice for the developer).
    await %raw("sql`DROP TABLE IF EXISTS \"public\".\"PositionSnapshot\";`")
  }
}

module Swap = {
  let createSwapTable: unit => promise<unit> = async () => {
    await %raw("sql`
      CREATE TABLE \"public\".\"Swap\" (\"origin\" text NOT NULL,\"sqrtPriceX96\" numeric NOT NULL,\"tick_id\" text NOT NULL,\"amount0\" numeric NOT NULL,\"transaction_id\" text NOT NULL,\"timestamp\" numeric NOT NULL,\"amount1\" numeric NOT NULL,\"token1_id\" text NOT NULL,\"logIndex\" numeric,\"sender\" text NOT NULL,\"recipient\" text NOT NULL,\"amountUSD\" numeric NOT NULL,\"token0_id\" text NOT NULL,\"id\" text NOT NULL,\"pool_id\" text NOT NULL, 
        db_write_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
        PRIMARY KEY (\"id\"));`")
  }

  let createSwapHistoryTable: unit => promise<unit> = async () => {
    // Rather using chain_id + log_index + block_number and not also "transaction_hash TEXT NOT NULL"
    await %raw("sql`
      CREATE TABLE \"public\".\"Swap_history\" (
        chain_id INTEGER NOT NULL,
        block_number INTEGER NOT NULL,
        log_index INTEGER NOT NULL,
        \"origin\" text NOT NULL,
        \"sqrtPriceX96\" numeric NOT NULL,
        \"tick\" text NOT NULL,
        \"amount0\" numeric NOT NULL,
        \"transaction\" text NOT NULL,
        \"timestamp\" numeric NOT NULL,
        \"amount1\" numeric NOT NULL,
        \"token1\" text NOT NULL,
        \"logIndex\" numeric,
        \"sender\" text NOT NULL,
        \"recipient\" text NOT NULL,
        \"amountUSD\" numeric NOT NULL,
        \"token0\" text NOT NULL,
        \"id\" text NOT NULL,
        \"pool\" text NOT NULL,
        db_write_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
        PRIMARY KEY (\"id\", chain_id, block_number, log_index));`")
  }

  let deleteSwapTable: unit => promise<unit> = async () => {
    // NOTE: we can refine the `IF EXISTS` part because this now prints to the terminal if the table doesn't exist (which isn't nice for the developer).
    await %raw("sql`DROP TABLE IF EXISTS \"public\".\"Swap\";`")
  }
}

module Tick = {
  let createTickTable: unit => promise<unit> = async () => {
    await %raw("sql`
      CREATE TABLE \"public\".\"Tick\" (\"collectedFeesToken1\" numeric NOT NULL,\"createdAtTimestamp\" numeric NOT NULL,\"createdAtBlockNumber\" numeric NOT NULL,\"id\" text NOT NULL,\"liquidityNet\" numeric NOT NULL,\"volumeToken0\" numeric NOT NULL,\"volumeToken1\" numeric NOT NULL,\"collectedFeesToken0\" numeric NOT NULL,\"collectedFeesUSD\" numeric NOT NULL,\"feeGrowthOutside1X128\" numeric NOT NULL,\"price1\" numeric NOT NULL,\"liquidityProviderCount\" numeric NOT NULL,\"feeGrowthOutside0X128\" numeric NOT NULL,\"liquidityGross\" numeric NOT NULL,\"volumeUSD\" numeric NOT NULL,\"price0\" numeric NOT NULL,\"untrackedVolumeUSD\" numeric NOT NULL,\"poolAddress\" text,\"feesUSD\" numeric NOT NULL,\"pool_id\" text NOT NULL,\"tickIdx\" numeric NOT NULL, 
        db_write_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
        PRIMARY KEY (\"id\"));`")
  }

  let createTickHistoryTable: unit => promise<unit> = async () => {
    // Rather using chain_id + log_index + block_number and not also "transaction_hash TEXT NOT NULL"
    await %raw("sql`
      CREATE TABLE \"public\".\"Tick_history\" (
        chain_id INTEGER NOT NULL,
        block_number INTEGER NOT NULL,
        log_index INTEGER NOT NULL,
        \"collectedFeesToken1\" numeric NOT NULL,
        \"createdAtTimestamp\" numeric NOT NULL,
        \"createdAtBlockNumber\" numeric NOT NULL,
        \"id\" text NOT NULL,
        \"liquidityNet\" numeric NOT NULL,
        \"volumeToken0\" numeric NOT NULL,
        \"volumeToken1\" numeric NOT NULL,
        \"collectedFeesToken0\" numeric NOT NULL,
        \"collectedFeesUSD\" numeric NOT NULL,
        
        \"feeGrowthOutside1X128\" numeric NOT NULL,
        \"price1\" numeric NOT NULL,
        \"liquidityProviderCount\" numeric NOT NULL,
        \"feeGrowthOutside0X128\" numeric NOT NULL,
        \"liquidityGross\" numeric NOT NULL,
        \"volumeUSD\" numeric NOT NULL,
        \"price0\" numeric NOT NULL,
        \"untrackedVolumeUSD\" numeric NOT NULL,
        \"poolAddress\" text,
        \"feesUSD\" numeric NOT NULL,
        \"pool\" text NOT NULL,
        \"tickIdx\" numeric NOT NULL,
        db_write_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
        PRIMARY KEY (\"id\", chain_id, block_number, log_index));`")
  }

  let deleteTickTable: unit => promise<unit> = async () => {
    // NOTE: we can refine the `IF EXISTS` part because this now prints to the terminal if the table doesn't exist (which isn't nice for the developer).
    await %raw("sql`DROP TABLE IF EXISTS \"public\".\"Tick\";`")
  }
}

module TickDayData = {
  let createTickDayDataTable: unit => promise<unit> = async () => {
    await %raw("sql`
      CREATE TABLE \"public\".\"TickDayData\" (\"feesUSD\" numeric NOT NULL,\"pool_id\" text NOT NULL,\"tick_id\" text NOT NULL,\"date\" integer NOT NULL,\"liquidityNet\" numeric NOT NULL,\"feeGrowthOutside0X128\" numeric NOT NULL,\"volumeUSD\" numeric NOT NULL,\"feeGrowthOutside1X128\" numeric NOT NULL,\"volumeToken1\" numeric NOT NULL,\"id\" text NOT NULL,\"volumeToken0\" numeric NOT NULL,\"liquidityGross\" numeric NOT NULL, 
        db_write_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
        PRIMARY KEY (\"id\"));`")
  }

  let createTickDayDataHistoryTable: unit => promise<unit> = async () => {
    // Rather using chain_id + log_index + block_number and not also "transaction_hash TEXT NOT NULL"
    await %raw("sql`
      CREATE TABLE \"public\".\"TickDayData_history\" (
        chain_id INTEGER NOT NULL,
        block_number INTEGER NOT NULL,
        log_index INTEGER NOT NULL,
        \"feesUSD\" numeric NOT NULL,
        \"pool\" text NOT NULL,
        \"tick\" text NOT NULL,
        \"date\" integer NOT NULL,
        \"liquidityNet\" numeric NOT NULL,
        \"feeGrowthOutside0X128\" numeric NOT NULL,
        \"volumeUSD\" numeric NOT NULL,
        \"feeGrowthOutside1X128\" numeric NOT NULL,
        \"volumeToken1\" numeric NOT NULL,
        \"id\" text NOT NULL,
        \"volumeToken0\" numeric NOT NULL,
        \"liquidityGross\" numeric NOT NULL,
        db_write_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
        PRIMARY KEY (\"id\", chain_id, block_number, log_index));`")
  }

  let deleteTickDayDataTable: unit => promise<unit> = async () => {
    // NOTE: we can refine the `IF EXISTS` part because this now prints to the terminal if the table doesn't exist (which isn't nice for the developer).
    await %raw("sql`DROP TABLE IF EXISTS \"public\".\"TickDayData\";`")
  }
}

module TickHourData = {
  let createTickHourDataTable: unit => promise<unit> = async () => {
    await %raw("sql`
      CREATE TABLE \"public\".\"TickHourData\" (\"id\" text NOT NULL,\"tick_id\" text NOT NULL,\"liquidityGross\" numeric NOT NULL,\"volumeToken0\" numeric NOT NULL,\"liquidityNet\" numeric NOT NULL,\"volumeUSD\" numeric NOT NULL,\"pool_id\" text NOT NULL,\"feesUSD\" numeric NOT NULL,\"periodStartUnix\" integer NOT NULL,\"volumeToken1\" numeric NOT NULL, 
        db_write_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
        PRIMARY KEY (\"id\"));`")
  }

  let createTickHourDataHistoryTable: unit => promise<unit> = async () => {
    // Rather using chain_id + log_index + block_number and not also "transaction_hash TEXT NOT NULL"
    await %raw("sql`
      CREATE TABLE \"public\".\"TickHourData_history\" (
        chain_id INTEGER NOT NULL,
        block_number INTEGER NOT NULL,
        log_index INTEGER NOT NULL,
        \"id\" text NOT NULL,
        \"tick\" text NOT NULL,
        \"liquidityGross\" numeric NOT NULL,
        \"volumeToken0\" numeric NOT NULL,
        \"liquidityNet\" numeric NOT NULL,
        \"volumeUSD\" numeric NOT NULL,
        \"pool\" text NOT NULL,
        \"feesUSD\" numeric NOT NULL,
        \"periodStartUnix\" integer NOT NULL,
        \"volumeToken1\" numeric NOT NULL,
        db_write_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
        PRIMARY KEY (\"id\", chain_id, block_number, log_index));`")
  }

  let deleteTickHourDataTable: unit => promise<unit> = async () => {
    // NOTE: we can refine the `IF EXISTS` part because this now prints to the terminal if the table doesn't exist (which isn't nice for the developer).
    await %raw("sql`DROP TABLE IF EXISTS \"public\".\"TickHourData\";`")
  }
}

module Token = {
  let createTokenTable: unit => promise<unit> = async () => {
    await %raw("sql`
      CREATE TABLE \"public\".\"Token\" (\"txCount\" numeric NOT NULL,\"untrackedVolumeUSD\" numeric NOT NULL,\"derivedETH\" numeric NOT NULL,\"name\" text NOT NULL,\"symbol\" text NOT NULL,\"feesUSD\" numeric NOT NULL,\"totalValueLocked\" numeric NOT NULL,\"id\" text NOT NULL,\"volumeUSD\" numeric NOT NULL,\"totalSupply\" numeric NOT NULL,\"poolCount\" numeric NOT NULL,\"decimals\" numeric NOT NULL,\"volume\" numeric NOT NULL,\"totalValueLockedUSDUntracked\" numeric NOT NULL,\"totalValueLockedUSD\" numeric NOT NULL, 
        db_write_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
        PRIMARY KEY (\"id\"));`")
  }

  let createTokenHistoryTable: unit => promise<unit> = async () => {
    // Rather using chain_id + log_index + block_number and not also "transaction_hash TEXT NOT NULL"
    await %raw("sql`
      CREATE TABLE \"public\".\"Token_history\" (
        chain_id INTEGER NOT NULL,
        block_number INTEGER NOT NULL,
        log_index INTEGER NOT NULL,
        \"txCount\" numeric NOT NULL,
        \"untrackedVolumeUSD\" numeric NOT NULL,
        
        \"derivedETH\" numeric NOT NULL,
        \"name\" text NOT NULL,
        \"symbol\" text NOT NULL,
        \"feesUSD\" numeric NOT NULL,
        \"totalValueLocked\" numeric NOT NULL,
        \"id\" text NOT NULL,
        \"volumeUSD\" numeric NOT NULL,
        \"totalSupply\" numeric NOT NULL,
        \"poolCount\" numeric NOT NULL,
        \"decimals\" numeric NOT NULL,
        \"volume\" numeric NOT NULL,
        \"totalValueLockedUSDUntracked\" numeric NOT NULL,
        \"totalValueLockedUSD\" numeric NOT NULL,
        
        db_write_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
        PRIMARY KEY (\"id\", chain_id, block_number, log_index));`")
  }

  let deleteTokenTable: unit => promise<unit> = async () => {
    // NOTE: we can refine the `IF EXISTS` part because this now prints to the terminal if the table doesn't exist (which isn't nice for the developer).
    await %raw("sql`DROP TABLE IF EXISTS \"public\".\"Token\";`")
  }
}

module TokenDayData = {
  let createTokenDayDataTable: unit => promise<unit> = async () => {
    await %raw("sql`
      CREATE TABLE \"public\".\"TokenDayData\" (\"high\" numeric NOT NULL,\"totalValueLocked\" numeric NOT NULL,\"low\" numeric NOT NULL,\"feesUSD\" numeric NOT NULL,\"close\" numeric NOT NULL,\"volumeUSD\" numeric NOT NULL,\"volume\" numeric NOT NULL,\"untrackedVolumeUSD\" numeric NOT NULL,\"totalValueLockedUSD\" numeric NOT NULL,\"priceUSD\" numeric NOT NULL,\"date\" integer NOT NULL,\"token_id\" text NOT NULL,\"openPrice\" numeric NOT NULL,\"id\" text NOT NULL, 
        db_write_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
        PRIMARY KEY (\"id\"));`")
  }

  let createTokenDayDataHistoryTable: unit => promise<unit> = async () => {
    // Rather using chain_id + log_index + block_number and not also "transaction_hash TEXT NOT NULL"
    await %raw("sql`
      CREATE TABLE \"public\".\"TokenDayData_history\" (
        chain_id INTEGER NOT NULL,
        block_number INTEGER NOT NULL,
        log_index INTEGER NOT NULL,
        \"high\" numeric NOT NULL,
        \"totalValueLocked\" numeric NOT NULL,
        \"low\" numeric NOT NULL,
        \"feesUSD\" numeric NOT NULL,
        \"close\" numeric NOT NULL,
        \"volumeUSD\" numeric NOT NULL,
        \"volume\" numeric NOT NULL,
        \"untrackedVolumeUSD\" numeric NOT NULL,
        \"totalValueLockedUSD\" numeric NOT NULL,
        \"priceUSD\" numeric NOT NULL,
        \"date\" integer NOT NULL,
        \"token\" text NOT NULL,
        \"openPrice\" numeric NOT NULL,
        \"id\" text NOT NULL,
        db_write_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
        PRIMARY KEY (\"id\", chain_id, block_number, log_index));`")
  }

  let deleteTokenDayDataTable: unit => promise<unit> = async () => {
    // NOTE: we can refine the `IF EXISTS` part because this now prints to the terminal if the table doesn't exist (which isn't nice for the developer).
    await %raw("sql`DROP TABLE IF EXISTS \"public\".\"TokenDayData\";`")
  }
}

module TokenHourData = {
  let createTokenHourDataTable: unit => promise<unit> = async () => {
    await %raw("sql`
      CREATE TABLE \"public\".\"TokenHourData\" (\"untrackedVolumeUSD\" numeric NOT NULL,\"token_id\" text NOT NULL,\"priceUSD\" numeric NOT NULL,\"openPrice\" numeric NOT NULL,\"totalValueLockedUSD\" numeric NOT NULL,\"volume\" numeric NOT NULL,\"id\" text NOT NULL,\"feesUSD\" numeric NOT NULL,\"close\" numeric NOT NULL,\"low\" numeric NOT NULL,\"high\" numeric NOT NULL,\"periodStartUnix\" integer NOT NULL,\"totalValueLocked\" numeric NOT NULL,\"volumeUSD\" numeric NOT NULL, 
        db_write_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
        PRIMARY KEY (\"id\"));`")
  }

  let createTokenHourDataHistoryTable: unit => promise<unit> = async () => {
    // Rather using chain_id + log_index + block_number and not also "transaction_hash TEXT NOT NULL"
    await %raw("sql`
      CREATE TABLE \"public\".\"TokenHourData_history\" (
        chain_id INTEGER NOT NULL,
        block_number INTEGER NOT NULL,
        log_index INTEGER NOT NULL,
        \"untrackedVolumeUSD\" numeric NOT NULL,
        \"token\" text NOT NULL,
        \"priceUSD\" numeric NOT NULL,
        \"openPrice\" numeric NOT NULL,
        \"totalValueLockedUSD\" numeric NOT NULL,
        \"volume\" numeric NOT NULL,
        \"id\" text NOT NULL,
        \"feesUSD\" numeric NOT NULL,
        \"close\" numeric NOT NULL,
        \"low\" numeric NOT NULL,
        \"high\" numeric NOT NULL,
        \"periodStartUnix\" integer NOT NULL,
        \"totalValueLocked\" numeric NOT NULL,
        \"volumeUSD\" numeric NOT NULL,
        db_write_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
        PRIMARY KEY (\"id\", chain_id, block_number, log_index));`")
  }

  let deleteTokenHourDataTable: unit => promise<unit> = async () => {
    // NOTE: we can refine the `IF EXISTS` part because this now prints to the terminal if the table doesn't exist (which isn't nice for the developer).
    await %raw("sql`DROP TABLE IF EXISTS \"public\".\"TokenHourData\";`")
  }
}

module TokenPoolWhitelist = {
  let createTokenPoolWhitelistTable: unit => promise<unit> = async () => {
    await %raw("sql`
      CREATE TABLE \"public\".\"TokenPoolWhitelist\" (\"token_id\" text NOT NULL,\"pool_id\" text NOT NULL,\"id\" text NOT NULL, 
        db_write_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
        PRIMARY KEY (\"id\"));`")
  }

  let createTokenPoolWhitelistHistoryTable: unit => promise<unit> = async () => {
    // Rather using chain_id + log_index + block_number and not also "transaction_hash TEXT NOT NULL"
    await %raw("sql`
      CREATE TABLE \"public\".\"TokenPoolWhitelist_history\" (
        chain_id INTEGER NOT NULL,
        block_number INTEGER NOT NULL,
        log_index INTEGER NOT NULL,
        \"token\" text NOT NULL,
        \"pool\" text NOT NULL,
        \"id\" text NOT NULL,
        db_write_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
        PRIMARY KEY (\"id\", chain_id, block_number, log_index));`")
  }

  let deleteTokenPoolWhitelistTable: unit => promise<unit> = async () => {
    // NOTE: we can refine the `IF EXISTS` part because this now prints to the terminal if the table doesn't exist (which isn't nice for the developer).
    await %raw("sql`DROP TABLE IF EXISTS \"public\".\"TokenPoolWhitelist\";`")
  }
}

module Transaction = {
  let createTransactionTable: unit => promise<unit> = async () => {
    await %raw("sql`
      CREATE TABLE \"public\".\"Transaction\" (\"blockNumber\" numeric NOT NULL,\"id\" text NOT NULL,\"timestamp\" numeric NOT NULL,\"gasPrice\" numeric NOT NULL,\"gasUsed\" numeric NOT NULL, 
        db_write_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
        PRIMARY KEY (\"id\"));`")
  }

  let createTransactionHistoryTable: unit => promise<unit> = async () => {
    // Rather using chain_id + log_index + block_number and not also "transaction_hash TEXT NOT NULL"
    await %raw("sql`
      CREATE TABLE \"public\".\"Transaction_history\" (
        chain_id INTEGER NOT NULL,
        block_number INTEGER NOT NULL,
        log_index INTEGER NOT NULL,
        \"blockNumber\" numeric NOT NULL,
        \"id\" text NOT NULL,
        \"timestamp\" numeric NOT NULL,
        \"gasPrice\" numeric NOT NULL,
        \"gasUsed\" numeric NOT NULL,
        db_write_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
        PRIMARY KEY (\"id\", chain_id, block_number, log_index));`")
  }

  let deleteTransactionTable: unit => promise<unit> = async () => {
    // NOTE: we can refine the `IF EXISTS` part because this now prints to the terminal if the table doesn't exist (which isn't nice for the developer).
    await %raw("sql`DROP TABLE IF EXISTS \"public\".\"Transaction\";`")
  }
}

module UniswapDayData = {
  let createUniswapDayDataTable: unit => promise<unit> = async () => {
    await %raw("sql`
      CREATE TABLE \"public\".\"UniswapDayData\" (\"volumeUSD\" numeric NOT NULL,\"feesUSD\" numeric NOT NULL,\"id\" text NOT NULL,\"tvlUSD\" numeric NOT NULL,\"txCount\" numeric NOT NULL,\"volumeETH\" numeric NOT NULL,\"volumeUSDUntracked\" numeric NOT NULL,\"date\" integer NOT NULL, 
        db_write_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
        PRIMARY KEY (\"id\"));`")
  }

  let createUniswapDayDataHistoryTable: unit => promise<unit> = async () => {
    // Rather using chain_id + log_index + block_number and not also "transaction_hash TEXT NOT NULL"
    await %raw("sql`
      CREATE TABLE \"public\".\"UniswapDayData_history\" (
        chain_id INTEGER NOT NULL,
        block_number INTEGER NOT NULL,
        log_index INTEGER NOT NULL,
        \"volumeUSD\" numeric NOT NULL,
        \"feesUSD\" numeric NOT NULL,
        \"id\" text NOT NULL,
        \"tvlUSD\" numeric NOT NULL,
        \"txCount\" numeric NOT NULL,
        \"volumeETH\" numeric NOT NULL,
        \"volumeUSDUntracked\" numeric NOT NULL,
        \"date\" integer NOT NULL,
        db_write_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP, 
        PRIMARY KEY (\"id\", chain_id, block_number, log_index));`")
  }

  let deleteUniswapDayDataTable: unit => promise<unit> = async () => {
    // NOTE: we can refine the `IF EXISTS` part because this now prints to the terminal if the table doesn't exist (which isn't nice for the developer).
    await %raw("sql`DROP TABLE IF EXISTS \"public\".\"UniswapDayData\";`")
  }
}

let deleteAllTables: unit => promise<unit> = async () => {
  Logging.trace("Dropping all tables")
  // NOTE: we can refine the `IF EXISTS` part because this now prints to the terminal if the table doesn't exist (which isn't nice for the developer).

  @warning("-21")
  await (
    %raw(
      "sql.unsafe`DROP SCHEMA public CASCADE;CREATE SCHEMA public;GRANT ALL ON SCHEMA public TO postgres;GRANT ALL ON SCHEMA public TO public;`"
    )
  )
}

let deleteAllTablesExceptRawEventsAndDynamicContractRegistry: unit => promise<unit> = async () => {
  // NOTE: we can refine the `IF EXISTS` part because this now prints to the terminal if the table doesn't exist (which isn't nice for the developer).

  @warning("-21")
  await (
    %raw("sql.unsafe`
    DO $$ 
    DECLARE
        table_name_var text;
    BEGIN
        FOR table_name_var IN (SELECT table_name
                           FROM information_schema.tables
                           WHERE table_schema = 'public'
                           AND table_name != 'raw_events'
                           AND table_name != 'dynamic_contract_registry') 
        LOOP
            EXECUTE 'DROP TABLE IF EXISTS ' || table_name_var || ' CASCADE';
        END LOOP;
    END $$;
  `")
  )
}

type t
@module external process: t = "process"

type exitCode = Success | Failure
@send external exit: (t, exitCode) => unit = "exit"

// TODO: all the migration steps should run as a single transaction
let runUpMigrations = async (~shouldExit) => {
  let exitCode = ref(Success)
  await PersistedState.createPersistedStateTable()->Promise.catch(err => {
    exitCode := Failure
    Logging.errorWithExn(err, `EE800: Error creating persisted_state table`)->Promise.resolve
  })

  await EventSyncState.createEventSyncStateTable()->Promise.catch(err => {
    exitCode := Failure
    Logging.errorWithExn(err, `EE800: Error creating event_sync_state table`)->Promise.resolve
  })
  await ChainMetadata.createChainMetadataTable()->Promise.catch(err => {
    exitCode := Failure
    Logging.errorWithExn(err, `EE800: Error creating chain_metadata table`)->Promise.resolve
  })
  await SyncBatchMetadata.createSyncBatchTable()->Promise.catch(err => {
    exitCode := Failure
    Logging.errorWithExn(err, `EE800: Error creating sync_batch table`)->Promise.resolve
  })
  await RawEventsTable.createRawEventsTable()->Promise.catch(err => {
    exitCode := Failure
    Logging.errorWithExn(err, `EE800: Error creating raw_events table`)->Promise.resolve
  })
  await DynamicContractRegistryTable.createDynamicContractRegistryTable()->Promise.catch(err => {
    exitCode := Failure
    Logging.errorWithExn(err, `EE801: Error creating dynamic_contracts table`)->Promise.resolve
  })

  // TODO: catch and handle query errors
  await Bundle.createBundleTable()->Promise.catch(err => {
    exitCode := Failure
    Logging.errorWithExn(err, `EE802: Error creating Bundle table`)->Promise.resolve
  })
  await Bundle.createBundleHistoryTable()->Promise.catch(err => {
    exitCode := Failure
    Logging.errorWithExn(err, `EE802: Error creating Bundle entity history table`)->Promise.resolve
  })
  await Burn.createBurnTable()->Promise.catch(err => {
    exitCode := Failure
    Logging.errorWithExn(err, `EE802: Error creating Burn table`)->Promise.resolve
  })
  await Burn.createBurnHistoryTable()->Promise.catch(err => {
    exitCode := Failure
    Logging.errorWithExn(err, `EE802: Error creating Burn entity history table`)->Promise.resolve
  })
  await Collect.createCollectTable()->Promise.catch(err => {
    exitCode := Failure
    Logging.errorWithExn(err, `EE802: Error creating Collect table`)->Promise.resolve
  })
  await Collect.createCollectHistoryTable()->Promise.catch(err => {
    exitCode := Failure
    Logging.errorWithExn(err, `EE802: Error creating Collect entity history table`)->Promise.resolve
  })
  await Factory.createFactoryTable()->Promise.catch(err => {
    exitCode := Failure
    Logging.errorWithExn(err, `EE802: Error creating Factory table`)->Promise.resolve
  })
  await Factory.createFactoryHistoryTable()->Promise.catch(err => {
    exitCode := Failure
    Logging.errorWithExn(err, `EE802: Error creating Factory entity history table`)->Promise.resolve
  })
  await Flash.createFlashTable()->Promise.catch(err => {
    exitCode := Failure
    Logging.errorWithExn(err, `EE802: Error creating Flash table`)->Promise.resolve
  })
  await Flash.createFlashHistoryTable()->Promise.catch(err => {
    exitCode := Failure
    Logging.errorWithExn(err, `EE802: Error creating Flash entity history table`)->Promise.resolve
  })
  await Mint.createMintTable()->Promise.catch(err => {
    exitCode := Failure
    Logging.errorWithExn(err, `EE802: Error creating Mint table`)->Promise.resolve
  })
  await Mint.createMintHistoryTable()->Promise.catch(err => {
    exitCode := Failure
    Logging.errorWithExn(err, `EE802: Error creating Mint entity history table`)->Promise.resolve
  })
  await Pool.createPoolTable()->Promise.catch(err => {
    exitCode := Failure
    Logging.errorWithExn(err, `EE802: Error creating Pool table`)->Promise.resolve
  })
  await Pool.createPoolHistoryTable()->Promise.catch(err => {
    exitCode := Failure
    Logging.errorWithExn(err, `EE802: Error creating Pool entity history table`)->Promise.resolve
  })
  await PoolDayData.createPoolDayDataTable()->Promise.catch(err => {
    exitCode := Failure
    Logging.errorWithExn(err, `EE802: Error creating PoolDayData table`)->Promise.resolve
  })
  await PoolDayData.createPoolDayDataHistoryTable()->Promise.catch(err => {
    exitCode := Failure
    Logging.errorWithExn(
      err,
      `EE802: Error creating PoolDayData entity history table`,
    )->Promise.resolve
  })
  await PoolHourData.createPoolHourDataTable()->Promise.catch(err => {
    exitCode := Failure
    Logging.errorWithExn(err, `EE802: Error creating PoolHourData table`)->Promise.resolve
  })
  await PoolHourData.createPoolHourDataHistoryTable()->Promise.catch(err => {
    exitCode := Failure
    Logging.errorWithExn(
      err,
      `EE802: Error creating PoolHourData entity history table`,
    )->Promise.resolve
  })
  await Position.createPositionTable()->Promise.catch(err => {
    exitCode := Failure
    Logging.errorWithExn(err, `EE802: Error creating Position table`)->Promise.resolve
  })
  await Position.createPositionHistoryTable()->Promise.catch(err => {
    exitCode := Failure
    Logging.errorWithExn(
      err,
      `EE802: Error creating Position entity history table`,
    )->Promise.resolve
  })
  await PositionSnapshot.createPositionSnapshotTable()->Promise.catch(err => {
    exitCode := Failure
    Logging.errorWithExn(err, `EE802: Error creating PositionSnapshot table`)->Promise.resolve
  })
  await PositionSnapshot.createPositionSnapshotHistoryTable()->Promise.catch(err => {
    exitCode := Failure
    Logging.errorWithExn(
      err,
      `EE802: Error creating PositionSnapshot entity history table`,
    )->Promise.resolve
  })
  await Swap.createSwapTable()->Promise.catch(err => {
    exitCode := Failure
    Logging.errorWithExn(err, `EE802: Error creating Swap table`)->Promise.resolve
  })
  await Swap.createSwapHistoryTable()->Promise.catch(err => {
    exitCode := Failure
    Logging.errorWithExn(err, `EE802: Error creating Swap entity history table`)->Promise.resolve
  })
  await Tick.createTickTable()->Promise.catch(err => {
    exitCode := Failure
    Logging.errorWithExn(err, `EE802: Error creating Tick table`)->Promise.resolve
  })
  await Tick.createTickHistoryTable()->Promise.catch(err => {
    exitCode := Failure
    Logging.errorWithExn(err, `EE802: Error creating Tick entity history table`)->Promise.resolve
  })
  await TickDayData.createTickDayDataTable()->Promise.catch(err => {
    exitCode := Failure
    Logging.errorWithExn(err, `EE802: Error creating TickDayData table`)->Promise.resolve
  })
  await TickDayData.createTickDayDataHistoryTable()->Promise.catch(err => {
    exitCode := Failure
    Logging.errorWithExn(
      err,
      `EE802: Error creating TickDayData entity history table`,
    )->Promise.resolve
  })
  await TickHourData.createTickHourDataTable()->Promise.catch(err => {
    exitCode := Failure
    Logging.errorWithExn(err, `EE802: Error creating TickHourData table`)->Promise.resolve
  })
  await TickHourData.createTickHourDataHistoryTable()->Promise.catch(err => {
    exitCode := Failure
    Logging.errorWithExn(
      err,
      `EE802: Error creating TickHourData entity history table`,
    )->Promise.resolve
  })
  await Token.createTokenTable()->Promise.catch(err => {
    exitCode := Failure
    Logging.errorWithExn(err, `EE802: Error creating Token table`)->Promise.resolve
  })
  await Token.createTokenHistoryTable()->Promise.catch(err => {
    exitCode := Failure
    Logging.errorWithExn(err, `EE802: Error creating Token entity history table`)->Promise.resolve
  })
  await TokenDayData.createTokenDayDataTable()->Promise.catch(err => {
    exitCode := Failure
    Logging.errorWithExn(err, `EE802: Error creating TokenDayData table`)->Promise.resolve
  })
  await TokenDayData.createTokenDayDataHistoryTable()->Promise.catch(err => {
    exitCode := Failure
    Logging.errorWithExn(
      err,
      `EE802: Error creating TokenDayData entity history table`,
    )->Promise.resolve
  })
  await TokenHourData.createTokenHourDataTable()->Promise.catch(err => {
    exitCode := Failure
    Logging.errorWithExn(err, `EE802: Error creating TokenHourData table`)->Promise.resolve
  })
  await TokenHourData.createTokenHourDataHistoryTable()->Promise.catch(err => {
    exitCode := Failure
    Logging.errorWithExn(
      err,
      `EE802: Error creating TokenHourData entity history table`,
    )->Promise.resolve
  })
  await TokenPoolWhitelist.createTokenPoolWhitelistTable()->Promise.catch(err => {
    exitCode := Failure
    Logging.errorWithExn(err, `EE802: Error creating TokenPoolWhitelist table`)->Promise.resolve
  })
  await TokenPoolWhitelist.createTokenPoolWhitelistHistoryTable()->Promise.catch(err => {
    exitCode := Failure
    Logging.errorWithExn(
      err,
      `EE802: Error creating TokenPoolWhitelist entity history table`,
    )->Promise.resolve
  })
  await Transaction.createTransactionTable()->Promise.catch(err => {
    exitCode := Failure
    Logging.errorWithExn(err, `EE802: Error creating Transaction table`)->Promise.resolve
  })
  await Transaction.createTransactionHistoryTable()->Promise.catch(err => {
    exitCode := Failure
    Logging.errorWithExn(
      err,
      `EE802: Error creating Transaction entity history table`,
    )->Promise.resolve
  })
  await UniswapDayData.createUniswapDayDataTable()->Promise.catch(err => {
    exitCode := Failure
    Logging.errorWithExn(err, `EE802: Error creating UniswapDayData table`)->Promise.resolve
  })
  await UniswapDayData.createUniswapDayDataHistoryTable()->Promise.catch(err => {
    exitCode := Failure
    Logging.errorWithExn(
      err,
      `EE802: Error creating UniswapDayData entity history table`,
    )->Promise.resolve
  })
  await TrackTables.trackAllTables()->Promise.catch(err => {
    Logging.errorWithExn(err, `EE803: Error tracking tables`)->Promise.resolve
  })
  if shouldExit {
    process->exit(exitCode.contents)
  }
  exitCode.contents
}

let runDownMigrations = async (~shouldExit, ~shouldDropRawEvents) => {
  let exitCode = ref(Success)

  //
  // await Bundle.deleteBundleTable()
  //
  // await Burn.deleteBurnTable()
  //
  // await Collect.deleteCollectTable()
  //
  // await Factory.deleteFactoryTable()
  //
  // await Flash.deleteFlashTable()
  //
  // await Mint.deleteMintTable()
  //
  // await Pool.deletePoolTable()
  //
  // await PoolDayData.deletePoolDayDataTable()
  //
  // await PoolHourData.deletePoolHourDataTable()
  //
  // await Position.deletePositionTable()
  //
  // await PositionSnapshot.deletePositionSnapshotTable()
  //
  // await Swap.deleteSwapTable()
  //
  // await Tick.deleteTickTable()
  //
  // await TickDayData.deleteTickDayDataTable()
  //
  // await TickHourData.deleteTickHourDataTable()
  //
  // await Token.deleteTokenTable()
  //
  // await TokenDayData.deleteTokenDayDataTable()
  //
  // await TokenHourData.deleteTokenHourDataTable()
  //
  // await TokenPoolWhitelist.deleteTokenPoolWhitelistTable()
  //
  // await Transaction.deleteTransactionTable()
  //
  // await UniswapDayData.deleteUniswapDayDataTable()
  //

  // NOTE: For now delete any remaining tables.
  if shouldDropRawEvents {
    await deleteAllTables()->Promise.catch(err => {
      exitCode := Failure
      Logging.errorWithExn(err, "EE804: Error dropping entity tables")->Promise.resolve
    })
  } else {
    await deleteAllTablesExceptRawEventsAndDynamicContractRegistry()->Promise.catch(err => {
      exitCode := Failure
      Logging.errorWithExn(
        err,
        "EE805: Error dropping entity tables except for raw events",
      )->Promise.resolve
    })
  }
  if shouldExit {
    process->exit(exitCode.contents)
  }
  exitCode.contents
}

let setupDb = async (~shouldDropRawEvents) => {
  Logging.info("Provisioning Database")
  // TODO: we should make a hash of the schema file (that gets stored in the DB) and either drop the tables and create new ones or keep this migration.
  //       for now we always run the down migration.
  // if (process.env.MIGRATE === "force" || hash_of_schema_file !== hash_of_current_schema)
  let exitCodeDown = await runDownMigrations(~shouldExit=false, ~shouldDropRawEvents)
  // else
  //   await clearDb()

  let exitCodeUp = await runUpMigrations(~shouldExit=false)

  let exitCode = switch (exitCodeDown, exitCodeUp) {
  | (Success, Success) => Success
  | _ => Failure
  }

  process->exit(exitCode)
}
