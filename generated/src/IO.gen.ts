/* TypeScript file generated from IO.res by genType. */
/* eslint-disable import/first */


import type {EventSyncState_eventSyncState as DbFunctions_EventSyncState_eventSyncState} from './DbFunctions.gen';

import type {bundleEntity as Types_bundleEntity} from './Types.gen';

import type {burnEntity as Types_burnEntity} from './Types.gen';

import type {collectEntity as Types_collectEntity} from './Types.gen';

import type {dynamicContractRegistryEntity as Types_dynamicContractRegistryEntity} from './Types.gen';

import type {ethAddress as Ethers_ethAddress} from '../src/bindings/Ethers.gen';

import type {factoryEntity as Types_factoryEntity} from './Types.gen';

import type {flashEntity as Types_flashEntity} from './Types.gen';

import type {inMemoryStoreRow as Types_inMemoryStoreRow} from './Types.gen';

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
export type InMemoryStore_stringHasher<val> = (_1:val) => string;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_storeState<entity,entityKey> = { readonly dict: {[id: string]: Types_inMemoryStoreRow<entity>}; readonly hasher: InMemoryStore_stringHasher<entityKey> };

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_EventSyncState_value = DbFunctions_EventSyncState_eventSyncState;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_EventSyncState_key = number;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_EventSyncState_t = InMemoryStore_storeState<InMemoryStore_EventSyncState_value,InMemoryStore_EventSyncState_key>;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_rawEventsKey = { readonly chainId: number; readonly eventId: string };

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_RawEvents_value = Types_rawEventsEntity;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_RawEvents_key = InMemoryStore_rawEventsKey;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_RawEvents_t = InMemoryStore_storeState<InMemoryStore_RawEvents_value,InMemoryStore_RawEvents_key>;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_dynamicContractRegistryKey = { readonly chainId: number; readonly contractAddress: Ethers_ethAddress };

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_DynamicContractRegistry_value = Types_dynamicContractRegistryEntity;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_DynamicContractRegistry_key = InMemoryStore_dynamicContractRegistryKey;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_DynamicContractRegistry_t = InMemoryStore_storeState<InMemoryStore_DynamicContractRegistry_value,InMemoryStore_DynamicContractRegistry_key>;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Bundle_value = Types_bundleEntity;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Bundle_key = string;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Bundle_t = InMemoryStore_storeState<InMemoryStore_Bundle_value,InMemoryStore_Bundle_key>;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Burn_value = Types_burnEntity;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Burn_key = string;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Burn_t = InMemoryStore_storeState<InMemoryStore_Burn_value,InMemoryStore_Burn_key>;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Collect_value = Types_collectEntity;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Collect_key = string;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Collect_t = InMemoryStore_storeState<InMemoryStore_Collect_value,InMemoryStore_Collect_key>;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Factory_value = Types_factoryEntity;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Factory_key = string;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Factory_t = InMemoryStore_storeState<InMemoryStore_Factory_value,InMemoryStore_Factory_key>;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Flash_value = Types_flashEntity;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Flash_key = string;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Flash_t = InMemoryStore_storeState<InMemoryStore_Flash_value,InMemoryStore_Flash_key>;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Mint_value = Types_mintEntity;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Mint_key = string;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Mint_t = InMemoryStore_storeState<InMemoryStore_Mint_value,InMemoryStore_Mint_key>;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Pool_value = Types_poolEntity;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Pool_key = string;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Pool_t = InMemoryStore_storeState<InMemoryStore_Pool_value,InMemoryStore_Pool_key>;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_PoolDayData_value = Types_poolDayDataEntity;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_PoolDayData_key = string;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_PoolDayData_t = InMemoryStore_storeState<InMemoryStore_PoolDayData_value,InMemoryStore_PoolDayData_key>;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_PoolHourData_value = Types_poolHourDataEntity;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_PoolHourData_key = string;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_PoolHourData_t = InMemoryStore_storeState<InMemoryStore_PoolHourData_value,InMemoryStore_PoolHourData_key>;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Position_value = Types_positionEntity;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Position_key = string;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Position_t = InMemoryStore_storeState<InMemoryStore_Position_value,InMemoryStore_Position_key>;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_PositionSnapshot_value = Types_positionSnapshotEntity;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_PositionSnapshot_key = string;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_PositionSnapshot_t = InMemoryStore_storeState<InMemoryStore_PositionSnapshot_value,InMemoryStore_PositionSnapshot_key>;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Swap_value = Types_swapEntity;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Swap_key = string;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Swap_t = InMemoryStore_storeState<InMemoryStore_Swap_value,InMemoryStore_Swap_key>;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Tick_value = Types_tickEntity;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Tick_key = string;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Tick_t = InMemoryStore_storeState<InMemoryStore_Tick_value,InMemoryStore_Tick_key>;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_TickDayData_value = Types_tickDayDataEntity;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_TickDayData_key = string;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_TickDayData_t = InMemoryStore_storeState<InMemoryStore_TickDayData_value,InMemoryStore_TickDayData_key>;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_TickHourData_value = Types_tickHourDataEntity;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_TickHourData_key = string;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_TickHourData_t = InMemoryStore_storeState<InMemoryStore_TickHourData_value,InMemoryStore_TickHourData_key>;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Token_value = Types_tokenEntity;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Token_key = string;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Token_t = InMemoryStore_storeState<InMemoryStore_Token_value,InMemoryStore_Token_key>;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_TokenDayData_value = Types_tokenDayDataEntity;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_TokenDayData_key = string;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_TokenDayData_t = InMemoryStore_storeState<InMemoryStore_TokenDayData_value,InMemoryStore_TokenDayData_key>;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_TokenHourData_value = Types_tokenHourDataEntity;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_TokenHourData_key = string;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_TokenHourData_t = InMemoryStore_storeState<InMemoryStore_TokenHourData_value,InMemoryStore_TokenHourData_key>;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_TokenPoolWhitelist_value = Types_tokenPoolWhitelistEntity;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_TokenPoolWhitelist_key = string;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_TokenPoolWhitelist_t = InMemoryStore_storeState<InMemoryStore_TokenPoolWhitelist_value,InMemoryStore_TokenPoolWhitelist_key>;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Transaction_value = Types_transactionEntity;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Transaction_key = string;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_Transaction_t = InMemoryStore_storeState<InMemoryStore_Transaction_value,InMemoryStore_Transaction_key>;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_UniswapDayData_value = Types_uniswapDayDataEntity;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_UniswapDayData_key = string;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_UniswapDayData_t = InMemoryStore_storeState<InMemoryStore_UniswapDayData_value,InMemoryStore_UniswapDayData_key>;

// tslint:disable-next-line:interface-over-type-literal
export type InMemoryStore_t = {
  readonly eventSyncState: InMemoryStore_EventSyncState_t; 
  readonly rawEvents: InMemoryStore_RawEvents_t; 
  readonly dynamicContractRegistry: InMemoryStore_DynamicContractRegistry_t; 
  readonly bundle: InMemoryStore_Bundle_t; 
  readonly burn: InMemoryStore_Burn_t; 
  readonly collect: InMemoryStore_Collect_t; 
  readonly factory: InMemoryStore_Factory_t; 
  readonly flash: InMemoryStore_Flash_t; 
  readonly mint: InMemoryStore_Mint_t; 
  readonly pool: InMemoryStore_Pool_t; 
  readonly poolDayData: InMemoryStore_PoolDayData_t; 
  readonly poolHourData: InMemoryStore_PoolHourData_t; 
  readonly position: InMemoryStore_Position_t; 
  readonly positionSnapshot: InMemoryStore_PositionSnapshot_t; 
  readonly swap: InMemoryStore_Swap_t; 
  readonly tick: InMemoryStore_Tick_t; 
  readonly tickDayData: InMemoryStore_TickDayData_t; 
  readonly tickHourData: InMemoryStore_TickHourData_t; 
  readonly token: InMemoryStore_Token_t; 
  readonly tokenDayData: InMemoryStore_TokenDayData_t; 
  readonly tokenHourData: InMemoryStore_TokenHourData_t; 
  readonly tokenPoolWhitelist: InMemoryStore_TokenPoolWhitelist_t; 
  readonly transaction: InMemoryStore_Transaction_t; 
  readonly uniswapDayData: InMemoryStore_UniswapDayData_t
};
