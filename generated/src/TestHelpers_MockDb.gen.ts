/* TypeScript file generated from TestHelpers_MockDb.res by genType. */
/* eslint-disable import/first */


// @ts-ignore: Implicit any on import
const TestHelpers_MockDbBS = require('./TestHelpers_MockDb.bs');

import type {EventSyncState_eventSyncState as DbFunctions_EventSyncState_eventSyncState} from './DbFunctions.gen';

import type {InMemoryStore_dynamicContractRegistryKey as IO_InMemoryStore_dynamicContractRegistryKey} from './IO.gen';

import type {InMemoryStore_rawEventsKey as IO_InMemoryStore_rawEventsKey} from './IO.gen';

import type {InMemoryStore_t as IO_InMemoryStore_t} from './IO.gen';

import type {bundleEntity as Types_bundleEntity} from './Types.gen';

import type {burnEntity as Types_burnEntity} from './Types.gen';

import type {chainId as Types_chainId} from './Types.gen';

import type {collectEntity as Types_collectEntity} from './Types.gen';

import type {dynamicContractRegistryEntity as Types_dynamicContractRegistryEntity} from './Types.gen';

import type {factoryEntity as Types_factoryEntity} from './Types.gen';

import type {flashEntity as Types_flashEntity} from './Types.gen';

import type {mintEntity as Types_mintEntity} from './Types.gen';

import type {poolDayDataEntity as Types_poolDayDataEntity} from './Types.gen';

import type {poolEntity as Types_poolEntity} from './Types.gen';

import type {poolHourDataEntity as Types_poolHourDataEntity} from './Types.gen';

import type {positionEntity as Types_positionEntity} from './Types.gen';

import type {positionSnapshotEntity as Types_positionSnapshotEntity} from './Types.gen';

import type {rawEventsEntity as Types_rawEventsEntity} from './Types.gen';

import type {swapEntity as Types_swapEntity} from './Types.gen';

import type {tickDayDataEntity as Types_tickDayDataEntity} from './Types.gen';

import type {tickEntity as Types_tickEntity} from './Types.gen';

import type {tickHourDataEntity as Types_tickHourDataEntity} from './Types.gen';

import type {tokenDayDataEntity as Types_tokenDayDataEntity} from './Types.gen';

import type {tokenEntity as Types_tokenEntity} from './Types.gen';

import type {tokenHourDataEntity as Types_tokenHourDataEntity} from './Types.gen';

import type {tokenPoolWhitelistEntity as Types_tokenPoolWhitelistEntity} from './Types.gen';

import type {transactionEntity as Types_transactionEntity} from './Types.gen';

import type {uniswapDayDataEntity as Types_uniswapDayDataEntity} from './Types.gen';

// tslint:disable-next-line:interface-over-type-literal
export type t = {
  readonly __dbInternal__: IO_InMemoryStore_t; 
  readonly entities: entities; 
  readonly rawEvents: storeOperations<IO_InMemoryStore_rawEventsKey,Types_rawEventsEntity>; 
  readonly eventSyncState: storeOperations<Types_chainId,DbFunctions_EventSyncState_eventSyncState>; 
  readonly dynamicContractRegistry: storeOperations<IO_InMemoryStore_dynamicContractRegistryKey,Types_dynamicContractRegistryEntity>
};

// tslint:disable-next-line:interface-over-type-literal
export type entities = {
  readonly Bundle: entityStoreOperations<Types_bundleEntity>; 
  readonly Burn: entityStoreOperations<Types_burnEntity>; 
  readonly Collect: entityStoreOperations<Types_collectEntity>; 
  readonly Factory: entityStoreOperations<Types_factoryEntity>; 
  readonly Flash: entityStoreOperations<Types_flashEntity>; 
  readonly Mint: entityStoreOperations<Types_mintEntity>; 
  readonly Pool: entityStoreOperations<Types_poolEntity>; 
  readonly PoolDayData: entityStoreOperations<Types_poolDayDataEntity>; 
  readonly PoolHourData: entityStoreOperations<Types_poolHourDataEntity>; 
  readonly Position: entityStoreOperations<Types_positionEntity>; 
  readonly PositionSnapshot: entityStoreOperations<Types_positionSnapshotEntity>; 
  readonly Swap: entityStoreOperations<Types_swapEntity>; 
  readonly Tick: entityStoreOperations<Types_tickEntity>; 
  readonly TickDayData: entityStoreOperations<Types_tickDayDataEntity>; 
  readonly TickHourData: entityStoreOperations<Types_tickHourDataEntity>; 
  readonly Token: entityStoreOperations<Types_tokenEntity>; 
  readonly TokenDayData: entityStoreOperations<Types_tokenDayDataEntity>; 
  readonly TokenHourData: entityStoreOperations<Types_tokenHourDataEntity>; 
  readonly TokenPoolWhitelist: entityStoreOperations<Types_tokenPoolWhitelistEntity>; 
  readonly Transaction: entityStoreOperations<Types_transactionEntity>; 
  readonly UniswapDayData: entityStoreOperations<Types_uniswapDayDataEntity>
};

// tslint:disable-next-line:interface-over-type-literal
export type entityStoreOperations<entity> = storeOperations<string,entity>;

// tslint:disable-next-line:interface-over-type-literal
export type storeOperations<entityKey,entity> = {
  readonly getAll: () => entity[]; 
  readonly get: (_1:entityKey) => (undefined | entity); 
  readonly set: (_1:entity) => t; 
  readonly delete: (_1:entityKey) => t
};

export const createMockDb: () => t = TestHelpers_MockDbBS.createMockDb;
