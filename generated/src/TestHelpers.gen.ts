/* TypeScript file generated from TestHelpers.res by genType. */
/* eslint-disable import/first */


// @ts-ignore: Implicit any on import
const TestHelpersBS = require('./TestHelpers.bs');

import type {BigInt_t as Ethers_BigInt_t} from '../src/bindings/Ethers.gen';

import type {FactoryContract_PoolCreatedEvent_eventArgs as Types_FactoryContract_PoolCreatedEvent_eventArgs} from './Types.gen';

import type {NonfungiblePositionManagerContract_DecreaseLiquidityEvent_eventArgs as Types_NonfungiblePositionManagerContract_DecreaseLiquidityEvent_eventArgs} from './Types.gen';

import type {NonfungiblePositionManagerContract_IncreaseLiquidityEvent_eventArgs as Types_NonfungiblePositionManagerContract_IncreaseLiquidityEvent_eventArgs} from './Types.gen';

import type {NonfungiblePositionManagerContract_TransferEvent_eventArgs as Types_NonfungiblePositionManagerContract_TransferEvent_eventArgs} from './Types.gen';

import type {PoolContract_SwapEvent_eventArgs as Types_PoolContract_SwapEvent_eventArgs} from './Types.gen';

import type {ethAddress as Ethers_ethAddress} from '../src/bindings/Ethers.gen';

import type {eventLog as Types_eventLog} from './Types.gen';

import type {t as TestHelpers_MockDb_t} from './TestHelpers_MockDb.gen';

// tslint:disable-next-line:interface-over-type-literal
export type EventFunctions_eventProcessorArgs<eventArgs> = {
  readonly event: Types_eventLog<eventArgs>; 
  readonly mockDb: TestHelpers_MockDb_t; 
  readonly chainId?: number
};

// tslint:disable-next-line:interface-over-type-literal
export type EventFunctions_mockEventData = {
  readonly blockNumber?: number; 
  readonly blockTimestamp?: number; 
  readonly blockHash?: string; 
  readonly chainId?: number; 
  readonly srcAddress?: Ethers_ethAddress; 
  readonly transactionHash?: string; 
  readonly transactionIndex?: number; 
  readonly txOrigin?: (undefined | Ethers_ethAddress); 
  readonly logIndex?: number
};

// tslint:disable-next-line:interface-over-type-literal
export type Factory_PoolCreated_createMockArgs = {
  readonly token0?: Ethers_ethAddress; 
  readonly token1?: Ethers_ethAddress; 
  readonly fee?: Ethers_BigInt_t; 
  readonly tickSpacing?: Ethers_BigInt_t; 
  readonly pool?: Ethers_ethAddress; 
  readonly mockEventData?: EventFunctions_mockEventData
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManager_IncreaseLiquidity_createMockArgs = {
  readonly tokenId?: Ethers_BigInt_t; 
  readonly liquidity?: Ethers_BigInt_t; 
  readonly amount0?: Ethers_BigInt_t; 
  readonly amount1?: Ethers_BigInt_t; 
  readonly mockEventData?: EventFunctions_mockEventData
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManager_DecreaseLiquidity_createMockArgs = {
  readonly tokenId?: Ethers_BigInt_t; 
  readonly liquidity?: Ethers_BigInt_t; 
  readonly amount0?: Ethers_BigInt_t; 
  readonly amount1?: Ethers_BigInt_t; 
  readonly mockEventData?: EventFunctions_mockEventData
};

// tslint:disable-next-line:interface-over-type-literal
export type NonfungiblePositionManager_Transfer_createMockArgs = {
  readonly from?: Ethers_ethAddress; 
  readonly to?: Ethers_ethAddress; 
  readonly tokenId?: Ethers_BigInt_t; 
  readonly mockEventData?: EventFunctions_mockEventData
};

// tslint:disable-next-line:interface-over-type-literal
export type Pool_Swap_createMockArgs = {
  readonly sender?: Ethers_ethAddress; 
  readonly recipient?: Ethers_ethAddress; 
  readonly amount0?: Ethers_BigInt_t; 
  readonly amount1?: Ethers_BigInt_t; 
  readonly sqrtPriceX96?: Ethers_BigInt_t; 
  readonly liquidity?: Ethers_BigInt_t; 
  readonly tick?: Ethers_BigInt_t; 
  readonly mockEventData?: EventFunctions_mockEventData
};

export const MockDb_createMockDb: () => TestHelpers_MockDb_t = TestHelpersBS.MockDb.createMockDb;

export const Factory_PoolCreated_processEvent: (_1:EventFunctions_eventProcessorArgs<Types_FactoryContract_PoolCreatedEvent_eventArgs>) => TestHelpers_MockDb_t = TestHelpersBS.Factory.PoolCreated.processEvent;

export const Factory_PoolCreated_processEventAsync: (_1:EventFunctions_eventProcessorArgs<Types_FactoryContract_PoolCreatedEvent_eventArgs>) => Promise<TestHelpers_MockDb_t> = TestHelpersBS.Factory.PoolCreated.processEventAsync;

export const Factory_PoolCreated_createMockEvent: (args:Factory_PoolCreated_createMockArgs) => Types_eventLog<Types_FactoryContract_PoolCreatedEvent_eventArgs> = TestHelpersBS.Factory.PoolCreated.createMockEvent;

export const NonfungiblePositionManager_IncreaseLiquidity_processEvent: (_1:EventFunctions_eventProcessorArgs<Types_NonfungiblePositionManagerContract_IncreaseLiquidityEvent_eventArgs>) => TestHelpers_MockDb_t = TestHelpersBS.NonfungiblePositionManager.IncreaseLiquidity.processEvent;

export const NonfungiblePositionManager_IncreaseLiquidity_processEventAsync: (_1:EventFunctions_eventProcessorArgs<Types_NonfungiblePositionManagerContract_IncreaseLiquidityEvent_eventArgs>) => Promise<TestHelpers_MockDb_t> = TestHelpersBS.NonfungiblePositionManager.IncreaseLiquidity.processEventAsync;

export const NonfungiblePositionManager_IncreaseLiquidity_createMockEvent: (args:NonfungiblePositionManager_IncreaseLiquidity_createMockArgs) => Types_eventLog<Types_NonfungiblePositionManagerContract_IncreaseLiquidityEvent_eventArgs> = TestHelpersBS.NonfungiblePositionManager.IncreaseLiquidity.createMockEvent;

export const NonfungiblePositionManager_DecreaseLiquidity_processEvent: (_1:EventFunctions_eventProcessorArgs<Types_NonfungiblePositionManagerContract_DecreaseLiquidityEvent_eventArgs>) => TestHelpers_MockDb_t = TestHelpersBS.NonfungiblePositionManager.DecreaseLiquidity.processEvent;

export const NonfungiblePositionManager_DecreaseLiquidity_processEventAsync: (_1:EventFunctions_eventProcessorArgs<Types_NonfungiblePositionManagerContract_DecreaseLiquidityEvent_eventArgs>) => Promise<TestHelpers_MockDb_t> = TestHelpersBS.NonfungiblePositionManager.DecreaseLiquidity.processEventAsync;

export const NonfungiblePositionManager_DecreaseLiquidity_createMockEvent: (args:NonfungiblePositionManager_DecreaseLiquidity_createMockArgs) => Types_eventLog<Types_NonfungiblePositionManagerContract_DecreaseLiquidityEvent_eventArgs> = TestHelpersBS.NonfungiblePositionManager.DecreaseLiquidity.createMockEvent;

export const NonfungiblePositionManager_Transfer_processEvent: (_1:EventFunctions_eventProcessorArgs<Types_NonfungiblePositionManagerContract_TransferEvent_eventArgs>) => TestHelpers_MockDb_t = TestHelpersBS.NonfungiblePositionManager.Transfer.processEvent;

export const NonfungiblePositionManager_Transfer_processEventAsync: (_1:EventFunctions_eventProcessorArgs<Types_NonfungiblePositionManagerContract_TransferEvent_eventArgs>) => Promise<TestHelpers_MockDb_t> = TestHelpersBS.NonfungiblePositionManager.Transfer.processEventAsync;

export const NonfungiblePositionManager_Transfer_createMockEvent: (args:NonfungiblePositionManager_Transfer_createMockArgs) => Types_eventLog<Types_NonfungiblePositionManagerContract_TransferEvent_eventArgs> = TestHelpersBS.NonfungiblePositionManager.Transfer.createMockEvent;

export const Pool_Swap_processEvent: (_1:EventFunctions_eventProcessorArgs<Types_PoolContract_SwapEvent_eventArgs>) => TestHelpers_MockDb_t = TestHelpersBS.Pool.Swap.processEvent;

export const Pool_Swap_processEventAsync: (_1:EventFunctions_eventProcessorArgs<Types_PoolContract_SwapEvent_eventArgs>) => Promise<TestHelpers_MockDb_t> = TestHelpersBS.Pool.Swap.processEventAsync;

export const Pool_Swap_createMockEvent: (args:Pool_Swap_createMockArgs) => Types_eventLog<Types_PoolContract_SwapEvent_eventArgs> = TestHelpersBS.Pool.Swap.createMockEvent;

export const Factory: { PoolCreated: {
  processEvent: (_1:EventFunctions_eventProcessorArgs<Types_FactoryContract_PoolCreatedEvent_eventArgs>) => TestHelpers_MockDb_t; 
  processEventAsync: (_1:EventFunctions_eventProcessorArgs<Types_FactoryContract_PoolCreatedEvent_eventArgs>) => Promise<TestHelpers_MockDb_t>; 
  createMockEvent: (args:Factory_PoolCreated_createMockArgs) => Types_eventLog<Types_FactoryContract_PoolCreatedEvent_eventArgs>
} } = TestHelpersBS.Factory

export const Pool: { Swap: {
  processEvent: (_1:EventFunctions_eventProcessorArgs<Types_PoolContract_SwapEvent_eventArgs>) => TestHelpers_MockDb_t; 
  processEventAsync: (_1:EventFunctions_eventProcessorArgs<Types_PoolContract_SwapEvent_eventArgs>) => Promise<TestHelpers_MockDb_t>; 
  createMockEvent: (args:Pool_Swap_createMockArgs) => Types_eventLog<Types_PoolContract_SwapEvent_eventArgs>
} } = TestHelpersBS.Pool

export const NonfungiblePositionManager: {
  IncreaseLiquidity: {
    processEvent: (_1:EventFunctions_eventProcessorArgs<Types_NonfungiblePositionManagerContract_IncreaseLiquidityEvent_eventArgs>) => TestHelpers_MockDb_t; 
    processEventAsync: (_1:EventFunctions_eventProcessorArgs<Types_NonfungiblePositionManagerContract_IncreaseLiquidityEvent_eventArgs>) => Promise<TestHelpers_MockDb_t>; 
    createMockEvent: (args:NonfungiblePositionManager_IncreaseLiquidity_createMockArgs) => Types_eventLog<Types_NonfungiblePositionManagerContract_IncreaseLiquidityEvent_eventArgs>
  }; 
  Transfer: {
    processEvent: (_1:EventFunctions_eventProcessorArgs<Types_NonfungiblePositionManagerContract_TransferEvent_eventArgs>) => TestHelpers_MockDb_t; 
    processEventAsync: (_1:EventFunctions_eventProcessorArgs<Types_NonfungiblePositionManagerContract_TransferEvent_eventArgs>) => Promise<TestHelpers_MockDb_t>; 
    createMockEvent: (args:NonfungiblePositionManager_Transfer_createMockArgs) => Types_eventLog<Types_NonfungiblePositionManagerContract_TransferEvent_eventArgs>
  }; 
  DecreaseLiquidity: {
    processEvent: (_1:EventFunctions_eventProcessorArgs<Types_NonfungiblePositionManagerContract_DecreaseLiquidityEvent_eventArgs>) => TestHelpers_MockDb_t; 
    processEventAsync: (_1:EventFunctions_eventProcessorArgs<Types_NonfungiblePositionManagerContract_DecreaseLiquidityEvent_eventArgs>) => Promise<TestHelpers_MockDb_t>; 
    createMockEvent: (args:NonfungiblePositionManager_DecreaseLiquidity_createMockArgs) => Types_eventLog<Types_NonfungiblePositionManagerContract_DecreaseLiquidityEvent_eventArgs>
  }
} = TestHelpersBS.NonfungiblePositionManager

export const MockDb: { createMockDb: () => TestHelpers_MockDb_t } = TestHelpersBS.MockDb
