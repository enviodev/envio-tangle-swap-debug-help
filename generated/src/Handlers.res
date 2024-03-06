type functionRegister = Loader | Handler

let mapFunctionRegisterName = (functionRegister: functionRegister) => {
  switch functionRegister {
  | Loader => "Loader"
  | Handler => "Handler"
  }
}

// This set makes sure that the warning doesn't print for every event of a type, but rather only prints the first time.
let hasPrintedWarning = Set.make()

@genType
type handlerFunction<'eventArgs, 'context, 'returned> = (
  ~event: Types.eventLog<'eventArgs>,
  ~context: 'context,
) => 'returned

@genType
type handlerWithContextGetter<
  'eventArgs,
  'context,
  'returned,
  'loaderContext,
  'handlerContextSync,
  'handlerContextAsync,
> = {
  handler: handlerFunction<'eventArgs, 'context, 'returned>,
  contextGetter: Context.genericContextCreatorFunctions<
    'loaderContext,
    'handlerContextSync,
    'handlerContextAsync,
  > => 'context,
}

@genType
type handlerWithContextGetterSyncAsync<
  'eventArgs,
  'loaderContext,
  'handlerContextSync,
  'handlerContextAsync,
> = SyncAsync.t<
  handlerWithContextGetter<
    'eventArgs,
    'handlerContextSync,
    unit,
    'loaderContext,
    'handlerContextSync,
    'handlerContextAsync,
  >,
  handlerWithContextGetter<
    'eventArgs,
    'handlerContextAsync,
    promise<unit>,
    'loaderContext,
    'handlerContextSync,
    'handlerContextAsync,
  >,
>

@genType
type loader<'eventArgs, 'loaderContext> = (
  ~event: Types.eventLog<'eventArgs>,
  ~context: 'loaderContext,
) => unit

let getDefaultLoaderHandler: (
  ~functionRegister: functionRegister,
  ~eventName: string,
  ~event: 'a,
  ~context: 'b,
) => unit = (~functionRegister, ~eventName, ~event as _, ~context as _) => {
  let functionName = mapFunctionRegisterName(functionRegister)

  // Here we use this key to prevent flooding the users terminal with
  let repeatKey = `${eventName}-${functionName}`
  if !(hasPrintedWarning->Set.has(repeatKey)) {
    // Here are docs on the 'terminal hyperlink' formatting that I use to link to the docs: https://gist.github.com/egmontkob/eb114294efbcd5adb1944c9f3cb5feda
    Logging.warn(
      `Skipped ${eventName} in the ${functionName}, as there is no ${functionName} registered. You need to implement a ${eventName}${functionName} method in your handler file or ignore this warning if you don't intend to implement it. Here are our docs on this topic: \\u001b]8;;https://docs.envio.dev/docs/event-handlers\u0007https://docs.envio.dev/docs/event-handlers\u001b]8;;\u0007`,
    )
    let _ = hasPrintedWarning->Set.add(repeatKey)
  }
}

let getDefaultLoaderHandlerWithContextGetter = (~functionRegister, ~eventName) => SyncAsync.Sync({
  handler: getDefaultLoaderHandler(~functionRegister, ~eventName),
  contextGetter: ctx => ctx.getHandlerContextSync(),
})

module FactoryContract = {
  module PoolCreated = {
    open Types.FactoryContract.PoolCreatedEvent

    type handlerWithContextGetter = handlerWithContextGetterSyncAsync<
      eventArgs,
      loaderContext,
      handlerContext,
      handlerContextAsync,
    >

    %%private(
      let poolCreatedLoader: ref<option<loader<eventArgs, loaderContext>>> = ref(None)
      let poolCreatedHandler: ref<option<handlerWithContextGetter>> = ref(None)
    )

    @genType
    let loader = loader => {
      poolCreatedLoader := Some(loader)
    }

    @genType
    let handler = handler => {
      poolCreatedHandler := Some(Sync({handler, contextGetter: ctx => ctx.getHandlerContextSync()}))
    }

    // Silence the "this statement never returns (or has an unsound type.)" warning in the case that the user hasn't specified `isAsync` in their config file yet.
    @warning("-21") @genType
    let handlerAsync = handler => {
      poolCreatedHandler :=
        Some(Async({handler, contextGetter: ctx => ctx.getHandlerContextAsync()}))
    }

    let getLoader = () =>
      poolCreatedLoader.contents->Belt.Option.getWithDefault(
        getDefaultLoaderHandler(~eventName="PoolCreated", ~functionRegister=Loader),
      )

    let getHandler = () =>
      switch poolCreatedHandler.contents {
      | Some(handler) => handler
      | None =>
        getDefaultLoaderHandlerWithContextGetter(
          ~eventName="PoolCreated",
          ~functionRegister=Handler,
        )
      }

    let handlerIsAsync = () => getHandler()->SyncAsync.isAsync
  }
}

module NonfungiblePositionManagerContract = {
  module IncreaseLiquidity = {
    open Types.NonfungiblePositionManagerContract.IncreaseLiquidityEvent

    type handlerWithContextGetter = handlerWithContextGetterSyncAsync<
      eventArgs,
      loaderContext,
      handlerContext,
      handlerContextAsync,
    >

    %%private(
      let increaseLiquidityLoader: ref<option<loader<eventArgs, loaderContext>>> = ref(None)
      let increaseLiquidityHandler: ref<option<handlerWithContextGetter>> = ref(None)
    )

    @genType
    let loader = loader => {
      increaseLiquidityLoader := Some(loader)
    }

    @genType
    let handler = handler => {
      increaseLiquidityHandler :=
        Some(Sync({handler, contextGetter: ctx => ctx.getHandlerContextSync()}))
    }

    // Silence the "this statement never returns (or has an unsound type.)" warning in the case that the user hasn't specified `isAsync` in their config file yet.
    @warning("-21") @genType
    let handlerAsync = handler => {
      increaseLiquidityHandler :=
        Some(Async({handler, contextGetter: ctx => ctx.getHandlerContextAsync()}))
    }

    let getLoader = () =>
      increaseLiquidityLoader.contents->Belt.Option.getWithDefault(
        getDefaultLoaderHandler(~eventName="IncreaseLiquidity", ~functionRegister=Loader),
      )

    let getHandler = () =>
      switch increaseLiquidityHandler.contents {
      | Some(handler) => handler
      | None =>
        getDefaultLoaderHandlerWithContextGetter(
          ~eventName="IncreaseLiquidity",
          ~functionRegister=Handler,
        )
      }

    let handlerIsAsync = () => getHandler()->SyncAsync.isAsync
  }
  module DecreaseLiquidity = {
    open Types.NonfungiblePositionManagerContract.DecreaseLiquidityEvent

    type handlerWithContextGetter = handlerWithContextGetterSyncAsync<
      eventArgs,
      loaderContext,
      handlerContext,
      handlerContextAsync,
    >

    %%private(
      let decreaseLiquidityLoader: ref<option<loader<eventArgs, loaderContext>>> = ref(None)
      let decreaseLiquidityHandler: ref<option<handlerWithContextGetter>> = ref(None)
    )

    @genType
    let loader = loader => {
      decreaseLiquidityLoader := Some(loader)
    }

    @genType
    let handler = handler => {
      decreaseLiquidityHandler :=
        Some(Sync({handler, contextGetter: ctx => ctx.getHandlerContextSync()}))
    }

    // Silence the "this statement never returns (or has an unsound type.)" warning in the case that the user hasn't specified `isAsync` in their config file yet.
    @warning("-21") @genType
    let handlerAsync = handler => {
      decreaseLiquidityHandler :=
        Some(Async({handler, contextGetter: ctx => ctx.getHandlerContextAsync()}))
    }

    let getLoader = () =>
      decreaseLiquidityLoader.contents->Belt.Option.getWithDefault(
        getDefaultLoaderHandler(~eventName="DecreaseLiquidity", ~functionRegister=Loader),
      )

    let getHandler = () =>
      switch decreaseLiquidityHandler.contents {
      | Some(handler) => handler
      | None =>
        getDefaultLoaderHandlerWithContextGetter(
          ~eventName="DecreaseLiquidity",
          ~functionRegister=Handler,
        )
      }

    let handlerIsAsync = () => getHandler()->SyncAsync.isAsync
  }
  module Transfer = {
    open Types.NonfungiblePositionManagerContract.TransferEvent

    type handlerWithContextGetter = handlerWithContextGetterSyncAsync<
      eventArgs,
      loaderContext,
      handlerContext,
      handlerContextAsync,
    >

    %%private(
      let transferLoader: ref<option<loader<eventArgs, loaderContext>>> = ref(None)
      let transferHandler: ref<option<handlerWithContextGetter>> = ref(None)
    )

    @genType
    let loader = loader => {
      transferLoader := Some(loader)
    }

    @genType
    let handler = handler => {
      transferHandler := Some(Sync({handler, contextGetter: ctx => ctx.getHandlerContextSync()}))
    }

    // Silence the "this statement never returns (or has an unsound type.)" warning in the case that the user hasn't specified `isAsync` in their config file yet.
    @warning("-21") @genType
    let handlerAsync = handler => {
      Js.Exn.raiseError("Please add 'isAsync: true' to your config.yaml file to enable Async Mode.")

      transferHandler := Some(Async({handler, contextGetter: ctx => ctx.getHandlerContextAsync()}))
    }

    let getLoader = () =>
      transferLoader.contents->Belt.Option.getWithDefault(
        getDefaultLoaderHandler(~eventName="Transfer", ~functionRegister=Loader),
      )

    let getHandler = () =>
      switch transferHandler.contents {
      | Some(handler) => handler
      | None =>
        getDefaultLoaderHandlerWithContextGetter(~eventName="Transfer", ~functionRegister=Handler)
      }

    let handlerIsAsync = () => getHandler()->SyncAsync.isAsync
  }
}

module PoolContract = {
  module Swap = {
    open Types.PoolContract.SwapEvent

    type handlerWithContextGetter = handlerWithContextGetterSyncAsync<
      eventArgs,
      loaderContext,
      handlerContext,
      handlerContextAsync,
    >

    %%private(
      let swapLoader: ref<option<loader<eventArgs, loaderContext>>> = ref(None)
      let swapHandler: ref<option<handlerWithContextGetter>> = ref(None)
    )

    @genType
    let loader = loader => {
      swapLoader := Some(loader)
    }

    @genType
    let handler = handler => {
      swapHandler := Some(Sync({handler, contextGetter: ctx => ctx.getHandlerContextSync()}))
    }

    // Silence the "this statement never returns (or has an unsound type.)" warning in the case that the user hasn't specified `isAsync` in their config file yet.
    @warning("-21") @genType
    let handlerAsync = handler => {
      swapHandler := Some(Async({handler, contextGetter: ctx => ctx.getHandlerContextAsync()}))
    }

    let getLoader = () =>
      swapLoader.contents->Belt.Option.getWithDefault(
        getDefaultLoaderHandler(~eventName="Swap", ~functionRegister=Loader),
      )

    let getHandler = () =>
      switch swapHandler.contents {
      | Some(handler) => handler
      | None =>
        getDefaultLoaderHandlerWithContextGetter(~eventName="Swap", ~functionRegister=Handler)
      }

    let handlerIsAsync = () => getHandler()->SyncAsync.isAsync
  }
}
