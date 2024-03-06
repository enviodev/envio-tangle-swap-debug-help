/* TypeScript file generated from Types.res by genType. */
/* eslint-disable import/first */


import type {BigInt_t as Ethers_BigInt_t} from '../src/bindings/Ethers.gen';

import type {Json_t as Js_Json_t} from '../src/Js.shim';

import type {ethAddress as Ethers_ethAddress} from '../src/bindings/Ethers.gen';

import type {userLogger as Logs_userLogger} from './Logs.gen';

// tslint:disable-next-line:interface-over-type-literal
export type id = string;
export type Id = id;

// tslint:disable-next-line:interface-over-type-literal
export type bundleLoaderConfig = boolean;

// tslint:disable-next-line:interface-over-type-literal
export type burnLoaderConfig = {
  readonly loadTransaction?: transactionLoaderConfig; 
  readonly loadToken0?: tokenLoaderConfig; 
  readonly loadPool?: poolLoaderConfig; 
  readonly loadToken1?: tokenLoaderConfig
};

// tslint:disable-next-line:interface-over-type-literal
export type collectLoaderConfig = { readonly loadTransaction?: transactionLoaderConfig; readonly loadPool?: poolLoaderConfig };

// tslint:disable-next-line:interface-over-type-literal
export type flashLoaderConfig = { readonly loadPool?: poolLoaderConfig; readonly loadTransaction?: transactionLoaderConfig };

// tslint:disable-next-line:interface-over-type-literal
export type mintLoaderConfig = {
  readonly loadToken0?: tokenLoaderConfig; 
  readonly loadTransaction?: transactionLoaderConfig; 
  readonly loadPool?: poolLoaderConfig; 
  readonly loadToken1?: tokenLoaderConfig
};

// tslint:disable-next-line:interface-over-type-literal
export type poolLoaderConfig = { readonly loadToken1?: tokenLoaderConfig; readonly loadToken0?: tokenLoaderConfig };

// tslint:disable-next-line:interface-over-type-literal
export type poolDayDataLoaderConfig = { readonly loadPool?: poolLoaderConfig };

// tslint:disable-next-line:interface-over-type-literal
export type poolHourDataLoaderConfig = { readonly loadPool?: poolLoaderConfig };

// tslint:disable-next-line:interface-over-type-literal
export type positionLoaderConfig = {
  readonly loadToken1?: tokenLoaderConfig; 
  readonly loadToken0?: tokenLoaderConfig; 
  readonly loadTickLower?: tickLoaderConfig; 
  readonly loadTransaction?: transactionLoaderConfig; 
  readonly loadPool?: poolLoaderConfig; 
  readonly loadTickUpper?: tickLoaderConfig
};

// tslint:disable-next-line:interface-over-type-literal
export type positionSnapshotLoaderConfig = {
  readonly loadPool?: poolLoaderConfig; 
  readonly loadPosition?: positionLoaderConfig; 
  readonly loadTransaction?: transactionLoaderConfig
};

// tslint:disable-next-line:interface-over-type-literal
export type swapLoaderConfig = {
  readonly loadTick?: tickLoaderConfig; 
  readonly loadTransaction?: transactionLoaderConfig; 
  readonly loadToken1?: tokenLoaderConfig; 
  readonly loadToken0?: tokenLoaderConfig; 
  readonly loadPool?: poolLoaderConfig
};

// tslint:disable-next-line:interface-over-type-literal
export type tickLoaderConfig = { readonly loadPool?: poolLoaderConfig };

// tslint:disable-next-line:interface-over-type-literal
export type tickDayDataLoaderConfig = { readonly loadPool?: poolLoaderConfig; readonly loadTick?: tickLoaderConfig };

// tslint:disable-next-line:interface-over-type-literal
export type tickHourDataLoaderConfig = { readonly loadTick?: tickLoaderConfig; readonly loadPool?: poolLoaderConfig };

// tslint:disable-next-line:interface-over-type-literal
export type tokenLoaderConfig = boolean;

// tslint:disable-next-line:interface-over-type-literal
export type tokenDayDataLoaderConfig = { readonly loadToken?: tokenLoaderConfig };

// tslint:disable-next-line:interface-over-type-literal
export type tokenHourDataLoaderConfig = { readonly loadToken?: tokenLoaderConfig };

// tslint:disable-next-line:interface-over-type-literal
export type tokenPoolWhitelistLoaderConfig = { readonly loadToken?: tokenLoaderConfig; readonly loadPool?: poolLoaderConfig };

// tslint:disable-next-line:interface-over-type-literal
export type transactionLoaderConfig = boolean;

// tslint:disable-next-line:interface-over-type-literal
export type entityRead = 
    { tag: "BundleRead"; value: id }
  | { tag: "BurnRead"; value: [id, burnLoaderConfig] }
  | { tag: "CollectRead"; value: [id, collectLoaderConfig] }
  | { tag: "FactoryRead"; value: id }
  | { tag: "FlashRead"; value: [id, flashLoaderConfig] }
  | { tag: "MintRead"; value: [id, mintLoaderConfig] }
  | { tag: "PoolRead"; value: [id, poolLoaderConfig] }
  | { tag: "PoolDayDataRead"; value: [id, poolDayDataLoaderConfig] }
  | { tag: "PoolHourDataRead"; value: [id, poolHourDataLoaderConfig] }
  | { tag: "PositionRead"; value: [id, positionLoaderConfig] }
  | { tag: "PositionSnapshotRead"; value: [id, positionSnapshotLoaderConfig] }
  | { tag: "SwapRead"; value: [id, swapLoaderConfig] }
  | { tag: "TickRead"; value: [id, tickLoaderConfig] }
  | { tag: "TickDayDataRead"; value: [id, tickDayDataLoaderConfig] }
  | { tag: "TickHourDataRead"; value: [id, tickHourDataLoaderConfig] }
  | { tag: "TokenRead"; value: id }
  | { tag: "TokenDayDataRead"; value: [id, tokenDayDataLoaderConfig] }
  | { tag: "TokenHourDataRead"; value: [id, tokenHourDataLoaderConfig] }
  | { tag: "TokenPoolWhitelistRead"; value: [id, tokenPoolWhitelistLoaderConfig] }
  | { tag: "TransactionRead"; value: id }
  | { tag: "UniswapDayDataRead"; value: id };

// tslint:disable-next-line:interface-over-type-literal
export type rawEventsEntity = {
  readonly chain_id: number; 
  readonly event_id: string; 
  readonly block_number: number; 
  readonly log_index: number; 
  readonly transaction_index: number; 
  readonly transaction_hash: string; 
  readonly src_address: Ethers_ethAddress; 
  readonly block_hash: string; 
  readonly block_timestamp: number; 
  readonly event_type: Js_Json_t; 
  readonly params: string
};

// tslint:disable-next-line:interface-over-type-literal
export type dynamicContractRegistryEntity = {
  readonly chain_id: number; 
  readonly event_id: Ethers_BigInt_t; 
  readonly contract_address: Ethers_ethAddress; 
  readonly contract_type: string
};

// tslint:disable-next-line:interface-over-type-literal
export type bundleEntity = { readonly id: id; readonly ethPriceUSD: number };
export type BundleEntity = bundleEntity;

// tslint:disable-next-line:interface-over-type-literal
export type burnEntity = {
  readonly timestamp: Ethers_BigInt_t; 
  readonly transaction_id: id; 
  readonly token0_id: id; 
  readonly tickLower: Ethers_BigInt_t; 
  readonly pool_id: id; 
  readonly amountUSD: (undefined | number); 
  readonly amount0: number; 
  readonly tickUpper: Ethers_BigInt_t; 
  readonly amount1: number; 
  readonly id: id; 
  readonly owner: (undefined | string); 
  readonly amount: Ethers_BigInt_t; 
  readonly token1_id: id; 
  readonly origin: string; 
  readonly logIndex: (undefined | Ethers_BigInt_t)
};
export type BurnEntity = burnEntity;

// tslint:disable-next-line:interface-over-type-literal
export type collectEntity = {
  readonly amountUSD: (undefined | number); 
  readonly owner: (undefined | string); 
  readonly id: id; 
  readonly amount0: number; 
  readonly transaction_id: id; 
  readonly timestamp: Ethers_BigInt_t; 
  readonly pool_id: id; 
  readonly amount1: number; 
  readonly tickLower: Ethers_BigInt_t; 
  readonly tickUpper: Ethers_BigInt_t; 
  readonly logIndex: (undefined | Ethers_BigInt_t)
};
export type CollectEntity = collectEntity;

// tslint:disable-next-line:interface-over-type-literal
export type factoryEntity = {
  readonly totalValueLockedUSD: number; 
  readonly id: id; 
  readonly totalFeesETH: number; 
  readonly totalValueLockedETHUntracked: number; 
  readonly totalValueLockedUSDUntracked: number; 
  readonly totalValueLockedETH: number; 
  readonly owner: id; 
  readonly totalVolumeUSD: number; 
  readonly txCount: Ethers_BigInt_t; 
  readonly totalFeesUSD: number; 
  readonly poolCount: Ethers_BigInt_t; 
  readonly untrackedVolumeUSD: number; 
  readonly totalVolumeETH: number
};
export type FactoryEntity = factoryEntity;

// tslint:disable-next-line:interface-over-type-literal
export type flashEntity = {
  readonly timestamp: Ethers_BigInt_t; 
  readonly sender: string; 
  readonly id: id; 
  readonly pool_id: id; 
  readonly amount1: number; 
  readonly amountUSD: number; 
  readonly amount0: number; 
  readonly amount0Paid: number; 
  readonly amount1Paid: number; 
  readonly logIndex: (undefined | Ethers_BigInt_t); 
  readonly transaction_id: id; 
  readonly recipient: string
};
export type FlashEntity = flashEntity;

// tslint:disable-next-line:interface-over-type-literal
export type mintEntity = {
  readonly sender: (undefined | string); 
  readonly origin: string; 
  readonly amount: Ethers_BigInt_t; 
  readonly amount0: number; 
  readonly tickUpper: Ethers_BigInt_t; 
  readonly logIndex: (undefined | Ethers_BigInt_t); 
  readonly token0_id: id; 
  readonly amountUSD: (undefined | number); 
  readonly transaction_id: id; 
  readonly pool_id: id; 
  readonly amount1: number; 
  readonly tickLower: Ethers_BigInt_t; 
  readonly id: id; 
  readonly timestamp: Ethers_BigInt_t; 
  readonly token1_id: id; 
  readonly owner: string
};
export type MintEntity = mintEntity;

// tslint:disable-next-line:interface-over-type-literal
export type poolEntity = {
  readonly token1_id: id; 
  readonly volumeToken1: number; 
  readonly id: id; 
  readonly token0_id: id; 
  readonly txCount: Ethers_BigInt_t; 
  readonly tick: (undefined | Ethers_BigInt_t); 
  readonly liquidity: Ethers_BigInt_t; 
  readonly observationIndex: Ethers_BigInt_t; 
  readonly feeTier: Ethers_BigInt_t; 
  readonly untrackedVolumeUSD: number; 
  readonly collectedFeesUSD: number; 
  readonly volumeToken0: number; 
  readonly totalValueLockedUSD: number; 
  readonly token1Price: number; 
  readonly feeGrowthGlobal0X128: Ethers_BigInt_t; 
  readonly totalValueLockedToken1: number; 
  readonly liquidityProviderCount: Ethers_BigInt_t; 
  readonly collectedFeesToken1: number; 
  readonly volumeUSD: number; 
  readonly createdAtTimestamp: Ethers_BigInt_t; 
  readonly feeGrowthGlobal1X128: Ethers_BigInt_t; 
  readonly sqrtPrice: Ethers_BigInt_t; 
  readonly totalValueLockedToken0: number; 
  readonly totalValueLockedETH: number; 
  readonly totalValueLockedUSDUntracked: number; 
  readonly feesUSD: number; 
  readonly collectedFeesToken0: number; 
  readonly token0Price: number; 
  readonly createdAtBlockNumber: Ethers_BigInt_t
};
export type PoolEntity = poolEntity;

// tslint:disable-next-line:interface-over-type-literal
export type poolDayDataEntity = {
  readonly tick: (undefined | Ethers_BigInt_t); 
  readonly feeGrowthGlobal1X128: Ethers_BigInt_t; 
  readonly volumeUSD: number; 
  readonly sqrtPrice: Ethers_BigInt_t; 
  readonly feesUSD: number; 
  readonly liquidity: Ethers_BigInt_t; 
  readonly txCount: Ethers_BigInt_t; 
  readonly openPrice0: number; 
  readonly volumeToken0: number; 
  readonly high: number; 
  readonly low: number; 
  readonly tvlUSD: number; 
  readonly date: number; 
  readonly token1Price: number; 
  readonly close: number; 
  readonly token0Price: number; 
  readonly pool_id: id; 
  readonly feeGrowthGlobal0X128: Ethers_BigInt_t; 
  readonly volumeToken1: number; 
  readonly id: id
};
export type PoolDayDataEntity = poolDayDataEntity;

// tslint:disable-next-line:interface-over-type-literal
export type poolHourDataEntity = {
  readonly token1Price: number; 
  readonly feesUSD: number; 
  readonly liquidity: Ethers_BigInt_t; 
  readonly sqrtPrice: Ethers_BigInt_t; 
  readonly volumeToken1: number; 
  readonly pool_id: id; 
  readonly tick: (undefined | Ethers_BigInt_t); 
  readonly feeGrowthGlobal1X128: Ethers_BigInt_t; 
  readonly volumeUSD: number; 
  readonly high: number; 
  readonly openPrice0: number; 
  readonly token0Price: number; 
  readonly feeGrowthGlobal0X128: Ethers_BigInt_t; 
  readonly txCount: Ethers_BigInt_t; 
  readonly close: number; 
  readonly tvlUSD: number; 
  readonly volumeToken0: number; 
  readonly periodStartUnix: number; 
  readonly id: id; 
  readonly low: number
};
export type PoolHourDataEntity = poolHourDataEntity;

// tslint:disable-next-line:interface-over-type-literal
export type positionEntity = {
  readonly owner: string; 
  readonly feeGrowthInside0LastX128: Ethers_BigInt_t; 
  readonly liquidity: Ethers_BigInt_t; 
  readonly token1_id: id; 
  readonly token0_id: id; 
  readonly tickLower_id: id; 
  readonly transaction_id: id; 
  readonly collectedFeesToken1: number; 
  readonly feeGrowthInside1LastX128: Ethers_BigInt_t; 
  readonly id: id; 
  readonly pool_id: id; 
  readonly withdrawnToken1: number; 
  readonly collectedToken1: number; 
  readonly depositedToken0: number; 
  readonly withdrawnToken0: number; 
  readonly depositedToken1: number; 
  readonly collectedToken0: number; 
  readonly tickUpper_id: id; 
  readonly collectedFeesToken0: number
};
export type PositionEntity = positionEntity;

// tslint:disable-next-line:interface-over-type-literal
export type positionSnapshotEntity = {
  readonly owner: string; 
  readonly depositedToken1: number; 
  readonly feeGrowthInside0LastX128: Ethers_BigInt_t; 
  readonly withdrawnToken1: number; 
  readonly id: id; 
  readonly timestamp: Ethers_BigInt_t; 
  readonly pool_id: id; 
  readonly position_id: id; 
  readonly liquidity: Ethers_BigInt_t; 
  readonly collectedFeesToken0: number; 
  readonly transaction_id: id; 
  readonly depositedToken0: number; 
  readonly feeGrowthInside1LastX128: Ethers_BigInt_t; 
  readonly collectedFeesToken1: number; 
  readonly blockNumber: Ethers_BigInt_t; 
  readonly withdrawnToken0: number
};
export type PositionSnapshotEntity = positionSnapshotEntity;

// tslint:disable-next-line:interface-over-type-literal
export type swapEntity = {
  readonly origin: string; 
  readonly sqrtPriceX96: Ethers_BigInt_t; 
  readonly tick_id: id; 
  readonly amount0: number; 
  readonly transaction_id: id; 
  readonly timestamp: Ethers_BigInt_t; 
  readonly amount1: number; 
  readonly token1_id: id; 
  readonly logIndex: (undefined | Ethers_BigInt_t); 
  readonly sender: string; 
  readonly recipient: string; 
  readonly amountUSD: number; 
  readonly token0_id: id; 
  readonly id: id; 
  readonly pool_id: id
};
export type SwapEntity = swapEntity;

// tslint:disable-next-line:interface-over-type-literal
export type tickEntity = {
  readonly collectedFeesToken1: number; 
  readonly createdAtTimestamp: Ethers_BigInt_t; 
  readonly createdAtBlockNumber: Ethers_BigInt_t; 
  readonly id: id; 
  readonly liquidityNet: Ethers_BigInt_t; 
  readonly volumeToken0: number; 
  readonly volumeToken1: number; 
  readonly collectedFeesToken0: number; 
  readonly collectedFeesUSD: number; 
  readonly feeGrowthOutside1X128: Ethers_BigInt_t; 
  readonly price1: number; 
  readonly liquidityProviderCount: Ethers_BigInt_t; 
  readonly feeGrowthOutside0X128: Ethers_BigInt_t; 
  readonly liquidityGross: Ethers_BigInt_t; 
  readonly volumeUSD: number; 
  readonly price0: number; 
  readonly untrackedVolumeUSD: number; 
  readonly poolAddress: (undefined | string); 
  readonly feesUSD: number; 
  readonly pool_id: id; 
  readonly tickIdx: Ethers_BigInt_t
};
export type TickEntity = tickEntity;

// tslint:disable-next-line:interface-over-type-literal
export type tickDayDataEntity = {
  readonly feesUSD: number; 
  readonly pool_id: id; 
  readonly tick_id: id; 
  readonly date: number; 
  readonly liquidityNet: Ethers_BigInt_t; 
  readonly feeGrowthOutside0X128: Ethers_BigInt_t; 
  readonly volumeUSD: number; 
  readonly feeGrowthOutside1X128: Ethers_BigInt_t; 
  readonly volumeToken1: number; 
  readonly id: id; 
  readonly volumeToken0: number; 
  readonly liquidityGross: Ethers_BigInt_t
};
export type TickDayDataEntity = tickDayDataEntity;

// tslint:disable-next-line:interface-over-type-literal
export type tickHourDataEntity = {
  readonly id: id; 
  readonly tick_id: id; 
  readonly liquidityGross: Ethers_BigInt_t; 
  readonly volumeToken0: number; 
  readonly liquidityNet: Ethers_BigInt_t; 
  readonly volumeUSD: number; 
  readonly pool_id: id; 
  readonly feesUSD: number; 
  readonly periodStartUnix: number; 
  readonly volumeToken1: number
};
export type TickHourDataEntity = tickHourDataEntity;

// tslint:disable-next-line:interface-over-type-literal
export type tokenEntity = {
  readonly txCount: Ethers_BigInt_t; 
  readonly untrackedVolumeUSD: number; 
  readonly derivedETH: number; 
  readonly name: string; 
  readonly symbol: string; 
  readonly feesUSD: number; 
  readonly totalValueLocked: number; 
  readonly id: id; 
  readonly volumeUSD: number; 
  readonly totalSupply: Ethers_BigInt_t; 
  readonly poolCount: Ethers_BigInt_t; 
  readonly decimals: Ethers_BigInt_t; 
  readonly volume: number; 
  readonly totalValueLockedUSDUntracked: number; 
  readonly totalValueLockedUSD: number
};
export type TokenEntity = tokenEntity;

// tslint:disable-next-line:interface-over-type-literal
export type tokenDayDataEntity = {
  readonly high: number; 
  readonly totalValueLocked: number; 
  readonly low: number; 
  readonly feesUSD: number; 
  readonly close: number; 
  readonly volumeUSD: number; 
  readonly volume: number; 
  readonly untrackedVolumeUSD: number; 
  readonly totalValueLockedUSD: number; 
  readonly priceUSD: number; 
  readonly date: number; 
  readonly token_id: id; 
  readonly openPrice: number; 
  readonly id: id
};
export type TokenDayDataEntity = tokenDayDataEntity;

// tslint:disable-next-line:interface-over-type-literal
export type tokenHourDataEntity = {
  readonly untrackedVolumeUSD: number; 
  readonly token_id: id; 
  readonly priceUSD: number; 
  readonly openPrice: number; 
  readonly totalValueLockedUSD: number; 
  readonly volume: number; 
  readonly id: id; 
  readonly feesUSD: number; 
  readonly close: number; 
  readonly low: number; 
  readonly high: number; 
  readonly periodStartUnix: number; 
  readonly totalValueLocked: number; 
  readonly volumeUSD: number
};
export type TokenHourDataEntity = tokenHourDataEntity;

// tslint:disable-next-line:interface-over-type-literal
export type tokenPoolWhitelistEntity = {
  readonly token_id: id; 
  readonly pool_id: id; 
  readonly id: id
};
export type TokenPoolWhitelistEntity = tokenPoolWhitelistEntity;

// tslint:disable-next-line:interface-over-type-literal
export type transactionEntity = {
  readonly blockNumber: Ethers_BigInt_t; 
  readonly id: id; 
  readonly timestamp: Ethers_BigInt_t; 
  readonly gasPrice: Ethers_BigInt_t; 
  readonly gasUsed: Ethers_BigInt_t
};
export type TransactionEntity = transactionEntity;

// tslint:disable-next-line:interface-over-type-literal
export type uniswapDayDataEntity = {
  readonly volumeUSD: number; 
  readonly feesUSD: number; 
  readonly id: id; 
  readonly tvlUSD: number; 
  readonly txCount: Ethers_BigInt_t; 
  readonly volumeETH: number; 
  readonly volumeUSDUntracked: number; 
  readonly date: number
};
export type UniswapDayDataEntity = uniswapDayDataEntity;

// tslint:disable-next-line:interface-over-type-literal
export type dbOp = "Read" | "Set" | "Delete";

// tslint:disable-next-line:interface-over-type-literal
export type inMemoryStoreRow<a> = { readonly dbOp: dbOp; readonly entity: a };

// tslint:disable-next-line:interface-over-type-literal
export type eventLog<a> = {
  readonly params: a; 
  readonly chainId: number; 
  readonly txOrigin: (undefined | Ethers_ethAddress); 
  readonly blockNumber: number; 
  readonly blockTimestamp: number; 
  readonly blockHash: string; 
  readonly srcAddress: Ethers_ethAddress; 
  readonly transactionHash: string; 
  readonly transactionIndex: number; 
  readonly logIndex: number
};
export type EventLog<a> = eventLog<a>;

// tslint:disable-next-line:interface-over-type-literal
export type FactoryContract_PoolCreatedEvent_eventArgs = {
  readonly token0: Ethers_ethAddress; 
  readonly token1: Ethers_ethAddress; 
  readonly fee: Ethers_BigInt_t; 
  readonly tickSpacing: Ethers_BigInt_t; 
  readonly pool: Ethers_ethAddress
};

// tslint:disable-next-line:interface-over-type-literal
export type FactoryContract_PoolCreatedEvent_log = eventLog<FactoryContract_PoolCreatedEvent_eventArgs>;
export type FactoryContract_PoolCreated_EventLog = FactoryContract_PoolCreatedEvent_log;

// tslint:disable-next-line:interface-over-type-literal
export type FactoryContract_PoolCreatedEvent_bundleEntityHandlerContext = { readonly set: (_1:bundleEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type FactoryContract_PoolCreatedEvent_bundleEntityHandlerContextAsync = { readonly set: (_1:bundleEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type FactoryContract_PoolCreatedEvent_burnEntityHandlerContext = {
  readonly getTransaction: (_1:burnEntity) => transactionEntity; 
  readonly getToken0: (_1:burnEntity) => tokenEntity; 
  readonly getPool: (_1:burnEntity) => poolEntity; 
  readonly getToken1: (_1:burnEntity) => tokenEntity; 
  readonly set: (_1:burnEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type FactoryContract_PoolCreatedEvent_burnEntityHandlerContextAsync = {
  readonly getTransaction: (_1:burnEntity) => Promise<transactionEntity>; 
  readonly getToken0: (_1:burnEntity) => Promise<tokenEntity>; 
  readonly getPool: (_1:burnEntity) => Promise<poolEntity>; 
  readonly getToken1: (_1:burnEntity) => Promise<tokenEntity>; 
  readonly set: (_1:burnEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type FactoryContract_PoolCreatedEvent_collectEntityHandlerContext = {
  readonly getTransaction: (_1:collectEntity) => transactionEntity; 
  readonly getPool: (_1:collectEntity) => poolEntity; 
  readonly set: (_1:collectEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type FactoryContract_PoolCreatedEvent_collectEntityHandlerContextAsync = {
  readonly getTransaction: (_1:collectEntity) => Promise<transactionEntity>; 
  readonly getPool: (_1:collectEntity) => Promise<poolEntity>; 
  readonly set: (_1:collectEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type FactoryContract_PoolCreatedEvent_factoryEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | factoryEntity); 
  readonly set: (_1:factoryEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type FactoryContract_PoolCreatedEvent_factoryEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | factoryEntity)>; 
  readonly set: (_1:factoryEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type FactoryContract_PoolCreatedEvent_flashEntityHandlerContext = {
  readonly getPool: (_1:flashEntity) => poolEntity; 
  readonly getTransaction: (_1:flashEntity) => transactionEntity; 
  readonly set: (_1:flashEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type FactoryContract_PoolCreatedEvent_flashEntityHandlerContextAsync = {
  readonly getPool: (_1:flashEntity) => Promise<poolEntity>; 
  readonly getTransaction: (_1:flashEntity) => Promise<transactionEntity>; 
  readonly set: (_1:flashEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type FactoryContract_PoolCreatedEvent_mintEntityHandlerContext = {
  readonly getToken0: (_1:mintEntity) => tokenEntity; 
  readonly getTransaction: (_1:mintEntity) => transactionEntity; 
  readonly getPool: (_1:mintEntity) => poolEntity; 
  readonly getToken1: (_1:mintEntity) => tokenEntity; 
  readonly set: (_1:mintEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type FactoryContract_PoolCreatedEvent_mintEntityHandlerContextAsync = {
  readonly getToken0: (_1:mintEntity) => Promise<tokenEntity>; 
  readonly getTransaction: (_1:mintEntity) => Promise<transactionEntity>; 
  readonly getPool: (_1:mintEntity) => Promise<poolEntity>; 
  readonly getToken1: (_1:mintEntity) => Promise<tokenEntity>; 
  readonly set: (_1:mintEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type FactoryContract_PoolCreatedEvent_poolEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | poolEntity); 
  readonly getToken1: (_1:poolEntity) => tokenEntity; 
  readonly getToken0: (_1:poolEntity) => tokenEntity; 
  readonly set: (_1:poolEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type FactoryContract_PoolCreatedEvent_poolEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | poolEntity)>; 
  readonly getToken1: (_1:poolEntity) => Promise<tokenEntity>; 
  readonly getToken0: (_1:poolEntity) => Promise<tokenEntity>; 
  readonly set: (_1:poolEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type FactoryContract_PoolCreatedEvent_poolDayDataEntityHandlerContext = {
  readonly getPool: (_1:poolDayDataEntity) => poolEntity; 
  readonly set: (_1:poolDayDataEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type FactoryContract_PoolCreatedEvent_poolDayDataEntityHandlerContextAsync = {
  readonly getPool: (_1:poolDayDataEntity) => Promise<poolEntity>; 
  readonly set: (_1:poolDayDataEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type FactoryContract_PoolCreatedEvent_poolHourDataEntityHandlerContext = {
  readonly getPool: (_1:poolHourDataEntity) => poolEntity; 
  readonly set: (_1:poolHourDataEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type FactoryContract_PoolCreatedEvent_poolHourDataEntityHandlerContextAsync = {
  readonly getPool: (_1:poolHourDataEntity) => Promise<poolEntity>; 
  readonly set: (_1:poolHourDataEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type FactoryContract_PoolCreatedEvent_positionEntityHandlerContext = {
  readonly getToken1: (_1:positionEntity) => tokenEntity; 
  readonly getToken0: (_1:positionEntity) => tokenEntity; 
  readonly getTickLower: (_1:positionEntity) => tickEntity; 
  readonly getTransaction: (_1:positionEntity) => transactionEntity; 
  readonly getPool: (_1:positionEntity) => poolEntity; 
  readonly getTickUpper: (_1:positionEntity) => tickEntity; 
  readonly set: (_1:positionEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type FactoryContract_PoolCreatedEvent_positionEntityHandlerContextAsync = {
  readonly getToken1: (_1:positionEntity) => Promise<tokenEntity>; 
  readonly getToken0: (_1:positionEntity) => Promise<tokenEntity>; 
  readonly getTickLower: (_1:positionEntity) => Promise<tickEntity>; 
  readonly getTransaction: (_1:positionEntity) => Promise<transactionEntity>; 
  readonly getPool: (_1:positionEntity) => Promise<poolEntity>; 
  readonly getTickUpper: (_1:positionEntity) => Promise<tickEntity>; 
  readonly set: (_1:positionEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type FactoryContract_PoolCreatedEvent_positionSnapshotEntityHandlerContext = {
  readonly getPool: (_1:positionSnapshotEntity) => poolEntity; 
  readonly getPosition: (_1:positionSnapshotEntity) => positionEntity; 
  readonly getTransaction: (_1:positionSnapshotEntity) => transactionEntity; 
  readonly set: (_1:positionSnapshotEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type FactoryContract_PoolCreatedEvent_positionSnapshotEntityHandlerContextAsync = {
  readonly getPool: (_1:positionSnapshotEntity) => Promise<poolEntity>; 
  readonly getPosition: (_1:positionSnapshotEntity) => Promise<positionEntity>; 
  readonly getTransaction: (_1:positionSnapshotEntity) => Promise<transactionEntity>; 
  readonly set: (_1:positionSnapshotEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type FactoryContract_PoolCreatedEvent_swapEntityHandlerContext = {
  readonly getTick: (_1:swapEntity) => tickEntity; 
  readonly getTransaction: (_1:swapEntity) => transactionEntity; 
  readonly getToken1: (_1:swapEntity) => tokenEntity; 
  readonly getToken0: (_1:swapEntity) => tokenEntity; 
  readonly getPool: (_1:swapEntity) => poolEntity; 
  readonly set: (_1:swapEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type FactoryContract_PoolCreatedEvent_swapEntityHandlerContextAsync = {
  readonly getTick: (_1:swapEntity) => Promise<tickEntity>; 
  readonly getTransaction: (_1:swapEntity) => Promise<transactionEntity>; 
  readonly getToken1: (_1:swapEntity) => Promise<tokenEntity>; 
  readonly getToken0: (_1:swapEntity) => Promise<tokenEntity>; 
  readonly getPool: (_1:swapEntity) => Promise<poolEntity>; 
  readonly set: (_1:swapEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type FactoryContract_PoolCreatedEvent_tickEntityHandlerContext = {
  readonly getPool: (_1:tickEntity) => poolEntity; 
  readonly set: (_1:tickEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type FactoryContract_PoolCreatedEvent_tickEntityHandlerContextAsync = {
  readonly getPool: (_1:tickEntity) => Promise<poolEntity>; 
  readonly set: (_1:tickEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type FactoryContract_PoolCreatedEvent_tickDayDataEntityHandlerContext = {
  readonly getPool: (_1:tickDayDataEntity) => poolEntity; 
  readonly getTick: (_1:tickDayDataEntity) => tickEntity; 
  readonly set: (_1:tickDayDataEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type FactoryContract_PoolCreatedEvent_tickDayDataEntityHandlerContextAsync = {
  readonly getPool: (_1:tickDayDataEntity) => Promise<poolEntity>; 
  readonly getTick: (_1:tickDayDataEntity) => Promise<tickEntity>; 
  readonly set: (_1:tickDayDataEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type FactoryContract_PoolCreatedEvent_tickHourDataEntityHandlerContext = {
  readonly getTick: (_1:tickHourDataEntity) => tickEntity; 
  readonly getPool: (_1:tickHourDataEntity) => poolEntity; 
  readonly set: (_1:tickHourDataEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type FactoryContract_PoolCreatedEvent_tickHourDataEntityHandlerContextAsync = {
  readonly getTick: (_1:tickHourDataEntity) => Promise<tickEntity>; 
  readonly getPool: (_1:tickHourDataEntity) => Promise<poolEntity>; 
  readonly set: (_1:tickHourDataEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type FactoryContract_PoolCreatedEvent_tokenEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | tokenEntity); 
  readonly set: (_1:tokenEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type FactoryContract_PoolCreatedEvent_tokenEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | tokenEntity)>; 
  readonly set: (_1:tokenEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type FactoryContract_PoolCreatedEvent_tokenDayDataEntityHandlerContext = {
  readonly getToken: (_1:tokenDayDataEntity) => tokenEntity; 
  readonly set: (_1:tokenDayDataEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type FactoryContract_PoolCreatedEvent_tokenDayDataEntityHandlerContextAsync = {
  readonly getToken: (_1:tokenDayDataEntity) => Promise<tokenEntity>; 
  readonly set: (_1:tokenDayDataEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type FactoryContract_PoolCreatedEvent_tokenHourDataEntityHandlerContext = {
  readonly getToken: (_1:tokenHourDataEntity) => tokenEntity; 
  readonly set: (_1:tokenHourDataEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type FactoryContract_PoolCreatedEvent_tokenHourDataEntityHandlerContextAsync = {
  readonly getToken: (_1:tokenHourDataEntity) => Promise<tokenEntity>; 
  readonly set: (_1:tokenHourDataEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type FactoryContract_PoolCreatedEvent_tokenPoolWhitelistEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | tokenPoolWhitelistEntity); 
  readonly getToken: (_1:tokenPoolWhitelistEntity) => tokenEntity; 
  readonly getPool: (_1:tokenPoolWhitelistEntity) => poolEntity; 
  readonly set: (_1:tokenPoolWhitelistEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type FactoryContract_PoolCreatedEvent_tokenPoolWhitelistEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | tokenPoolWhitelistEntity)>; 
  readonly getToken: (_1:tokenPoolWhitelistEntity) => Promise<tokenEntity>; 
  readonly getPool: (_1:tokenPoolWhitelistEntity) => Promise<poolEntity>; 
  readonly set: (_1:tokenPoolWhitelistEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type FactoryContract_PoolCreatedEvent_transactionEntityHandlerContext = { readonly set: (_1:transactionEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type FactoryContract_PoolCreatedEvent_transactionEntityHandlerContextAsync = { readonly set: (_1:transactionEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type FactoryContract_PoolCreatedEvent_uniswapDayDataEntityHandlerContext = { readonly set: (_1:uniswapDayDataEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type FactoryContract_PoolCreatedEvent_uniswapDayDataEntityHandlerContextAsync = { readonly set: (_1:uniswapDayDataEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type FactoryContract_PoolCreatedEvent_handlerContext = {
  readonly log: Logs_userLogger; 
  readonly Bundle: FactoryContract_PoolCreatedEvent_bundleEntityHandlerContext; 
  readonly Burn: FactoryContract_PoolCreatedEvent_burnEntityHandlerContext; 
  readonly Collect: FactoryContract_PoolCreatedEvent_collectEntityHandlerContext; 
  readonly Factory: FactoryContract_PoolCreatedEvent_factoryEntityHandlerContext; 
  readonly Flash: FactoryContract_PoolCreatedEvent_flashEntityHandlerContext; 
  readonly Mint: FactoryContract_PoolCreatedEvent_mintEntityHandlerContext; 
  readonly Pool: FactoryContract_PoolCreatedEvent_poolEntityHandlerContext; 
  readonly PoolDayData: FactoryContract_PoolCreatedEvent_poolDayDataEntityHandlerContext; 
  readonly PoolHourData: FactoryContract_PoolCreatedEvent_poolHourDataEntityHandlerContext; 
  readonly Position: FactoryContract_PoolCreatedEvent_positionEntityHandlerContext; 
  readonly PositionSnapshot: FactoryContract_PoolCreatedEvent_positionSnapshotEntityHandlerContext; 
  readonly Swap: FactoryContract_PoolCreatedEvent_swapEntityHandlerContext; 
  readonly Tick: FactoryContract_PoolCreatedEvent_tickEntityHandlerContext; 
  readonly TickDayData: FactoryContract_PoolCreatedEvent_tickDayDataEntityHandlerContext; 
  readonly TickHourData: FactoryContract_PoolCreatedEvent_tickHourDataEntityHandlerContext; 
  readonly Token: FactoryContract_PoolCreatedEvent_tokenEntityHandlerContext; 
  readonly TokenDayData: FactoryContract_PoolCreatedEvent_tokenDayDataEntityHandlerContext; 
  readonly TokenHourData: FactoryContract_PoolCreatedEvent_tokenHourDataEntityHandlerContext; 
  readonly TokenPoolWhitelist: FactoryContract_PoolCreatedEvent_tokenPoolWhitelistEntityHandlerContext; 
  readonly Transaction: FactoryContract_PoolCreatedEvent_transactionEntityHandlerContext; 
  readonly UniswapDayData: FactoryContract_PoolCreatedEvent_uniswapDayDataEntityHandlerContext
};

// tslint:disable-next-line:interface-over-type-literal
export type FactoryContract_PoolCreatedEvent_handlerContextAsync = {
  readonly log: Logs_userLogger; 
  readonly Bundle: FactoryContract_PoolCreatedEvent_bundleEntityHandlerContextAsync; 
  readonly Burn: FactoryContract_PoolCreatedEvent_burnEntityHandlerContextAsync; 
  readonly Collect: FactoryContract_PoolCreatedEvent_collectEntityHandlerContextAsync; 
  readonly Factory: FactoryContract_PoolCreatedEvent_factoryEntityHandlerContextAsync; 
  readonly Flash: FactoryContract_PoolCreatedEvent_flashEntityHandlerContextAsync; 
  readonly Mint: FactoryContract_PoolCreatedEvent_mintEntityHandlerContextAsync; 
  readonly Pool: FactoryContract_PoolCreatedEvent_poolEntityHandlerContextAsync; 
  readonly PoolDayData: FactoryContract_PoolCreatedEvent_poolDayDataEntityHandlerContextAsync; 
  readonly PoolHourData: FactoryContract_PoolCreatedEvent_poolHourDataEntityHandlerContextAsync; 
  readonly Position: FactoryContract_PoolCreatedEvent_positionEntityHandlerContextAsync; 
  readonly PositionSnapshot: FactoryContract_PoolCreatedEvent_positionSnapshotEntityHandlerContextAsync; 
  readonly Swap: FactoryContract_PoolCreatedEvent_swapEntityHandlerContextAsync; 
  readonly Tick: FactoryContract_PoolCreatedEvent_tickEntityHandlerContextAsync; 
  readonly TickDayData: FactoryContract_PoolCreatedEvent_tickDayDataEntityHandlerContextAsync; 
  readonly TickHourData: FactoryContract_PoolCreatedEvent_tickHourDataEntityHandlerContextAsync; 
  readonly Token: FactoryContract_PoolCreatedEvent_tokenEntityHandlerContextAsync; 
  readonly TokenDayData: FactoryContract_PoolCreatedEvent_tokenDayDataEntityHandlerContextAsync; 
  readonly TokenHourData: FactoryContract_PoolCreatedEvent_tokenHourDataEntityHandlerContextAsync; 
  readonly TokenPoolWhitelist: FactoryContract_PoolCreatedEvent_tokenPoolWhitelistEntityHandlerContextAsync; 
  readonly Transaction: FactoryContract_PoolCreatedEvent_transactionEntityHandlerContextAsync; 
  readonly UniswapDayData: FactoryContract_PoolCreatedEvent_uniswapDayDataEntityHandlerContextAsync
};

// tslint:disable-next-line:interface-over-type-literal
export type FactoryContract_PoolCreatedEvent_poolEntityLoaderContext = { readonly load: (_1:id, _2:{ readonly loaders?: poolLoaderConfig }) => void };

// tslint:disable-next-line:interface-over-type-literal
export type FactoryContract_PoolCreatedEvent_factoryEntityLoaderContext = { readonly load: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type FactoryContract_PoolCreatedEvent_tokenEntityLoaderContext = { readonly load: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type FactoryContract_PoolCreatedEvent_tokenPoolWhitelistEntityLoaderContext = { readonly load: (_1:id, _2:{ readonly loaders?: tokenPoolWhitelistLoaderConfig }) => void };

// tslint:disable-next-line:interface-over-type-literal
export type FactoryContract_PoolCreatedEvent_contractRegistrations = {
  readonly addFactory: (_1:Ethers_ethAddress) => void; 
  readonly addNonfungiblePositionManager: (_1:Ethers_ethAddress) => void; 
  readonly addPool: (_1:Ethers_ethAddress) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type FactoryContract_PoolCreatedEvent_loaderContext = {
  readonly log: Logs_userLogger; 
  readonly contractRegistration: FactoryContract_PoolCreatedEvent_contractRegistrations; 
  readonly Pool: FactoryContract_PoolCreatedEvent_poolEntityLoaderContext; 
  readonly Factory: FactoryContract_PoolCreatedEvent_factoryEntityLoaderContext; 
  readonly Token: FactoryContract_PoolCreatedEvent_tokenEntityLoaderContext; 
  readonly TokenPoolWhitelist: FactoryContract_PoolCreatedEvent_tokenPoolWhitelistEntityLoaderContext
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_IncreaseLiquidityEvent_eventArgs = {
  readonly tokenId: Ethers_BigInt_t; 
  readonly liquidity: Ethers_BigInt_t; 
  readonly amount0: Ethers_BigInt_t; 
  readonly amount1: Ethers_BigInt_t
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_IncreaseLiquidityEvent_log = eventLog<NonfungiblePositionManagerContract_IncreaseLiquidityEvent_eventArgs>;
export type NonfungiblePositionManagerContract_IncreaseLiquidity_EventLog = NonfungiblePositionManagerContract_IncreaseLiquidityEvent_log;

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_IncreaseLiquidityEvent_bundleEntityHandlerContext = { readonly set: (_1:bundleEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_IncreaseLiquidityEvent_bundleEntityHandlerContextAsync = { readonly set: (_1:bundleEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_IncreaseLiquidityEvent_burnEntityHandlerContext = {
  readonly getTransaction: (_1:burnEntity) => transactionEntity; 
  readonly getToken0: (_1:burnEntity) => tokenEntity; 
  readonly getPool: (_1:burnEntity) => poolEntity; 
  readonly getToken1: (_1:burnEntity) => tokenEntity; 
  readonly set: (_1:burnEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_IncreaseLiquidityEvent_burnEntityHandlerContextAsync = {
  readonly getTransaction: (_1:burnEntity) => Promise<transactionEntity>; 
  readonly getToken0: (_1:burnEntity) => Promise<tokenEntity>; 
  readonly getPool: (_1:burnEntity) => Promise<poolEntity>; 
  readonly getToken1: (_1:burnEntity) => Promise<tokenEntity>; 
  readonly set: (_1:burnEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_IncreaseLiquidityEvent_collectEntityHandlerContext = {
  readonly getTransaction: (_1:collectEntity) => transactionEntity; 
  readonly getPool: (_1:collectEntity) => poolEntity; 
  readonly set: (_1:collectEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_IncreaseLiquidityEvent_collectEntityHandlerContextAsync = {
  readonly getTransaction: (_1:collectEntity) => Promise<transactionEntity>; 
  readonly getPool: (_1:collectEntity) => Promise<poolEntity>; 
  readonly set: (_1:collectEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_IncreaseLiquidityEvent_factoryEntityHandlerContext = { readonly set: (_1:factoryEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_IncreaseLiquidityEvent_factoryEntityHandlerContextAsync = { readonly set: (_1:factoryEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_IncreaseLiquidityEvent_flashEntityHandlerContext = {
  readonly getPool: (_1:flashEntity) => poolEntity; 
  readonly getTransaction: (_1:flashEntity) => transactionEntity; 
  readonly set: (_1:flashEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_IncreaseLiquidityEvent_flashEntityHandlerContextAsync = {
  readonly getPool: (_1:flashEntity) => Promise<poolEntity>; 
  readonly getTransaction: (_1:flashEntity) => Promise<transactionEntity>; 
  readonly set: (_1:flashEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_IncreaseLiquidityEvent_mintEntityHandlerContext = {
  readonly getToken0: (_1:mintEntity) => tokenEntity; 
  readonly getTransaction: (_1:mintEntity) => transactionEntity; 
  readonly getPool: (_1:mintEntity) => poolEntity; 
  readonly getToken1: (_1:mintEntity) => tokenEntity; 
  readonly set: (_1:mintEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_IncreaseLiquidityEvent_mintEntityHandlerContextAsync = {
  readonly getToken0: (_1:mintEntity) => Promise<tokenEntity>; 
  readonly getTransaction: (_1:mintEntity) => Promise<transactionEntity>; 
  readonly getPool: (_1:mintEntity) => Promise<poolEntity>; 
  readonly getToken1: (_1:mintEntity) => Promise<tokenEntity>; 
  readonly set: (_1:mintEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_IncreaseLiquidityEvent_poolEntityHandlerContext = {
  readonly getToken1: (_1:poolEntity) => tokenEntity; 
  readonly getToken0: (_1:poolEntity) => tokenEntity; 
  readonly set: (_1:poolEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_IncreaseLiquidityEvent_poolEntityHandlerContextAsync = {
  readonly getToken1: (_1:poolEntity) => Promise<tokenEntity>; 
  readonly getToken0: (_1:poolEntity) => Promise<tokenEntity>; 
  readonly set: (_1:poolEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_IncreaseLiquidityEvent_poolDayDataEntityHandlerContext = {
  readonly getPool: (_1:poolDayDataEntity) => poolEntity; 
  readonly set: (_1:poolDayDataEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_IncreaseLiquidityEvent_poolDayDataEntityHandlerContextAsync = {
  readonly getPool: (_1:poolDayDataEntity) => Promise<poolEntity>; 
  readonly set: (_1:poolDayDataEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_IncreaseLiquidityEvent_poolHourDataEntityHandlerContext = {
  readonly getPool: (_1:poolHourDataEntity) => poolEntity; 
  readonly set: (_1:poolHourDataEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_IncreaseLiquidityEvent_poolHourDataEntityHandlerContextAsync = {
  readonly getPool: (_1:poolHourDataEntity) => Promise<poolEntity>; 
  readonly set: (_1:poolHourDataEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_IncreaseLiquidityEvent_positionEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | positionEntity); 
  readonly getToken1: (_1:positionEntity) => tokenEntity; 
  readonly getToken0: (_1:positionEntity) => tokenEntity; 
  readonly getTickLower: (_1:positionEntity) => tickEntity; 
  readonly getTransaction: (_1:positionEntity) => transactionEntity; 
  readonly getPool: (_1:positionEntity) => poolEntity; 
  readonly getTickUpper: (_1:positionEntity) => tickEntity; 
  readonly set: (_1:positionEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_IncreaseLiquidityEvent_positionEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | positionEntity)>; 
  readonly getToken1: (_1:positionEntity) => Promise<tokenEntity>; 
  readonly getToken0: (_1:positionEntity) => Promise<tokenEntity>; 
  readonly getTickLower: (_1:positionEntity) => Promise<tickEntity>; 
  readonly getTransaction: (_1:positionEntity) => Promise<transactionEntity>; 
  readonly getPool: (_1:positionEntity) => Promise<poolEntity>; 
  readonly getTickUpper: (_1:positionEntity) => Promise<tickEntity>; 
  readonly set: (_1:positionEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_IncreaseLiquidityEvent_positionSnapshotEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | positionSnapshotEntity); 
  readonly getPool: (_1:positionSnapshotEntity) => poolEntity; 
  readonly getPosition: (_1:positionSnapshotEntity) => positionEntity; 
  readonly getTransaction: (_1:positionSnapshotEntity) => transactionEntity; 
  readonly set: (_1:positionSnapshotEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_IncreaseLiquidityEvent_positionSnapshotEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | positionSnapshotEntity)>; 
  readonly getPool: (_1:positionSnapshotEntity) => Promise<poolEntity>; 
  readonly getPosition: (_1:positionSnapshotEntity) => Promise<positionEntity>; 
  readonly getTransaction: (_1:positionSnapshotEntity) => Promise<transactionEntity>; 
  readonly set: (_1:positionSnapshotEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_IncreaseLiquidityEvent_swapEntityHandlerContext = {
  readonly getTick: (_1:swapEntity) => tickEntity; 
  readonly getTransaction: (_1:swapEntity) => transactionEntity; 
  readonly getToken1: (_1:swapEntity) => tokenEntity; 
  readonly getToken0: (_1:swapEntity) => tokenEntity; 
  readonly getPool: (_1:swapEntity) => poolEntity; 
  readonly set: (_1:swapEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_IncreaseLiquidityEvent_swapEntityHandlerContextAsync = {
  readonly getTick: (_1:swapEntity) => Promise<tickEntity>; 
  readonly getTransaction: (_1:swapEntity) => Promise<transactionEntity>; 
  readonly getToken1: (_1:swapEntity) => Promise<tokenEntity>; 
  readonly getToken0: (_1:swapEntity) => Promise<tokenEntity>; 
  readonly getPool: (_1:swapEntity) => Promise<poolEntity>; 
  readonly set: (_1:swapEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_IncreaseLiquidityEvent_tickEntityHandlerContext = {
  readonly getPool: (_1:tickEntity) => poolEntity; 
  readonly set: (_1:tickEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_IncreaseLiquidityEvent_tickEntityHandlerContextAsync = {
  readonly getPool: (_1:tickEntity) => Promise<poolEntity>; 
  readonly set: (_1:tickEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_IncreaseLiquidityEvent_tickDayDataEntityHandlerContext = {
  readonly getPool: (_1:tickDayDataEntity) => poolEntity; 
  readonly getTick: (_1:tickDayDataEntity) => tickEntity; 
  readonly set: (_1:tickDayDataEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_IncreaseLiquidityEvent_tickDayDataEntityHandlerContextAsync = {
  readonly getPool: (_1:tickDayDataEntity) => Promise<poolEntity>; 
  readonly getTick: (_1:tickDayDataEntity) => Promise<tickEntity>; 
  readonly set: (_1:tickDayDataEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_IncreaseLiquidityEvent_tickHourDataEntityHandlerContext = {
  readonly getTick: (_1:tickHourDataEntity) => tickEntity; 
  readonly getPool: (_1:tickHourDataEntity) => poolEntity; 
  readonly set: (_1:tickHourDataEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_IncreaseLiquidityEvent_tickHourDataEntityHandlerContextAsync = {
  readonly getTick: (_1:tickHourDataEntity) => Promise<tickEntity>; 
  readonly getPool: (_1:tickHourDataEntity) => Promise<poolEntity>; 
  readonly set: (_1:tickHourDataEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_IncreaseLiquidityEvent_tokenEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | tokenEntity); 
  readonly set: (_1:tokenEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_IncreaseLiquidityEvent_tokenEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | tokenEntity)>; 
  readonly set: (_1:tokenEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_IncreaseLiquidityEvent_tokenDayDataEntityHandlerContext = {
  readonly getToken: (_1:tokenDayDataEntity) => tokenEntity; 
  readonly set: (_1:tokenDayDataEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_IncreaseLiquidityEvent_tokenDayDataEntityHandlerContextAsync = {
  readonly getToken: (_1:tokenDayDataEntity) => Promise<tokenEntity>; 
  readonly set: (_1:tokenDayDataEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_IncreaseLiquidityEvent_tokenHourDataEntityHandlerContext = {
  readonly getToken: (_1:tokenHourDataEntity) => tokenEntity; 
  readonly set: (_1:tokenHourDataEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_IncreaseLiquidityEvent_tokenHourDataEntityHandlerContextAsync = {
  readonly getToken: (_1:tokenHourDataEntity) => Promise<tokenEntity>; 
  readonly set: (_1:tokenHourDataEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_IncreaseLiquidityEvent_tokenPoolWhitelistEntityHandlerContext = {
  readonly getToken: (_1:tokenPoolWhitelistEntity) => tokenEntity; 
  readonly getPool: (_1:tokenPoolWhitelistEntity) => poolEntity; 
  readonly set: (_1:tokenPoolWhitelistEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_IncreaseLiquidityEvent_tokenPoolWhitelistEntityHandlerContextAsync = {
  readonly getToken: (_1:tokenPoolWhitelistEntity) => Promise<tokenEntity>; 
  readonly getPool: (_1:tokenPoolWhitelistEntity) => Promise<poolEntity>; 
  readonly set: (_1:tokenPoolWhitelistEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_IncreaseLiquidityEvent_transactionEntityHandlerContext = { readonly set: (_1:transactionEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_IncreaseLiquidityEvent_transactionEntityHandlerContextAsync = { readonly set: (_1:transactionEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_IncreaseLiquidityEvent_uniswapDayDataEntityHandlerContext = { readonly set: (_1:uniswapDayDataEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_IncreaseLiquidityEvent_uniswapDayDataEntityHandlerContextAsync = { readonly set: (_1:uniswapDayDataEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_IncreaseLiquidityEvent_handlerContext = {
  readonly log: Logs_userLogger; 
  readonly Bundle: NonfungiblePositionManagerContract_IncreaseLiquidityEvent_bundleEntityHandlerContext; 
  readonly Burn: NonfungiblePositionManagerContract_IncreaseLiquidityEvent_burnEntityHandlerContext; 
  readonly Collect: NonfungiblePositionManagerContract_IncreaseLiquidityEvent_collectEntityHandlerContext; 
  readonly Factory: NonfungiblePositionManagerContract_IncreaseLiquidityEvent_factoryEntityHandlerContext; 
  readonly Flash: NonfungiblePositionManagerContract_IncreaseLiquidityEvent_flashEntityHandlerContext; 
  readonly Mint: NonfungiblePositionManagerContract_IncreaseLiquidityEvent_mintEntityHandlerContext; 
  readonly Pool: NonfungiblePositionManagerContract_IncreaseLiquidityEvent_poolEntityHandlerContext; 
  readonly PoolDayData: NonfungiblePositionManagerContract_IncreaseLiquidityEvent_poolDayDataEntityHandlerContext; 
  readonly PoolHourData: NonfungiblePositionManagerContract_IncreaseLiquidityEvent_poolHourDataEntityHandlerContext; 
  readonly Position: NonfungiblePositionManagerContract_IncreaseLiquidityEvent_positionEntityHandlerContext; 
  readonly PositionSnapshot: NonfungiblePositionManagerContract_IncreaseLiquidityEvent_positionSnapshotEntityHandlerContext; 
  readonly Swap: NonfungiblePositionManagerContract_IncreaseLiquidityEvent_swapEntityHandlerContext; 
  readonly Tick: NonfungiblePositionManagerContract_IncreaseLiquidityEvent_tickEntityHandlerContext; 
  readonly TickDayData: NonfungiblePositionManagerContract_IncreaseLiquidityEvent_tickDayDataEntityHandlerContext; 
  readonly TickHourData: NonfungiblePositionManagerContract_IncreaseLiquidityEvent_tickHourDataEntityHandlerContext; 
  readonly Token: NonfungiblePositionManagerContract_IncreaseLiquidityEvent_tokenEntityHandlerContext; 
  readonly TokenDayData: NonfungiblePositionManagerContract_IncreaseLiquidityEvent_tokenDayDataEntityHandlerContext; 
  readonly TokenHourData: NonfungiblePositionManagerContract_IncreaseLiquidityEvent_tokenHourDataEntityHandlerContext; 
  readonly TokenPoolWhitelist: NonfungiblePositionManagerContract_IncreaseLiquidityEvent_tokenPoolWhitelistEntityHandlerContext; 
  readonly Transaction: NonfungiblePositionManagerContract_IncreaseLiquidityEvent_transactionEntityHandlerContext; 
  readonly UniswapDayData: NonfungiblePositionManagerContract_IncreaseLiquidityEvent_uniswapDayDataEntityHandlerContext
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_IncreaseLiquidityEvent_handlerContextAsync = {
  readonly log: Logs_userLogger; 
  readonly Bundle: NonfungiblePositionManagerContract_IncreaseLiquidityEvent_bundleEntityHandlerContextAsync; 
  readonly Burn: NonfungiblePositionManagerContract_IncreaseLiquidityEvent_burnEntityHandlerContextAsync; 
  readonly Collect: NonfungiblePositionManagerContract_IncreaseLiquidityEvent_collectEntityHandlerContextAsync; 
  readonly Factory: NonfungiblePositionManagerContract_IncreaseLiquidityEvent_factoryEntityHandlerContextAsync; 
  readonly Flash: NonfungiblePositionManagerContract_IncreaseLiquidityEvent_flashEntityHandlerContextAsync; 
  readonly Mint: NonfungiblePositionManagerContract_IncreaseLiquidityEvent_mintEntityHandlerContextAsync; 
  readonly Pool: NonfungiblePositionManagerContract_IncreaseLiquidityEvent_poolEntityHandlerContextAsync; 
  readonly PoolDayData: NonfungiblePositionManagerContract_IncreaseLiquidityEvent_poolDayDataEntityHandlerContextAsync; 
  readonly PoolHourData: NonfungiblePositionManagerContract_IncreaseLiquidityEvent_poolHourDataEntityHandlerContextAsync; 
  readonly Position: NonfungiblePositionManagerContract_IncreaseLiquidityEvent_positionEntityHandlerContextAsync; 
  readonly PositionSnapshot: NonfungiblePositionManagerContract_IncreaseLiquidityEvent_positionSnapshotEntityHandlerContextAsync; 
  readonly Swap: NonfungiblePositionManagerContract_IncreaseLiquidityEvent_swapEntityHandlerContextAsync; 
  readonly Tick: NonfungiblePositionManagerContract_IncreaseLiquidityEvent_tickEntityHandlerContextAsync; 
  readonly TickDayData: NonfungiblePositionManagerContract_IncreaseLiquidityEvent_tickDayDataEntityHandlerContextAsync; 
  readonly TickHourData: NonfungiblePositionManagerContract_IncreaseLiquidityEvent_tickHourDataEntityHandlerContextAsync; 
  readonly Token: NonfungiblePositionManagerContract_IncreaseLiquidityEvent_tokenEntityHandlerContextAsync; 
  readonly TokenDayData: NonfungiblePositionManagerContract_IncreaseLiquidityEvent_tokenDayDataEntityHandlerContextAsync; 
  readonly TokenHourData: NonfungiblePositionManagerContract_IncreaseLiquidityEvent_tokenHourDataEntityHandlerContextAsync; 
  readonly TokenPoolWhitelist: NonfungiblePositionManagerContract_IncreaseLiquidityEvent_tokenPoolWhitelistEntityHandlerContextAsync; 
  readonly Transaction: NonfungiblePositionManagerContract_IncreaseLiquidityEvent_transactionEntityHandlerContextAsync; 
  readonly UniswapDayData: NonfungiblePositionManagerContract_IncreaseLiquidityEvent_uniswapDayDataEntityHandlerContextAsync
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_IncreaseLiquidityEvent_positionEntityLoaderContext = { readonly load: (_1:id, _2:{ readonly loaders?: positionLoaderConfig }) => void };

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_IncreaseLiquidityEvent_positionSnapshotEntityLoaderContext = { readonly load: (_1:id, _2:{ readonly loaders?: positionSnapshotLoaderConfig }) => void };

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_IncreaseLiquidityEvent_tokenEntityLoaderContext = { readonly load: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_IncreaseLiquidityEvent_contractRegistrations = {
  readonly addFactory: (_1:Ethers_ethAddress) => void; 
  readonly addNonfungiblePositionManager: (_1:Ethers_ethAddress) => void; 
  readonly addPool: (_1:Ethers_ethAddress) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_IncreaseLiquidityEvent_loaderContext = {
  readonly log: Logs_userLogger; 
  readonly contractRegistration: NonfungiblePositionManagerContract_IncreaseLiquidityEvent_contractRegistrations; 
  readonly Position: NonfungiblePositionManagerContract_IncreaseLiquidityEvent_positionEntityLoaderContext; 
  readonly PositionSnapshot: NonfungiblePositionManagerContract_IncreaseLiquidityEvent_positionSnapshotEntityLoaderContext; 
  readonly Token: NonfungiblePositionManagerContract_IncreaseLiquidityEvent_tokenEntityLoaderContext
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_DecreaseLiquidityEvent_eventArgs = {
  readonly tokenId: Ethers_BigInt_t; 
  readonly liquidity: Ethers_BigInt_t; 
  readonly amount0: Ethers_BigInt_t; 
  readonly amount1: Ethers_BigInt_t
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_DecreaseLiquidityEvent_log = eventLog<NonfungiblePositionManagerContract_DecreaseLiquidityEvent_eventArgs>;
export type NonfungiblePositionManagerContract_DecreaseLiquidity_EventLog = NonfungiblePositionManagerContract_DecreaseLiquidityEvent_log;

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_DecreaseLiquidityEvent_bundleEntityHandlerContext = { readonly set: (_1:bundleEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_DecreaseLiquidityEvent_bundleEntityHandlerContextAsync = { readonly set: (_1:bundleEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_DecreaseLiquidityEvent_burnEntityHandlerContext = {
  readonly getTransaction: (_1:burnEntity) => transactionEntity; 
  readonly getToken0: (_1:burnEntity) => tokenEntity; 
  readonly getPool: (_1:burnEntity) => poolEntity; 
  readonly getToken1: (_1:burnEntity) => tokenEntity; 
  readonly set: (_1:burnEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_DecreaseLiquidityEvent_burnEntityHandlerContextAsync = {
  readonly getTransaction: (_1:burnEntity) => Promise<transactionEntity>; 
  readonly getToken0: (_1:burnEntity) => Promise<tokenEntity>; 
  readonly getPool: (_1:burnEntity) => Promise<poolEntity>; 
  readonly getToken1: (_1:burnEntity) => Promise<tokenEntity>; 
  readonly set: (_1:burnEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_DecreaseLiquidityEvent_collectEntityHandlerContext = {
  readonly getTransaction: (_1:collectEntity) => transactionEntity; 
  readonly getPool: (_1:collectEntity) => poolEntity; 
  readonly set: (_1:collectEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_DecreaseLiquidityEvent_collectEntityHandlerContextAsync = {
  readonly getTransaction: (_1:collectEntity) => Promise<transactionEntity>; 
  readonly getPool: (_1:collectEntity) => Promise<poolEntity>; 
  readonly set: (_1:collectEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_DecreaseLiquidityEvent_factoryEntityHandlerContext = { readonly set: (_1:factoryEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_DecreaseLiquidityEvent_factoryEntityHandlerContextAsync = { readonly set: (_1:factoryEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_DecreaseLiquidityEvent_flashEntityHandlerContext = {
  readonly getPool: (_1:flashEntity) => poolEntity; 
  readonly getTransaction: (_1:flashEntity) => transactionEntity; 
  readonly set: (_1:flashEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_DecreaseLiquidityEvent_flashEntityHandlerContextAsync = {
  readonly getPool: (_1:flashEntity) => Promise<poolEntity>; 
  readonly getTransaction: (_1:flashEntity) => Promise<transactionEntity>; 
  readonly set: (_1:flashEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_DecreaseLiquidityEvent_mintEntityHandlerContext = {
  readonly getToken0: (_1:mintEntity) => tokenEntity; 
  readonly getTransaction: (_1:mintEntity) => transactionEntity; 
  readonly getPool: (_1:mintEntity) => poolEntity; 
  readonly getToken1: (_1:mintEntity) => tokenEntity; 
  readonly set: (_1:mintEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_DecreaseLiquidityEvent_mintEntityHandlerContextAsync = {
  readonly getToken0: (_1:mintEntity) => Promise<tokenEntity>; 
  readonly getTransaction: (_1:mintEntity) => Promise<transactionEntity>; 
  readonly getPool: (_1:mintEntity) => Promise<poolEntity>; 
  readonly getToken1: (_1:mintEntity) => Promise<tokenEntity>; 
  readonly set: (_1:mintEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_DecreaseLiquidityEvent_poolEntityHandlerContext = {
  readonly getToken1: (_1:poolEntity) => tokenEntity; 
  readonly getToken0: (_1:poolEntity) => tokenEntity; 
  readonly set: (_1:poolEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_DecreaseLiquidityEvent_poolEntityHandlerContextAsync = {
  readonly getToken1: (_1:poolEntity) => Promise<tokenEntity>; 
  readonly getToken0: (_1:poolEntity) => Promise<tokenEntity>; 
  readonly set: (_1:poolEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_DecreaseLiquidityEvent_poolDayDataEntityHandlerContext = {
  readonly getPool: (_1:poolDayDataEntity) => poolEntity; 
  readonly set: (_1:poolDayDataEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_DecreaseLiquidityEvent_poolDayDataEntityHandlerContextAsync = {
  readonly getPool: (_1:poolDayDataEntity) => Promise<poolEntity>; 
  readonly set: (_1:poolDayDataEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_DecreaseLiquidityEvent_poolHourDataEntityHandlerContext = {
  readonly getPool: (_1:poolHourDataEntity) => poolEntity; 
  readonly set: (_1:poolHourDataEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_DecreaseLiquidityEvent_poolHourDataEntityHandlerContextAsync = {
  readonly getPool: (_1:poolHourDataEntity) => Promise<poolEntity>; 
  readonly set: (_1:poolHourDataEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_DecreaseLiquidityEvent_positionEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | positionEntity); 
  readonly getToken1: (_1:positionEntity) => tokenEntity; 
  readonly getToken0: (_1:positionEntity) => tokenEntity; 
  readonly getTickLower: (_1:positionEntity) => tickEntity; 
  readonly getTransaction: (_1:positionEntity) => transactionEntity; 
  readonly getPool: (_1:positionEntity) => poolEntity; 
  readonly getTickUpper: (_1:positionEntity) => tickEntity; 
  readonly set: (_1:positionEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_DecreaseLiquidityEvent_positionEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | positionEntity)>; 
  readonly getToken1: (_1:positionEntity) => Promise<tokenEntity>; 
  readonly getToken0: (_1:positionEntity) => Promise<tokenEntity>; 
  readonly getTickLower: (_1:positionEntity) => Promise<tickEntity>; 
  readonly getTransaction: (_1:positionEntity) => Promise<transactionEntity>; 
  readonly getPool: (_1:positionEntity) => Promise<poolEntity>; 
  readonly getTickUpper: (_1:positionEntity) => Promise<tickEntity>; 
  readonly set: (_1:positionEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_DecreaseLiquidityEvent_positionSnapshotEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | positionSnapshotEntity); 
  readonly getPool: (_1:positionSnapshotEntity) => poolEntity; 
  readonly getPosition: (_1:positionSnapshotEntity) => positionEntity; 
  readonly getTransaction: (_1:positionSnapshotEntity) => transactionEntity; 
  readonly set: (_1:positionSnapshotEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_DecreaseLiquidityEvent_positionSnapshotEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | positionSnapshotEntity)>; 
  readonly getPool: (_1:positionSnapshotEntity) => Promise<poolEntity>; 
  readonly getPosition: (_1:positionSnapshotEntity) => Promise<positionEntity>; 
  readonly getTransaction: (_1:positionSnapshotEntity) => Promise<transactionEntity>; 
  readonly set: (_1:positionSnapshotEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_DecreaseLiquidityEvent_swapEntityHandlerContext = {
  readonly getTick: (_1:swapEntity) => tickEntity; 
  readonly getTransaction: (_1:swapEntity) => transactionEntity; 
  readonly getToken1: (_1:swapEntity) => tokenEntity; 
  readonly getToken0: (_1:swapEntity) => tokenEntity; 
  readonly getPool: (_1:swapEntity) => poolEntity; 
  readonly set: (_1:swapEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_DecreaseLiquidityEvent_swapEntityHandlerContextAsync = {
  readonly getTick: (_1:swapEntity) => Promise<tickEntity>; 
  readonly getTransaction: (_1:swapEntity) => Promise<transactionEntity>; 
  readonly getToken1: (_1:swapEntity) => Promise<tokenEntity>; 
  readonly getToken0: (_1:swapEntity) => Promise<tokenEntity>; 
  readonly getPool: (_1:swapEntity) => Promise<poolEntity>; 
  readonly set: (_1:swapEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_DecreaseLiquidityEvent_tickEntityHandlerContext = {
  readonly getPool: (_1:tickEntity) => poolEntity; 
  readonly set: (_1:tickEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_DecreaseLiquidityEvent_tickEntityHandlerContextAsync = {
  readonly getPool: (_1:tickEntity) => Promise<poolEntity>; 
  readonly set: (_1:tickEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_DecreaseLiquidityEvent_tickDayDataEntityHandlerContext = {
  readonly getPool: (_1:tickDayDataEntity) => poolEntity; 
  readonly getTick: (_1:tickDayDataEntity) => tickEntity; 
  readonly set: (_1:tickDayDataEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_DecreaseLiquidityEvent_tickDayDataEntityHandlerContextAsync = {
  readonly getPool: (_1:tickDayDataEntity) => Promise<poolEntity>; 
  readonly getTick: (_1:tickDayDataEntity) => Promise<tickEntity>; 
  readonly set: (_1:tickDayDataEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_DecreaseLiquidityEvent_tickHourDataEntityHandlerContext = {
  readonly getTick: (_1:tickHourDataEntity) => tickEntity; 
  readonly getPool: (_1:tickHourDataEntity) => poolEntity; 
  readonly set: (_1:tickHourDataEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_DecreaseLiquidityEvent_tickHourDataEntityHandlerContextAsync = {
  readonly getTick: (_1:tickHourDataEntity) => Promise<tickEntity>; 
  readonly getPool: (_1:tickHourDataEntity) => Promise<poolEntity>; 
  readonly set: (_1:tickHourDataEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_DecreaseLiquidityEvent_tokenEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | tokenEntity); 
  readonly set: (_1:tokenEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_DecreaseLiquidityEvent_tokenEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | tokenEntity)>; 
  readonly set: (_1:tokenEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_DecreaseLiquidityEvent_tokenDayDataEntityHandlerContext = {
  readonly getToken: (_1:tokenDayDataEntity) => tokenEntity; 
  readonly set: (_1:tokenDayDataEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_DecreaseLiquidityEvent_tokenDayDataEntityHandlerContextAsync = {
  readonly getToken: (_1:tokenDayDataEntity) => Promise<tokenEntity>; 
  readonly set: (_1:tokenDayDataEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_DecreaseLiquidityEvent_tokenHourDataEntityHandlerContext = {
  readonly getToken: (_1:tokenHourDataEntity) => tokenEntity; 
  readonly set: (_1:tokenHourDataEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_DecreaseLiquidityEvent_tokenHourDataEntityHandlerContextAsync = {
  readonly getToken: (_1:tokenHourDataEntity) => Promise<tokenEntity>; 
  readonly set: (_1:tokenHourDataEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_DecreaseLiquidityEvent_tokenPoolWhitelistEntityHandlerContext = {
  readonly getToken: (_1:tokenPoolWhitelistEntity) => tokenEntity; 
  readonly getPool: (_1:tokenPoolWhitelistEntity) => poolEntity; 
  readonly set: (_1:tokenPoolWhitelistEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_DecreaseLiquidityEvent_tokenPoolWhitelistEntityHandlerContextAsync = {
  readonly getToken: (_1:tokenPoolWhitelistEntity) => Promise<tokenEntity>; 
  readonly getPool: (_1:tokenPoolWhitelistEntity) => Promise<poolEntity>; 
  readonly set: (_1:tokenPoolWhitelistEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_DecreaseLiquidityEvent_transactionEntityHandlerContext = { readonly set: (_1:transactionEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_DecreaseLiquidityEvent_transactionEntityHandlerContextAsync = { readonly set: (_1:transactionEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_DecreaseLiquidityEvent_uniswapDayDataEntityHandlerContext = { readonly set: (_1:uniswapDayDataEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_DecreaseLiquidityEvent_uniswapDayDataEntityHandlerContextAsync = { readonly set: (_1:uniswapDayDataEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_DecreaseLiquidityEvent_handlerContext = {
  readonly log: Logs_userLogger; 
  readonly Bundle: NonfungiblePositionManagerContract_DecreaseLiquidityEvent_bundleEntityHandlerContext; 
  readonly Burn: NonfungiblePositionManagerContract_DecreaseLiquidityEvent_burnEntityHandlerContext; 
  readonly Collect: NonfungiblePositionManagerContract_DecreaseLiquidityEvent_collectEntityHandlerContext; 
  readonly Factory: NonfungiblePositionManagerContract_DecreaseLiquidityEvent_factoryEntityHandlerContext; 
  readonly Flash: NonfungiblePositionManagerContract_DecreaseLiquidityEvent_flashEntityHandlerContext; 
  readonly Mint: NonfungiblePositionManagerContract_DecreaseLiquidityEvent_mintEntityHandlerContext; 
  readonly Pool: NonfungiblePositionManagerContract_DecreaseLiquidityEvent_poolEntityHandlerContext; 
  readonly PoolDayData: NonfungiblePositionManagerContract_DecreaseLiquidityEvent_poolDayDataEntityHandlerContext; 
  readonly PoolHourData: NonfungiblePositionManagerContract_DecreaseLiquidityEvent_poolHourDataEntityHandlerContext; 
  readonly Position: NonfungiblePositionManagerContract_DecreaseLiquidityEvent_positionEntityHandlerContext; 
  readonly PositionSnapshot: NonfungiblePositionManagerContract_DecreaseLiquidityEvent_positionSnapshotEntityHandlerContext; 
  readonly Swap: NonfungiblePositionManagerContract_DecreaseLiquidityEvent_swapEntityHandlerContext; 
  readonly Tick: NonfungiblePositionManagerContract_DecreaseLiquidityEvent_tickEntityHandlerContext; 
  readonly TickDayData: NonfungiblePositionManagerContract_DecreaseLiquidityEvent_tickDayDataEntityHandlerContext; 
  readonly TickHourData: NonfungiblePositionManagerContract_DecreaseLiquidityEvent_tickHourDataEntityHandlerContext; 
  readonly Token: NonfungiblePositionManagerContract_DecreaseLiquidityEvent_tokenEntityHandlerContext; 
  readonly TokenDayData: NonfungiblePositionManagerContract_DecreaseLiquidityEvent_tokenDayDataEntityHandlerContext; 
  readonly TokenHourData: NonfungiblePositionManagerContract_DecreaseLiquidityEvent_tokenHourDataEntityHandlerContext; 
  readonly TokenPoolWhitelist: NonfungiblePositionManagerContract_DecreaseLiquidityEvent_tokenPoolWhitelistEntityHandlerContext; 
  readonly Transaction: NonfungiblePositionManagerContract_DecreaseLiquidityEvent_transactionEntityHandlerContext; 
  readonly UniswapDayData: NonfungiblePositionManagerContract_DecreaseLiquidityEvent_uniswapDayDataEntityHandlerContext
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_DecreaseLiquidityEvent_handlerContextAsync = {
  readonly log: Logs_userLogger; 
  readonly Bundle: NonfungiblePositionManagerContract_DecreaseLiquidityEvent_bundleEntityHandlerContextAsync; 
  readonly Burn: NonfungiblePositionManagerContract_DecreaseLiquidityEvent_burnEntityHandlerContextAsync; 
  readonly Collect: NonfungiblePositionManagerContract_DecreaseLiquidityEvent_collectEntityHandlerContextAsync; 
  readonly Factory: NonfungiblePositionManagerContract_DecreaseLiquidityEvent_factoryEntityHandlerContextAsync; 
  readonly Flash: NonfungiblePositionManagerContract_DecreaseLiquidityEvent_flashEntityHandlerContextAsync; 
  readonly Mint: NonfungiblePositionManagerContract_DecreaseLiquidityEvent_mintEntityHandlerContextAsync; 
  readonly Pool: NonfungiblePositionManagerContract_DecreaseLiquidityEvent_poolEntityHandlerContextAsync; 
  readonly PoolDayData: NonfungiblePositionManagerContract_DecreaseLiquidityEvent_poolDayDataEntityHandlerContextAsync; 
  readonly PoolHourData: NonfungiblePositionManagerContract_DecreaseLiquidityEvent_poolHourDataEntityHandlerContextAsync; 
  readonly Position: NonfungiblePositionManagerContract_DecreaseLiquidityEvent_positionEntityHandlerContextAsync; 
  readonly PositionSnapshot: NonfungiblePositionManagerContract_DecreaseLiquidityEvent_positionSnapshotEntityHandlerContextAsync; 
  readonly Swap: NonfungiblePositionManagerContract_DecreaseLiquidityEvent_swapEntityHandlerContextAsync; 
  readonly Tick: NonfungiblePositionManagerContract_DecreaseLiquidityEvent_tickEntityHandlerContextAsync; 
  readonly TickDayData: NonfungiblePositionManagerContract_DecreaseLiquidityEvent_tickDayDataEntityHandlerContextAsync; 
  readonly TickHourData: NonfungiblePositionManagerContract_DecreaseLiquidityEvent_tickHourDataEntityHandlerContextAsync; 
  readonly Token: NonfungiblePositionManagerContract_DecreaseLiquidityEvent_tokenEntityHandlerContextAsync; 
  readonly TokenDayData: NonfungiblePositionManagerContract_DecreaseLiquidityEvent_tokenDayDataEntityHandlerContextAsync; 
  readonly TokenHourData: NonfungiblePositionManagerContract_DecreaseLiquidityEvent_tokenHourDataEntityHandlerContextAsync; 
  readonly TokenPoolWhitelist: NonfungiblePositionManagerContract_DecreaseLiquidityEvent_tokenPoolWhitelistEntityHandlerContextAsync; 
  readonly Transaction: NonfungiblePositionManagerContract_DecreaseLiquidityEvent_transactionEntityHandlerContextAsync; 
  readonly UniswapDayData: NonfungiblePositionManagerContract_DecreaseLiquidityEvent_uniswapDayDataEntityHandlerContextAsync
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_DecreaseLiquidityEvent_positionEntityLoaderContext = { readonly load: (_1:id, _2:{ readonly loaders?: positionLoaderConfig }) => void };

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_DecreaseLiquidityEvent_positionSnapshotEntityLoaderContext = { readonly load: (_1:id, _2:{ readonly loaders?: positionSnapshotLoaderConfig }) => void };

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_DecreaseLiquidityEvent_tokenEntityLoaderContext = { readonly load: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_DecreaseLiquidityEvent_contractRegistrations = {
  readonly addFactory: (_1:Ethers_ethAddress) => void; 
  readonly addNonfungiblePositionManager: (_1:Ethers_ethAddress) => void; 
  readonly addPool: (_1:Ethers_ethAddress) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_DecreaseLiquidityEvent_loaderContext = {
  readonly log: Logs_userLogger; 
  readonly contractRegistration: NonfungiblePositionManagerContract_DecreaseLiquidityEvent_contractRegistrations; 
  readonly Position: NonfungiblePositionManagerContract_DecreaseLiquidityEvent_positionEntityLoaderContext; 
  readonly PositionSnapshot: NonfungiblePositionManagerContract_DecreaseLiquidityEvent_positionSnapshotEntityLoaderContext; 
  readonly Token: NonfungiblePositionManagerContract_DecreaseLiquidityEvent_tokenEntityLoaderContext
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_TransferEvent_eventArgs = {
  readonly from: Ethers_ethAddress; 
  readonly to: Ethers_ethAddress; 
  readonly tokenId: Ethers_BigInt_t
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_TransferEvent_log = eventLog<NonfungiblePositionManagerContract_TransferEvent_eventArgs>;
export type NonfungiblePositionManagerContract_Transfer_EventLog = NonfungiblePositionManagerContract_TransferEvent_log;

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_TransferEvent_bundleEntityHandlerContext = { readonly set: (_1:bundleEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_TransferEvent_bundleEntityHandlerContextAsync = { readonly set: (_1:bundleEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_TransferEvent_burnEntityHandlerContext = {
  readonly getTransaction: (_1:burnEntity) => transactionEntity; 
  readonly getToken0: (_1:burnEntity) => tokenEntity; 
  readonly getPool: (_1:burnEntity) => poolEntity; 
  readonly getToken1: (_1:burnEntity) => tokenEntity; 
  readonly set: (_1:burnEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_TransferEvent_burnEntityHandlerContextAsync = {
  readonly getTransaction: (_1:burnEntity) => Promise<transactionEntity>; 
  readonly getToken0: (_1:burnEntity) => Promise<tokenEntity>; 
  readonly getPool: (_1:burnEntity) => Promise<poolEntity>; 
  readonly getToken1: (_1:burnEntity) => Promise<tokenEntity>; 
  readonly set: (_1:burnEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_TransferEvent_collectEntityHandlerContext = {
  readonly getTransaction: (_1:collectEntity) => transactionEntity; 
  readonly getPool: (_1:collectEntity) => poolEntity; 
  readonly set: (_1:collectEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_TransferEvent_collectEntityHandlerContextAsync = {
  readonly getTransaction: (_1:collectEntity) => Promise<transactionEntity>; 
  readonly getPool: (_1:collectEntity) => Promise<poolEntity>; 
  readonly set: (_1:collectEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_TransferEvent_factoryEntityHandlerContext = { readonly set: (_1:factoryEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_TransferEvent_factoryEntityHandlerContextAsync = { readonly set: (_1:factoryEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_TransferEvent_flashEntityHandlerContext = {
  readonly getPool: (_1:flashEntity) => poolEntity; 
  readonly getTransaction: (_1:flashEntity) => transactionEntity; 
  readonly set: (_1:flashEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_TransferEvent_flashEntityHandlerContextAsync = {
  readonly getPool: (_1:flashEntity) => Promise<poolEntity>; 
  readonly getTransaction: (_1:flashEntity) => Promise<transactionEntity>; 
  readonly set: (_1:flashEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_TransferEvent_mintEntityHandlerContext = {
  readonly getToken0: (_1:mintEntity) => tokenEntity; 
  readonly getTransaction: (_1:mintEntity) => transactionEntity; 
  readonly getPool: (_1:mintEntity) => poolEntity; 
  readonly getToken1: (_1:mintEntity) => tokenEntity; 
  readonly set: (_1:mintEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_TransferEvent_mintEntityHandlerContextAsync = {
  readonly getToken0: (_1:mintEntity) => Promise<tokenEntity>; 
  readonly getTransaction: (_1:mintEntity) => Promise<transactionEntity>; 
  readonly getPool: (_1:mintEntity) => Promise<poolEntity>; 
  readonly getToken1: (_1:mintEntity) => Promise<tokenEntity>; 
  readonly set: (_1:mintEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_TransferEvent_poolEntityHandlerContext = {
  readonly getToken1: (_1:poolEntity) => tokenEntity; 
  readonly getToken0: (_1:poolEntity) => tokenEntity; 
  readonly set: (_1:poolEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_TransferEvent_poolEntityHandlerContextAsync = {
  readonly getToken1: (_1:poolEntity) => Promise<tokenEntity>; 
  readonly getToken0: (_1:poolEntity) => Promise<tokenEntity>; 
  readonly set: (_1:poolEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_TransferEvent_poolDayDataEntityHandlerContext = {
  readonly getPool: (_1:poolDayDataEntity) => poolEntity; 
  readonly set: (_1:poolDayDataEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_TransferEvent_poolDayDataEntityHandlerContextAsync = {
  readonly getPool: (_1:poolDayDataEntity) => Promise<poolEntity>; 
  readonly set: (_1:poolDayDataEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_TransferEvent_poolHourDataEntityHandlerContext = {
  readonly getPool: (_1:poolHourDataEntity) => poolEntity; 
  readonly set: (_1:poolHourDataEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_TransferEvent_poolHourDataEntityHandlerContextAsync = {
  readonly getPool: (_1:poolHourDataEntity) => Promise<poolEntity>; 
  readonly set: (_1:poolHourDataEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_TransferEvent_positionEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | positionEntity); 
  readonly getToken1: (_1:positionEntity) => tokenEntity; 
  readonly getToken0: (_1:positionEntity) => tokenEntity; 
  readonly getTickLower: (_1:positionEntity) => tickEntity; 
  readonly getTransaction: (_1:positionEntity) => transactionEntity; 
  readonly getPool: (_1:positionEntity) => poolEntity; 
  readonly getTickUpper: (_1:positionEntity) => tickEntity; 
  readonly set: (_1:positionEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_TransferEvent_positionEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | positionEntity)>; 
  readonly getToken1: (_1:positionEntity) => Promise<tokenEntity>; 
  readonly getToken0: (_1:positionEntity) => Promise<tokenEntity>; 
  readonly getTickLower: (_1:positionEntity) => Promise<tickEntity>; 
  readonly getTransaction: (_1:positionEntity) => Promise<transactionEntity>; 
  readonly getPool: (_1:positionEntity) => Promise<poolEntity>; 
  readonly getTickUpper: (_1:positionEntity) => Promise<tickEntity>; 
  readonly set: (_1:positionEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_TransferEvent_positionSnapshotEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | positionSnapshotEntity); 
  readonly getPool: (_1:positionSnapshotEntity) => poolEntity; 
  readonly getPosition: (_1:positionSnapshotEntity) => positionEntity; 
  readonly getTransaction: (_1:positionSnapshotEntity) => transactionEntity; 
  readonly set: (_1:positionSnapshotEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_TransferEvent_positionSnapshotEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | positionSnapshotEntity)>; 
  readonly getPool: (_1:positionSnapshotEntity) => Promise<poolEntity>; 
  readonly getPosition: (_1:positionSnapshotEntity) => Promise<positionEntity>; 
  readonly getTransaction: (_1:positionSnapshotEntity) => Promise<transactionEntity>; 
  readonly set: (_1:positionSnapshotEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_TransferEvent_swapEntityHandlerContext = {
  readonly getTick: (_1:swapEntity) => tickEntity; 
  readonly getTransaction: (_1:swapEntity) => transactionEntity; 
  readonly getToken1: (_1:swapEntity) => tokenEntity; 
  readonly getToken0: (_1:swapEntity) => tokenEntity; 
  readonly getPool: (_1:swapEntity) => poolEntity; 
  readonly set: (_1:swapEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_TransferEvent_swapEntityHandlerContextAsync = {
  readonly getTick: (_1:swapEntity) => Promise<tickEntity>; 
  readonly getTransaction: (_1:swapEntity) => Promise<transactionEntity>; 
  readonly getToken1: (_1:swapEntity) => Promise<tokenEntity>; 
  readonly getToken0: (_1:swapEntity) => Promise<tokenEntity>; 
  readonly getPool: (_1:swapEntity) => Promise<poolEntity>; 
  readonly set: (_1:swapEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_TransferEvent_tickEntityHandlerContext = {
  readonly getPool: (_1:tickEntity) => poolEntity; 
  readonly set: (_1:tickEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_TransferEvent_tickEntityHandlerContextAsync = {
  readonly getPool: (_1:tickEntity) => Promise<poolEntity>; 
  readonly set: (_1:tickEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_TransferEvent_tickDayDataEntityHandlerContext = {
  readonly getPool: (_1:tickDayDataEntity) => poolEntity; 
  readonly getTick: (_1:tickDayDataEntity) => tickEntity; 
  readonly set: (_1:tickDayDataEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_TransferEvent_tickDayDataEntityHandlerContextAsync = {
  readonly getPool: (_1:tickDayDataEntity) => Promise<poolEntity>; 
  readonly getTick: (_1:tickDayDataEntity) => Promise<tickEntity>; 
  readonly set: (_1:tickDayDataEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_TransferEvent_tickHourDataEntityHandlerContext = {
  readonly getTick: (_1:tickHourDataEntity) => tickEntity; 
  readonly getPool: (_1:tickHourDataEntity) => poolEntity; 
  readonly set: (_1:tickHourDataEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_TransferEvent_tickHourDataEntityHandlerContextAsync = {
  readonly getTick: (_1:tickHourDataEntity) => Promise<tickEntity>; 
  readonly getPool: (_1:tickHourDataEntity) => Promise<poolEntity>; 
  readonly set: (_1:tickHourDataEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_TransferEvent_tokenEntityHandlerContext = { readonly set: (_1:tokenEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_TransferEvent_tokenEntityHandlerContextAsync = { readonly set: (_1:tokenEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_TransferEvent_tokenDayDataEntityHandlerContext = {
  readonly getToken: (_1:tokenDayDataEntity) => tokenEntity; 
  readonly set: (_1:tokenDayDataEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_TransferEvent_tokenDayDataEntityHandlerContextAsync = {
  readonly getToken: (_1:tokenDayDataEntity) => Promise<tokenEntity>; 
  readonly set: (_1:tokenDayDataEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_TransferEvent_tokenHourDataEntityHandlerContext = {
  readonly getToken: (_1:tokenHourDataEntity) => tokenEntity; 
  readonly set: (_1:tokenHourDataEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_TransferEvent_tokenHourDataEntityHandlerContextAsync = {
  readonly getToken: (_1:tokenHourDataEntity) => Promise<tokenEntity>; 
  readonly set: (_1:tokenHourDataEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_TransferEvent_tokenPoolWhitelistEntityHandlerContext = {
  readonly getToken: (_1:tokenPoolWhitelistEntity) => tokenEntity; 
  readonly getPool: (_1:tokenPoolWhitelistEntity) => poolEntity; 
  readonly set: (_1:tokenPoolWhitelistEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_TransferEvent_tokenPoolWhitelistEntityHandlerContextAsync = {
  readonly getToken: (_1:tokenPoolWhitelistEntity) => Promise<tokenEntity>; 
  readonly getPool: (_1:tokenPoolWhitelistEntity) => Promise<poolEntity>; 
  readonly set: (_1:tokenPoolWhitelistEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_TransferEvent_transactionEntityHandlerContext = { readonly set: (_1:transactionEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_TransferEvent_transactionEntityHandlerContextAsync = { readonly set: (_1:transactionEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_TransferEvent_uniswapDayDataEntityHandlerContext = { readonly set: (_1:uniswapDayDataEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_TransferEvent_uniswapDayDataEntityHandlerContextAsync = { readonly set: (_1:uniswapDayDataEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_TransferEvent_handlerContext = {
  readonly log: Logs_userLogger; 
  readonly Bundle: NonfungiblePositionManagerContract_TransferEvent_bundleEntityHandlerContext; 
  readonly Burn: NonfungiblePositionManagerContract_TransferEvent_burnEntityHandlerContext; 
  readonly Collect: NonfungiblePositionManagerContract_TransferEvent_collectEntityHandlerContext; 
  readonly Factory: NonfungiblePositionManagerContract_TransferEvent_factoryEntityHandlerContext; 
  readonly Flash: NonfungiblePositionManagerContract_TransferEvent_flashEntityHandlerContext; 
  readonly Mint: NonfungiblePositionManagerContract_TransferEvent_mintEntityHandlerContext; 
  readonly Pool: NonfungiblePositionManagerContract_TransferEvent_poolEntityHandlerContext; 
  readonly PoolDayData: NonfungiblePositionManagerContract_TransferEvent_poolDayDataEntityHandlerContext; 
  readonly PoolHourData: NonfungiblePositionManagerContract_TransferEvent_poolHourDataEntityHandlerContext; 
  readonly Position: NonfungiblePositionManagerContract_TransferEvent_positionEntityHandlerContext; 
  readonly PositionSnapshot: NonfungiblePositionManagerContract_TransferEvent_positionSnapshotEntityHandlerContext; 
  readonly Swap: NonfungiblePositionManagerContract_TransferEvent_swapEntityHandlerContext; 
  readonly Tick: NonfungiblePositionManagerContract_TransferEvent_tickEntityHandlerContext; 
  readonly TickDayData: NonfungiblePositionManagerContract_TransferEvent_tickDayDataEntityHandlerContext; 
  readonly TickHourData: NonfungiblePositionManagerContract_TransferEvent_tickHourDataEntityHandlerContext; 
  readonly Token: NonfungiblePositionManagerContract_TransferEvent_tokenEntityHandlerContext; 
  readonly TokenDayData: NonfungiblePositionManagerContract_TransferEvent_tokenDayDataEntityHandlerContext; 
  readonly TokenHourData: NonfungiblePositionManagerContract_TransferEvent_tokenHourDataEntityHandlerContext; 
  readonly TokenPoolWhitelist: NonfungiblePositionManagerContract_TransferEvent_tokenPoolWhitelistEntityHandlerContext; 
  readonly Transaction: NonfungiblePositionManagerContract_TransferEvent_transactionEntityHandlerContext; 
  readonly UniswapDayData: NonfungiblePositionManagerContract_TransferEvent_uniswapDayDataEntityHandlerContext
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_TransferEvent_handlerContextAsync = {
  readonly log: Logs_userLogger; 
  readonly Bundle: NonfungiblePositionManagerContract_TransferEvent_bundleEntityHandlerContextAsync; 
  readonly Burn: NonfungiblePositionManagerContract_TransferEvent_burnEntityHandlerContextAsync; 
  readonly Collect: NonfungiblePositionManagerContract_TransferEvent_collectEntityHandlerContextAsync; 
  readonly Factory: NonfungiblePositionManagerContract_TransferEvent_factoryEntityHandlerContextAsync; 
  readonly Flash: NonfungiblePositionManagerContract_TransferEvent_flashEntityHandlerContextAsync; 
  readonly Mint: NonfungiblePositionManagerContract_TransferEvent_mintEntityHandlerContextAsync; 
  readonly Pool: NonfungiblePositionManagerContract_TransferEvent_poolEntityHandlerContextAsync; 
  readonly PoolDayData: NonfungiblePositionManagerContract_TransferEvent_poolDayDataEntityHandlerContextAsync; 
  readonly PoolHourData: NonfungiblePositionManagerContract_TransferEvent_poolHourDataEntityHandlerContextAsync; 
  readonly Position: NonfungiblePositionManagerContract_TransferEvent_positionEntityHandlerContextAsync; 
  readonly PositionSnapshot: NonfungiblePositionManagerContract_TransferEvent_positionSnapshotEntityHandlerContextAsync; 
  readonly Swap: NonfungiblePositionManagerContract_TransferEvent_swapEntityHandlerContextAsync; 
  readonly Tick: NonfungiblePositionManagerContract_TransferEvent_tickEntityHandlerContextAsync; 
  readonly TickDayData: NonfungiblePositionManagerContract_TransferEvent_tickDayDataEntityHandlerContextAsync; 
  readonly TickHourData: NonfungiblePositionManagerContract_TransferEvent_tickHourDataEntityHandlerContextAsync; 
  readonly Token: NonfungiblePositionManagerContract_TransferEvent_tokenEntityHandlerContextAsync; 
  readonly TokenDayData: NonfungiblePositionManagerContract_TransferEvent_tokenDayDataEntityHandlerContextAsync; 
  readonly TokenHourData: NonfungiblePositionManagerContract_TransferEvent_tokenHourDataEntityHandlerContextAsync; 
  readonly TokenPoolWhitelist: NonfungiblePositionManagerContract_TransferEvent_tokenPoolWhitelistEntityHandlerContextAsync; 
  readonly Transaction: NonfungiblePositionManagerContract_TransferEvent_transactionEntityHandlerContextAsync; 
  readonly UniswapDayData: NonfungiblePositionManagerContract_TransferEvent_uniswapDayDataEntityHandlerContextAsync
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_TransferEvent_positionEntityLoaderContext = { readonly load: (_1:id, _2:{ readonly loaders?: positionLoaderConfig }) => void };

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_TransferEvent_positionSnapshotEntityLoaderContext = { readonly load: (_1:id, _2:{ readonly loaders?: positionSnapshotLoaderConfig }) => void };

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_TransferEvent_contractRegistrations = {
  readonly addFactory: (_1:Ethers_ethAddress) => void; 
  readonly addNonfungiblePositionManager: (_1:Ethers_ethAddress) => void; 
  readonly addPool: (_1:Ethers_ethAddress) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManagerContract_TransferEvent_loaderContext = {
  readonly log: Logs_userLogger; 
  readonly contractRegistration: NonfungiblePositionManagerContract_TransferEvent_contractRegistrations; 
  readonly Position: NonfungiblePositionManagerContract_TransferEvent_positionEntityLoaderContext; 
  readonly PositionSnapshot: NonfungiblePositionManagerContract_TransferEvent_positionSnapshotEntityLoaderContext
};

// tslint:disable-next-line:interface-over-type-literal
export type PoolContract_SwapEvent_eventArgs = {
  readonly sender: Ethers_ethAddress; 
  readonly recipient: Ethers_ethAddress; 
  readonly amount0: Ethers_BigInt_t; 
  readonly amount1: Ethers_BigInt_t; 
  readonly sqrtPriceX96: Ethers_BigInt_t; 
  readonly liquidity: Ethers_BigInt_t; 
  readonly tick: Ethers_BigInt_t
};

// tslint:disable-next-line:interface-over-type-literal
export type PoolContract_SwapEvent_log = eventLog<PoolContract_SwapEvent_eventArgs>;
export type PoolContract_Swap_EventLog = PoolContract_SwapEvent_log;

// tslint:disable-next-line:interface-over-type-literal
export type PoolContract_SwapEvent_bundleEntityHandlerContext = { readonly set: (_1:bundleEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type PoolContract_SwapEvent_bundleEntityHandlerContextAsync = { readonly set: (_1:bundleEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type PoolContract_SwapEvent_burnEntityHandlerContext = {
  readonly getTransaction: (_1:burnEntity) => transactionEntity; 
  readonly getToken0: (_1:burnEntity) => tokenEntity; 
  readonly getPool: (_1:burnEntity) => poolEntity; 
  readonly getToken1: (_1:burnEntity) => tokenEntity; 
  readonly set: (_1:burnEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type PoolContract_SwapEvent_burnEntityHandlerContextAsync = {
  readonly getTransaction: (_1:burnEntity) => Promise<transactionEntity>; 
  readonly getToken0: (_1:burnEntity) => Promise<tokenEntity>; 
  readonly getPool: (_1:burnEntity) => Promise<poolEntity>; 
  readonly getToken1: (_1:burnEntity) => Promise<tokenEntity>; 
  readonly set: (_1:burnEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type PoolContract_SwapEvent_collectEntityHandlerContext = {
  readonly getTransaction: (_1:collectEntity) => transactionEntity; 
  readonly getPool: (_1:collectEntity) => poolEntity; 
  readonly set: (_1:collectEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type PoolContract_SwapEvent_collectEntityHandlerContextAsync = {
  readonly getTransaction: (_1:collectEntity) => Promise<transactionEntity>; 
  readonly getPool: (_1:collectEntity) => Promise<poolEntity>; 
  readonly set: (_1:collectEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type PoolContract_SwapEvent_factoryEntityHandlerContext = { readonly set: (_1:factoryEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type PoolContract_SwapEvent_factoryEntityHandlerContextAsync = { readonly set: (_1:factoryEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type PoolContract_SwapEvent_flashEntityHandlerContext = {
  readonly getPool: (_1:flashEntity) => poolEntity; 
  readonly getTransaction: (_1:flashEntity) => transactionEntity; 
  readonly set: (_1:flashEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type PoolContract_SwapEvent_flashEntityHandlerContextAsync = {
  readonly getPool: (_1:flashEntity) => Promise<poolEntity>; 
  readonly getTransaction: (_1:flashEntity) => Promise<transactionEntity>; 
  readonly set: (_1:flashEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type PoolContract_SwapEvent_mintEntityHandlerContext = {
  readonly getToken0: (_1:mintEntity) => tokenEntity; 
  readonly getTransaction: (_1:mintEntity) => transactionEntity; 
  readonly getPool: (_1:mintEntity) => poolEntity; 
  readonly getToken1: (_1:mintEntity) => tokenEntity; 
  readonly set: (_1:mintEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type PoolContract_SwapEvent_mintEntityHandlerContextAsync = {
  readonly getToken0: (_1:mintEntity) => Promise<tokenEntity>; 
  readonly getTransaction: (_1:mintEntity) => Promise<transactionEntity>; 
  readonly getPool: (_1:mintEntity) => Promise<poolEntity>; 
  readonly getToken1: (_1:mintEntity) => Promise<tokenEntity>; 
  readonly set: (_1:mintEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type PoolContract_SwapEvent_poolEntityHandlerContext = {
  readonly getToken1: (_1:poolEntity) => tokenEntity; 
  readonly getToken0: (_1:poolEntity) => tokenEntity; 
  readonly set: (_1:poolEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type PoolContract_SwapEvent_poolEntityHandlerContextAsync = {
  readonly getToken1: (_1:poolEntity) => Promise<tokenEntity>; 
  readonly getToken0: (_1:poolEntity) => Promise<tokenEntity>; 
  readonly set: (_1:poolEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type PoolContract_SwapEvent_poolDayDataEntityHandlerContext = {
  readonly getPool: (_1:poolDayDataEntity) => poolEntity; 
  readonly set: (_1:poolDayDataEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type PoolContract_SwapEvent_poolDayDataEntityHandlerContextAsync = {
  readonly getPool: (_1:poolDayDataEntity) => Promise<poolEntity>; 
  readonly set: (_1:poolDayDataEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type PoolContract_SwapEvent_poolHourDataEntityHandlerContext = {
  readonly getPool: (_1:poolHourDataEntity) => poolEntity; 
  readonly set: (_1:poolHourDataEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type PoolContract_SwapEvent_poolHourDataEntityHandlerContextAsync = {
  readonly getPool: (_1:poolHourDataEntity) => Promise<poolEntity>; 
  readonly set: (_1:poolHourDataEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type PoolContract_SwapEvent_positionEntityHandlerContext = {
  readonly getToken1: (_1:positionEntity) => tokenEntity; 
  readonly getToken0: (_1:positionEntity) => tokenEntity; 
  readonly getTickLower: (_1:positionEntity) => tickEntity; 
  readonly getTransaction: (_1:positionEntity) => transactionEntity; 
  readonly getPool: (_1:positionEntity) => poolEntity; 
  readonly getTickUpper: (_1:positionEntity) => tickEntity; 
  readonly set: (_1:positionEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type PoolContract_SwapEvent_positionEntityHandlerContextAsync = {
  readonly getToken1: (_1:positionEntity) => Promise<tokenEntity>; 
  readonly getToken0: (_1:positionEntity) => Promise<tokenEntity>; 
  readonly getTickLower: (_1:positionEntity) => Promise<tickEntity>; 
  readonly getTransaction: (_1:positionEntity) => Promise<transactionEntity>; 
  readonly getPool: (_1:positionEntity) => Promise<poolEntity>; 
  readonly getTickUpper: (_1:positionEntity) => Promise<tickEntity>; 
  readonly set: (_1:positionEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type PoolContract_SwapEvent_positionSnapshotEntityHandlerContext = {
  readonly getPool: (_1:positionSnapshotEntity) => poolEntity; 
  readonly getPosition: (_1:positionSnapshotEntity) => positionEntity; 
  readonly getTransaction: (_1:positionSnapshotEntity) => transactionEntity; 
  readonly set: (_1:positionSnapshotEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type PoolContract_SwapEvent_positionSnapshotEntityHandlerContextAsync = {
  readonly getPool: (_1:positionSnapshotEntity) => Promise<poolEntity>; 
  readonly getPosition: (_1:positionSnapshotEntity) => Promise<positionEntity>; 
  readonly getTransaction: (_1:positionSnapshotEntity) => Promise<transactionEntity>; 
  readonly set: (_1:positionSnapshotEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type PoolContract_SwapEvent_swapEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | swapEntity); 
  readonly getTick: (_1:swapEntity) => tickEntity; 
  readonly getTransaction: (_1:swapEntity) => transactionEntity; 
  readonly getToken1: (_1:swapEntity) => tokenEntity; 
  readonly getToken0: (_1:swapEntity) => tokenEntity; 
  readonly getPool: (_1:swapEntity) => poolEntity; 
  readonly set: (_1:swapEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type PoolContract_SwapEvent_swapEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | swapEntity)>; 
  readonly getTick: (_1:swapEntity) => Promise<tickEntity>; 
  readonly getTransaction: (_1:swapEntity) => Promise<transactionEntity>; 
  readonly getToken1: (_1:swapEntity) => Promise<tokenEntity>; 
  readonly getToken0: (_1:swapEntity) => Promise<tokenEntity>; 
  readonly getPool: (_1:swapEntity) => Promise<poolEntity>; 
  readonly set: (_1:swapEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type PoolContract_SwapEvent_tickEntityHandlerContext = {
  readonly getPool: (_1:tickEntity) => poolEntity; 
  readonly set: (_1:tickEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type PoolContract_SwapEvent_tickEntityHandlerContextAsync = {
  readonly getPool: (_1:tickEntity) => Promise<poolEntity>; 
  readonly set: (_1:tickEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type PoolContract_SwapEvent_tickDayDataEntityHandlerContext = {
  readonly getPool: (_1:tickDayDataEntity) => poolEntity; 
  readonly getTick: (_1:tickDayDataEntity) => tickEntity; 
  readonly set: (_1:tickDayDataEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type PoolContract_SwapEvent_tickDayDataEntityHandlerContextAsync = {
  readonly getPool: (_1:tickDayDataEntity) => Promise<poolEntity>; 
  readonly getTick: (_1:tickDayDataEntity) => Promise<tickEntity>; 
  readonly set: (_1:tickDayDataEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type PoolContract_SwapEvent_tickHourDataEntityHandlerContext = {
  readonly getTick: (_1:tickHourDataEntity) => tickEntity; 
  readonly getPool: (_1:tickHourDataEntity) => poolEntity; 
  readonly set: (_1:tickHourDataEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type PoolContract_SwapEvent_tickHourDataEntityHandlerContextAsync = {
  readonly getTick: (_1:tickHourDataEntity) => Promise<tickEntity>; 
  readonly getPool: (_1:tickHourDataEntity) => Promise<poolEntity>; 
  readonly set: (_1:tickHourDataEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type PoolContract_SwapEvent_tokenEntityHandlerContext = {
  readonly get: (_1:id) => (undefined | tokenEntity); 
  readonly set: (_1:tokenEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type PoolContract_SwapEvent_tokenEntityHandlerContextAsync = {
  readonly get: (_1:id) => Promise<(undefined | tokenEntity)>; 
  readonly set: (_1:tokenEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type PoolContract_SwapEvent_tokenDayDataEntityHandlerContext = {
  readonly getToken: (_1:tokenDayDataEntity) => tokenEntity; 
  readonly set: (_1:tokenDayDataEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type PoolContract_SwapEvent_tokenDayDataEntityHandlerContextAsync = {
  readonly getToken: (_1:tokenDayDataEntity) => Promise<tokenEntity>; 
  readonly set: (_1:tokenDayDataEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type PoolContract_SwapEvent_tokenHourDataEntityHandlerContext = {
  readonly getToken: (_1:tokenHourDataEntity) => tokenEntity; 
  readonly set: (_1:tokenHourDataEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type PoolContract_SwapEvent_tokenHourDataEntityHandlerContextAsync = {
  readonly getToken: (_1:tokenHourDataEntity) => Promise<tokenEntity>; 
  readonly set: (_1:tokenHourDataEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type PoolContract_SwapEvent_tokenPoolWhitelistEntityHandlerContext = {
  readonly getToken: (_1:tokenPoolWhitelistEntity) => tokenEntity; 
  readonly getPool: (_1:tokenPoolWhitelistEntity) => poolEntity; 
  readonly set: (_1:tokenPoolWhitelistEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type PoolContract_SwapEvent_tokenPoolWhitelistEntityHandlerContextAsync = {
  readonly getToken: (_1:tokenPoolWhitelistEntity) => Promise<tokenEntity>; 
  readonly getPool: (_1:tokenPoolWhitelistEntity) => Promise<poolEntity>; 
  readonly set: (_1:tokenPoolWhitelistEntity) => void; 
  readonly delete: (_1:id) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type PoolContract_SwapEvent_transactionEntityHandlerContext = { readonly set: (_1:transactionEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type PoolContract_SwapEvent_transactionEntityHandlerContextAsync = { readonly set: (_1:transactionEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type PoolContract_SwapEvent_uniswapDayDataEntityHandlerContext = { readonly set: (_1:uniswapDayDataEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type PoolContract_SwapEvent_uniswapDayDataEntityHandlerContextAsync = { readonly set: (_1:uniswapDayDataEntity) => void; readonly delete: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type PoolContract_SwapEvent_handlerContext = {
  readonly log: Logs_userLogger; 
  readonly Bundle: PoolContract_SwapEvent_bundleEntityHandlerContext; 
  readonly Burn: PoolContract_SwapEvent_burnEntityHandlerContext; 
  readonly Collect: PoolContract_SwapEvent_collectEntityHandlerContext; 
  readonly Factory: PoolContract_SwapEvent_factoryEntityHandlerContext; 
  readonly Flash: PoolContract_SwapEvent_flashEntityHandlerContext; 
  readonly Mint: PoolContract_SwapEvent_mintEntityHandlerContext; 
  readonly Pool: PoolContract_SwapEvent_poolEntityHandlerContext; 
  readonly PoolDayData: PoolContract_SwapEvent_poolDayDataEntityHandlerContext; 
  readonly PoolHourData: PoolContract_SwapEvent_poolHourDataEntityHandlerContext; 
  readonly Position: PoolContract_SwapEvent_positionEntityHandlerContext; 
  readonly PositionSnapshot: PoolContract_SwapEvent_positionSnapshotEntityHandlerContext; 
  readonly Swap: PoolContract_SwapEvent_swapEntityHandlerContext; 
  readonly Tick: PoolContract_SwapEvent_tickEntityHandlerContext; 
  readonly TickDayData: PoolContract_SwapEvent_tickDayDataEntityHandlerContext; 
  readonly TickHourData: PoolContract_SwapEvent_tickHourDataEntityHandlerContext; 
  readonly Token: PoolContract_SwapEvent_tokenEntityHandlerContext; 
  readonly TokenDayData: PoolContract_SwapEvent_tokenDayDataEntityHandlerContext; 
  readonly TokenHourData: PoolContract_SwapEvent_tokenHourDataEntityHandlerContext; 
  readonly TokenPoolWhitelist: PoolContract_SwapEvent_tokenPoolWhitelistEntityHandlerContext; 
  readonly Transaction: PoolContract_SwapEvent_transactionEntityHandlerContext; 
  readonly UniswapDayData: PoolContract_SwapEvent_uniswapDayDataEntityHandlerContext
};

// tslint:disable-next-line:interface-over-type-literal
export type PoolContract_SwapEvent_handlerContextAsync = {
  readonly log: Logs_userLogger; 
  readonly Bundle: PoolContract_SwapEvent_bundleEntityHandlerContextAsync; 
  readonly Burn: PoolContract_SwapEvent_burnEntityHandlerContextAsync; 
  readonly Collect: PoolContract_SwapEvent_collectEntityHandlerContextAsync; 
  readonly Factory: PoolContract_SwapEvent_factoryEntityHandlerContextAsync; 
  readonly Flash: PoolContract_SwapEvent_flashEntityHandlerContextAsync; 
  readonly Mint: PoolContract_SwapEvent_mintEntityHandlerContextAsync; 
  readonly Pool: PoolContract_SwapEvent_poolEntityHandlerContextAsync; 
  readonly PoolDayData: PoolContract_SwapEvent_poolDayDataEntityHandlerContextAsync; 
  readonly PoolHourData: PoolContract_SwapEvent_poolHourDataEntityHandlerContextAsync; 
  readonly Position: PoolContract_SwapEvent_positionEntityHandlerContextAsync; 
  readonly PositionSnapshot: PoolContract_SwapEvent_positionSnapshotEntityHandlerContextAsync; 
  readonly Swap: PoolContract_SwapEvent_swapEntityHandlerContextAsync; 
  readonly Tick: PoolContract_SwapEvent_tickEntityHandlerContextAsync; 
  readonly TickDayData: PoolContract_SwapEvent_tickDayDataEntityHandlerContextAsync; 
  readonly TickHourData: PoolContract_SwapEvent_tickHourDataEntityHandlerContextAsync; 
  readonly Token: PoolContract_SwapEvent_tokenEntityHandlerContextAsync; 
  readonly TokenDayData: PoolContract_SwapEvent_tokenDayDataEntityHandlerContextAsync; 
  readonly TokenHourData: PoolContract_SwapEvent_tokenHourDataEntityHandlerContextAsync; 
  readonly TokenPoolWhitelist: PoolContract_SwapEvent_tokenPoolWhitelistEntityHandlerContextAsync; 
  readonly Transaction: PoolContract_SwapEvent_transactionEntityHandlerContextAsync; 
  readonly UniswapDayData: PoolContract_SwapEvent_uniswapDayDataEntityHandlerContextAsync
};

// tslint:disable-next-line:interface-over-type-literal
export type PoolContract_SwapEvent_swapEntityLoaderContext = { readonly load: (_1:id, _2:{ readonly loaders?: swapLoaderConfig }) => void };

// tslint:disable-next-line:interface-over-type-literal
export type PoolContract_SwapEvent_tokenEntityLoaderContext = { readonly load: (_1:id) => void };

// tslint:disable-next-line:interface-over-type-literal
export type PoolContract_SwapEvent_contractRegistrations = {
  readonly addFactory: (_1:Ethers_ethAddress) => void; 
  readonly addNonfungiblePositionManager: (_1:Ethers_ethAddress) => void; 
  readonly addPool: (_1:Ethers_ethAddress) => void
};

// tslint:disable-next-line:interface-over-type-literal
export type PoolContract_SwapEvent_loaderContext = {
  readonly log: Logs_userLogger; 
  readonly contractRegistration: PoolContract_SwapEvent_contractRegistrations; 
  readonly Swap: PoolContract_SwapEvent_swapEntityLoaderContext; 
  readonly Token: PoolContract_SwapEvent_tokenEntityLoaderContext
};

// tslint:disable-next-line:interface-over-type-literal
export type chainId = number;
