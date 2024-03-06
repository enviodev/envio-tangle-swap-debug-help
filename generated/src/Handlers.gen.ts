/* TypeScript file generated from Handlers.res by genType. */
/* eslint-disable import/first */


// @ts-ignore: Implicit any on import
const Curry = require('rescript/lib/js/curry.js');

// @ts-ignore: Implicit any on import
const HandlersBS = require('./Handlers.bs');

import type {FactoryContract_PoolCreatedEvent_eventArgs as Types_FactoryContract_PoolCreatedEvent_eventArgs} from './Types.gen';

import type {FactoryContract_PoolCreatedEvent_handlerContextAsync as Types_FactoryContract_PoolCreatedEvent_handlerContextAsync} from './Types.gen';

import type {FactoryContract_PoolCreatedEvent_handlerContext as Types_FactoryContract_PoolCreatedEvent_handlerContext} from './Types.gen';

import type {FactoryContract_PoolCreatedEvent_loaderContext as Types_FactoryContract_PoolCreatedEvent_loaderContext} from './Types.gen';

import type {NonfungiblePositionManagerContract_DecreaseLiquidityEvent_eventArgs as Types_NonfungiblePositionManagerContract_DecreaseLiquidityEvent_eventArgs} from './Types.gen';

import type {NonfungiblePositionManagerContract_DecreaseLiquidityEvent_handlerContextAsync as Types_NonfungiblePositionManagerContract_DecreaseLiquidityEvent_handlerContextAsync} from './Types.gen';

import type {NonfungiblePositionManagerContract_DecreaseLiquidityEvent_handlerContext as Types_NonfungiblePositionManagerContract_DecreaseLiquidityEvent_handlerContext} from './Types.gen';

import type {NonfungiblePositionManagerContract_DecreaseLiquidityEvent_loaderContext as Types_NonfungiblePositionManagerContract_DecreaseLiquidityEvent_loaderContext} from './Types.gen';

import type {NonfungiblePositionManagerContract_IncreaseLiquidityEvent_eventArgs as Types_NonfungiblePositionManagerContract_IncreaseLiquidityEvent_eventArgs} from './Types.gen';

import type {NonfungiblePositionManagerContract_IncreaseLiquidityEvent_handlerContextAsync as Types_NonfungiblePositionManagerContract_IncreaseLiquidityEvent_handlerContextAsync} from './Types.gen';

import type {NonfungiblePositionManagerContract_IncreaseLiquidityEvent_handlerContext as Types_NonfungiblePositionManagerContract_IncreaseLiquidityEvent_handlerContext} from './Types.gen';

import type {NonfungiblePositionManagerContract_IncreaseLiquidityEvent_loaderContext as Types_NonfungiblePositionManagerContract_IncreaseLiquidityEvent_loaderContext} from './Types.gen';

import type {NonfungiblePositionManagerContract_TransferEvent_eventArgs as Types_NonfungiblePositionManagerContract_TransferEvent_eventArgs} from './Types.gen';

import type {NonfungiblePositionManagerContract_TransferEvent_handlerContextAsync as Types_NonfungiblePositionManagerContract_TransferEvent_handlerContextAsync} from './Types.gen';

import type {NonfungiblePositionManagerContract_TransferEvent_handlerContext as Types_NonfungiblePositionManagerContract_TransferEvent_handlerContext} from './Types.gen';

import type {NonfungiblePositionManagerContract_TransferEvent_loaderContext as Types_NonfungiblePositionManagerContract_TransferEvent_loaderContext} from './Types.gen';

import type {PoolContract_SwapEvent_eventArgs as Types_PoolContract_SwapEvent_eventArgs} from './Types.gen';

import type {PoolContract_SwapEvent_handlerContextAsync as Types_PoolContract_SwapEvent_handlerContextAsync} from './Types.gen';

import type {PoolContract_SwapEvent_handlerContext as Types_PoolContract_SwapEvent_handlerContext} from './Types.gen';

import type {PoolContract_SwapEvent_loaderContext as Types_PoolContract_SwapEvent_loaderContext} from './Types.gen';

import type {eventLog as Types_eventLog} from './Types.gen';

import type {genericContextCreatorFunctions as Context_genericContextCreatorFunctions} from './Context.gen';

import type {t as SyncAsync_t} from './SyncAsync.gen';

// tslint:disable-next-line:interface-over-type-literal
export type handlerFunction<eventArgs,context,returned> = (_1:{ readonly event: Types_eventLog<eventArgs>; readonly context: context }) => returned;

// tslint:disable-next-line:interface-over-type-literal
export type handlerWithContextGetter<eventArgs,context,returned,loaderContext,handlerContextSync,handlerContextAsync> = { readonly handler: handlerFunction<eventArgs,context,returned>; readonly contextGetter: (_1:Context_genericContextCreatorFunctions<loaderContext,handlerContextSync,handlerContextAsync>) => context };

// tslint:disable-next-line:interface-over-type-literal
export type handlerWithContextGetterSyncAsync<eventArgs,loaderContext,handlerContextSync,handlerContextAsync> = SyncAsync_t<handlerWithContextGetter<eventArgs,handlerContextSync,void,loaderContext,handlerContextSync,handlerContextAsync>,handlerWithContextGetter<eventArgs,handlerContextAsync,Promise<void>,loaderContext,handlerContextSync,handlerContextAsync>>;

// tslint:disable-next-line:interface-over-type-literal
export type loader<eventArgs,loaderContext> = (_1:{ readonly event: Types_eventLog<eventArgs>; readonly context: loaderContext }) => void;

export const FactoryContract_PoolCreated_loader: (loader:loader<Types_FactoryContract_PoolCreatedEvent_eventArgs,Types_FactoryContract_PoolCreatedEvent_loaderContext>) => void = function (Arg1: any) {
  const result = HandlersBS.FactoryContract.PoolCreated.loader(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, contractRegistration:Argcontext.contractRegistration, Pool:{load:function (Arg12: any, Arg21: any) {
          const result3 = Curry._2(Argcontext.Pool.load, Arg12, Arg21.loaders);
          return result3
        }}, Factory:Argcontext.Factory, Token:Argcontext.Token, TokenPoolWhitelist:{load:function (Arg13: any, Arg22: any) {
          const result4 = Curry._2(Argcontext.TokenPoolWhitelist.load, Arg13, Arg22.loaders);
          return result4
        }}}});
      return result1
    });
  return result
};

export const FactoryContract_PoolCreated_handler: (handler:handlerFunction<Types_FactoryContract_PoolCreatedEvent_eventArgs,Types_FactoryContract_PoolCreatedEvent_handlerContext,void>) => void = function (Arg1: any) {
  const result = HandlersBS.FactoryContract.PoolCreated.handler(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, Bundle:Argcontext.Bundle, Burn:Argcontext.Burn, Collect:Argcontext.Collect, Factory:Argcontext.Factory, Flash:Argcontext.Flash, Mint:Argcontext.Mint, Pool:Argcontext.Pool, PoolDayData:Argcontext.PoolDayData, PoolHourData:Argcontext.PoolHourData, Position:Argcontext.Position, PositionSnapshot:Argcontext.PositionSnapshot, Swap:Argcontext.Swap, Tick:Argcontext.Tick, TickDayData:Argcontext.TickDayData, TickHourData:Argcontext.TickHourData, Token:Argcontext.Token, TokenDayData:Argcontext.TokenDayData, TokenHourData:Argcontext.TokenHourData, TokenPoolWhitelist:Argcontext.TokenPoolWhitelist, Transaction:Argcontext.Transaction, UniswapDayData:Argcontext.UniswapDayData}});
      return result1
    });
  return result
};

export const FactoryContract_PoolCreated_handlerAsync: (handler:handlerFunction<Types_FactoryContract_PoolCreatedEvent_eventArgs,Types_FactoryContract_PoolCreatedEvent_handlerContextAsync,Promise<void>>) => void = function (Arg1: any) {
  const result = HandlersBS.FactoryContract.PoolCreated.handlerAsync(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, Bundle:Argcontext.Bundle, Burn:Argcontext.Burn, Collect:Argcontext.Collect, Factory:Argcontext.Factory, Flash:Argcontext.Flash, Mint:Argcontext.Mint, Pool:Argcontext.Pool, PoolDayData:Argcontext.PoolDayData, PoolHourData:Argcontext.PoolHourData, Position:Argcontext.Position, PositionSnapshot:Argcontext.PositionSnapshot, Swap:Argcontext.Swap, Tick:Argcontext.Tick, TickDayData:Argcontext.TickDayData, TickHourData:Argcontext.TickHourData, Token:Argcontext.Token, TokenDayData:Argcontext.TokenDayData, TokenHourData:Argcontext.TokenHourData, TokenPoolWhitelist:Argcontext.TokenPoolWhitelist, Transaction:Argcontext.Transaction, UniswapDayData:Argcontext.UniswapDayData}});
      return result1
    });
  return result
};

export const NonfungiblePositionManagerContract_IncreaseLiquidity_loader: (loader:loader<Types_NonfungiblePositionManagerContract_IncreaseLiquidityEvent_eventArgs,Types_NonfungiblePositionManagerContract_IncreaseLiquidityEvent_loaderContext>) => void = function (Arg1: any) {
  const result = HandlersBS.NonfungiblePositionManagerContract.IncreaseLiquidity.loader(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, contractRegistration:Argcontext.contractRegistration, Position:{load:function (Arg12: any, Arg21: any) {
          const result3 = Curry._2(Argcontext.Position.load, Arg12, Arg21.loaders);
          return result3
        }}, PositionSnapshot:{load:function (Arg13: any, Arg22: any) {
          const result4 = Curry._2(Argcontext.PositionSnapshot.load, Arg13, Arg22.loaders);
          return result4
        }}, Token:Argcontext.Token}});
      return result1
    });
  return result
};

export const NonfungiblePositionManagerContract_IncreaseLiquidity_handler: (handler:handlerFunction<Types_NonfungiblePositionManagerContract_IncreaseLiquidityEvent_eventArgs,Types_NonfungiblePositionManagerContract_IncreaseLiquidityEvent_handlerContext,void>) => void = function (Arg1: any) {
  const result = HandlersBS.NonfungiblePositionManagerContract.IncreaseLiquidity.handler(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, Bundle:Argcontext.Bundle, Burn:Argcontext.Burn, Collect:Argcontext.Collect, Factory:Argcontext.Factory, Flash:Argcontext.Flash, Mint:Argcontext.Mint, Pool:Argcontext.Pool, PoolDayData:Argcontext.PoolDayData, PoolHourData:Argcontext.PoolHourData, Position:Argcontext.Position, PositionSnapshot:Argcontext.PositionSnapshot, Swap:Argcontext.Swap, Tick:Argcontext.Tick, TickDayData:Argcontext.TickDayData, TickHourData:Argcontext.TickHourData, Token:Argcontext.Token, TokenDayData:Argcontext.TokenDayData, TokenHourData:Argcontext.TokenHourData, TokenPoolWhitelist:Argcontext.TokenPoolWhitelist, Transaction:Argcontext.Transaction, UniswapDayData:Argcontext.UniswapDayData}});
      return result1
    });
  return result
};

export const NonfungiblePositionManagerContract_IncreaseLiquidity_handlerAsync: (handler:handlerFunction<Types_NonfungiblePositionManagerContract_IncreaseLiquidityEvent_eventArgs,Types_NonfungiblePositionManagerContract_IncreaseLiquidityEvent_handlerContextAsync,Promise<void>>) => void = function (Arg1: any) {
  const result = HandlersBS.NonfungiblePositionManagerContract.IncreaseLiquidity.handlerAsync(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, Bundle:Argcontext.Bundle, Burn:Argcontext.Burn, Collect:Argcontext.Collect, Factory:Argcontext.Factory, Flash:Argcontext.Flash, Mint:Argcontext.Mint, Pool:Argcontext.Pool, PoolDayData:Argcontext.PoolDayData, PoolHourData:Argcontext.PoolHourData, Position:Argcontext.Position, PositionSnapshot:Argcontext.PositionSnapshot, Swap:Argcontext.Swap, Tick:Argcontext.Tick, TickDayData:Argcontext.TickDayData, TickHourData:Argcontext.TickHourData, Token:Argcontext.Token, TokenDayData:Argcontext.TokenDayData, TokenHourData:Argcontext.TokenHourData, TokenPoolWhitelist:Argcontext.TokenPoolWhitelist, Transaction:Argcontext.Transaction, UniswapDayData:Argcontext.UniswapDayData}});
      return result1
    });
  return result
};

export const NonfungiblePositionManagerContract_DecreaseLiquidity_loader: (loader:loader<Types_NonfungiblePositionManagerContract_DecreaseLiquidityEvent_eventArgs,Types_NonfungiblePositionManagerContract_DecreaseLiquidityEvent_loaderContext>) => void = function (Arg1: any) {
  const result = HandlersBS.NonfungiblePositionManagerContract.DecreaseLiquidity.loader(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, contractRegistration:Argcontext.contractRegistration, Position:{load:function (Arg12: any, Arg21: any) {
          const result3 = Curry._2(Argcontext.Position.load, Arg12, Arg21.loaders);
          return result3
        }}, PositionSnapshot:{load:function (Arg13: any, Arg22: any) {
          const result4 = Curry._2(Argcontext.PositionSnapshot.load, Arg13, Arg22.loaders);
          return result4
        }}, Token:Argcontext.Token}});
      return result1
    });
  return result
};

export const NonfungiblePositionManagerContract_DecreaseLiquidity_handler: (handler:handlerFunction<Types_NonfungiblePositionManagerContract_DecreaseLiquidityEvent_eventArgs,Types_NonfungiblePositionManagerContract_DecreaseLiquidityEvent_handlerContext,void>) => void = function (Arg1: any) {
  const result = HandlersBS.NonfungiblePositionManagerContract.DecreaseLiquidity.handler(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, Bundle:Argcontext.Bundle, Burn:Argcontext.Burn, Collect:Argcontext.Collect, Factory:Argcontext.Factory, Flash:Argcontext.Flash, Mint:Argcontext.Mint, Pool:Argcontext.Pool, PoolDayData:Argcontext.PoolDayData, PoolHourData:Argcontext.PoolHourData, Position:Argcontext.Position, PositionSnapshot:Argcontext.PositionSnapshot, Swap:Argcontext.Swap, Tick:Argcontext.Tick, TickDayData:Argcontext.TickDayData, TickHourData:Argcontext.TickHourData, Token:Argcontext.Token, TokenDayData:Argcontext.TokenDayData, TokenHourData:Argcontext.TokenHourData, TokenPoolWhitelist:Argcontext.TokenPoolWhitelist, Transaction:Argcontext.Transaction, UniswapDayData:Argcontext.UniswapDayData}});
      return result1
    });
  return result
};

export const NonfungiblePositionManagerContract_DecreaseLiquidity_handlerAsync: (handler:handlerFunction<Types_NonfungiblePositionManagerContract_DecreaseLiquidityEvent_eventArgs,Types_NonfungiblePositionManagerContract_DecreaseLiquidityEvent_handlerContextAsync,Promise<void>>) => void = function (Arg1: any) {
  const result = HandlersBS.NonfungiblePositionManagerContract.DecreaseLiquidity.handlerAsync(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, Bundle:Argcontext.Bundle, Burn:Argcontext.Burn, Collect:Argcontext.Collect, Factory:Argcontext.Factory, Flash:Argcontext.Flash, Mint:Argcontext.Mint, Pool:Argcontext.Pool, PoolDayData:Argcontext.PoolDayData, PoolHourData:Argcontext.PoolHourData, Position:Argcontext.Position, PositionSnapshot:Argcontext.PositionSnapshot, Swap:Argcontext.Swap, Tick:Argcontext.Tick, TickDayData:Argcontext.TickDayData, TickHourData:Argcontext.TickHourData, Token:Argcontext.Token, TokenDayData:Argcontext.TokenDayData, TokenHourData:Argcontext.TokenHourData, TokenPoolWhitelist:Argcontext.TokenPoolWhitelist, Transaction:Argcontext.Transaction, UniswapDayData:Argcontext.UniswapDayData}});
      return result1
    });
  return result
};

export const NonfungiblePositionManagerContract_Transfer_loader: (loader:loader<Types_NonfungiblePositionManagerContract_TransferEvent_eventArgs,Types_NonfungiblePositionManagerContract_TransferEvent_loaderContext>) => void = function (Arg1: any) {
  const result = HandlersBS.NonfungiblePositionManagerContract.Transfer.loader(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, contractRegistration:Argcontext.contractRegistration, Position:{load:function (Arg12: any, Arg21: any) {
          const result3 = Curry._2(Argcontext.Position.load, Arg12, Arg21.loaders);
          return result3
        }}, PositionSnapshot:{load:function (Arg13: any, Arg22: any) {
          const result4 = Curry._2(Argcontext.PositionSnapshot.load, Arg13, Arg22.loaders);
          return result4
        }}}});
      return result1
    });
  return result
};

export const NonfungiblePositionManagerContract_Transfer_handler: (handler:handlerFunction<Types_NonfungiblePositionManagerContract_TransferEvent_eventArgs,Types_NonfungiblePositionManagerContract_TransferEvent_handlerContext,void>) => void = function (Arg1: any) {
  const result = HandlersBS.NonfungiblePositionManagerContract.Transfer.handler(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, Bundle:Argcontext.Bundle, Burn:Argcontext.Burn, Collect:Argcontext.Collect, Factory:Argcontext.Factory, Flash:Argcontext.Flash, Mint:Argcontext.Mint, Pool:Argcontext.Pool, PoolDayData:Argcontext.PoolDayData, PoolHourData:Argcontext.PoolHourData, Position:Argcontext.Position, PositionSnapshot:Argcontext.PositionSnapshot, Swap:Argcontext.Swap, Tick:Argcontext.Tick, TickDayData:Argcontext.TickDayData, TickHourData:Argcontext.TickHourData, Token:Argcontext.Token, TokenDayData:Argcontext.TokenDayData, TokenHourData:Argcontext.TokenHourData, TokenPoolWhitelist:Argcontext.TokenPoolWhitelist, Transaction:Argcontext.Transaction, UniswapDayData:Argcontext.UniswapDayData}});
      return result1
    });
  return result
};

export const NonfungiblePositionManagerContract_Transfer_handlerAsync: (handler:handlerFunction<Types_NonfungiblePositionManagerContract_TransferEvent_eventArgs,Types_NonfungiblePositionManagerContract_TransferEvent_handlerContextAsync,Promise<void>>) => void = function (Arg1: any) {
  const result = HandlersBS.NonfungiblePositionManagerContract.Transfer.handlerAsync(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, Bundle:Argcontext.Bundle, Burn:Argcontext.Burn, Collect:Argcontext.Collect, Factory:Argcontext.Factory, Flash:Argcontext.Flash, Mint:Argcontext.Mint, Pool:Argcontext.Pool, PoolDayData:Argcontext.PoolDayData, PoolHourData:Argcontext.PoolHourData, Position:Argcontext.Position, PositionSnapshot:Argcontext.PositionSnapshot, Swap:Argcontext.Swap, Tick:Argcontext.Tick, TickDayData:Argcontext.TickDayData, TickHourData:Argcontext.TickHourData, Token:Argcontext.Token, TokenDayData:Argcontext.TokenDayData, TokenHourData:Argcontext.TokenHourData, TokenPoolWhitelist:Argcontext.TokenPoolWhitelist, Transaction:Argcontext.Transaction, UniswapDayData:Argcontext.UniswapDayData}});
      return result1
    });
  return result
};

export const PoolContract_Swap_loader: (loader:loader<Types_PoolContract_SwapEvent_eventArgs,Types_PoolContract_SwapEvent_loaderContext>) => void = function (Arg1: any) {
  const result = HandlersBS.PoolContract.Swap.loader(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, contractRegistration:Argcontext.contractRegistration, Swap:{load:function (Arg12: any, Arg21: any) {
          const result3 = Curry._2(Argcontext.Swap.load, Arg12, Arg21.loaders);
          return result3
        }}, Token:Argcontext.Token}});
      return result1
    });
  return result
};

export const PoolContract_Swap_handler: (handler:handlerFunction<Types_PoolContract_SwapEvent_eventArgs,Types_PoolContract_SwapEvent_handlerContext,void>) => void = function (Arg1: any) {
  const result = HandlersBS.PoolContract.Swap.handler(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, Bundle:Argcontext.Bundle, Burn:Argcontext.Burn, Collect:Argcontext.Collect, Factory:Argcontext.Factory, Flash:Argcontext.Flash, Mint:Argcontext.Mint, Pool:Argcontext.Pool, PoolDayData:Argcontext.PoolDayData, PoolHourData:Argcontext.PoolHourData, Position:Argcontext.Position, PositionSnapshot:Argcontext.PositionSnapshot, Swap:Argcontext.Swap, Tick:Argcontext.Tick, TickDayData:Argcontext.TickDayData, TickHourData:Argcontext.TickHourData, Token:Argcontext.Token, TokenDayData:Argcontext.TokenDayData, TokenHourData:Argcontext.TokenHourData, TokenPoolWhitelist:Argcontext.TokenPoolWhitelist, Transaction:Argcontext.Transaction, UniswapDayData:Argcontext.UniswapDayData}});
      return result1
    });
  return result
};

export const PoolContract_Swap_handlerAsync: (handler:handlerFunction<Types_PoolContract_SwapEvent_eventArgs,Types_PoolContract_SwapEvent_handlerContextAsync,Promise<void>>) => void = function (Arg1: any) {
  const result = HandlersBS.PoolContract.Swap.handlerAsync(function (Argevent: any, Argcontext: any) {
      const result1 = Arg1({event:Argevent, context:{log:{debug:Argcontext.log.debug, info:Argcontext.log.info, warn:Argcontext.log.warn, error:Argcontext.log.error, errorWithExn:function (Arg11: any, Arg2: any) {
          const result2 = Curry._2(Argcontext.log.errorWithExn, Arg11, Arg2);
          return result2
        }}, Bundle:Argcontext.Bundle, Burn:Argcontext.Burn, Collect:Argcontext.Collect, Factory:Argcontext.Factory, Flash:Argcontext.Flash, Mint:Argcontext.Mint, Pool:Argcontext.Pool, PoolDayData:Argcontext.PoolDayData, PoolHourData:Argcontext.PoolHourData, Position:Argcontext.Position, PositionSnapshot:Argcontext.PositionSnapshot, Swap:Argcontext.Swap, Tick:Argcontext.Tick, TickDayData:Argcontext.TickDayData, TickHourData:Argcontext.TickHourData, Token:Argcontext.Token, TokenDayData:Argcontext.TokenDayData, TokenHourData:Argcontext.TokenHourData, TokenPoolWhitelist:Argcontext.TokenPoolWhitelist, Transaction:Argcontext.Transaction, UniswapDayData:Argcontext.UniswapDayData}});
      return result1
    });
  return result
};
