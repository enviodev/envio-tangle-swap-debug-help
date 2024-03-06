exception UndefinedEvent(string)
let eventStringToEvent = (eventName: string, contractName: string): Types.eventName => {
  switch (eventName, contractName) {
  | ("PoolCreated", "Factory") => Factory_PoolCreated
  | ("IncreaseLiquidity", "NonfungiblePositionManager") =>
    NonfungiblePositionManager_IncreaseLiquidity
  | ("DecreaseLiquidity", "NonfungiblePositionManager") =>
    NonfungiblePositionManager_DecreaseLiquidity
  | ("Transfer", "NonfungiblePositionManager") => NonfungiblePositionManager_Transfer
  | ("Swap", "Pool") => Pool_Swap
  | _ => UndefinedEvent(eventName)->raise
  }
}

module Factory = {
  let convertPoolCreatedViemDecodedEvent: Viem.decodedEvent<'a> => Viem.decodedEvent<
    Types.FactoryContract.PoolCreatedEvent.eventArgs,
  > = Obj.magic

  let convertPoolCreatedLogDescription = (log: Ethers.logDescription<'a>): Ethers.logDescription<
    Types.FactoryContract.PoolCreatedEvent.eventArgs,
  > => {
    //Convert from the ethersLog type with indexs as keys to named key value object
    let ethersLog: Ethers.logDescription<Types.FactoryContract.PoolCreatedEvent.ethersEventArgs> =
      log->Obj.magic
    let {args, name, signature, topic} = ethersLog

    {
      name,
      signature,
      topic,
      args: {
        token0: args.token0,
        token1: args.token1,
        fee: args.fee,
        tickSpacing: args.tickSpacing,
        pool: args.pool,
      },
    }
  }

  let convertPoolCreatedLog = (
    logDescription: Ethers.logDescription<Types.FactoryContract.PoolCreatedEvent.eventArgs>,
    ~log: Ethers.log,
    ~blockTimestamp: int,
    ~chainId: int,
    ~txOrigin: option<Ethers.ethAddress>,
  ) => {
    let params: Types.FactoryContract.PoolCreatedEvent.eventArgs = {
      token0: logDescription.args.token0,
      token1: logDescription.args.token1,
      fee: logDescription.args.fee,
      tickSpacing: logDescription.args.tickSpacing,
      pool: logDescription.args.pool,
    }

    let poolCreatedLog: Types.eventLog<Types.FactoryContract.PoolCreatedEvent.eventArgs> = {
      params,
      chainId,
      txOrigin,
      blockNumber: log.blockNumber,
      blockTimestamp,
      blockHash: log.blockHash,
      srcAddress: log.address,
      transactionHash: log.transactionHash,
      transactionIndex: log.transactionIndex,
      logIndex: log.logIndex,
    }

    Types.FactoryContract_PoolCreated(poolCreatedLog)
  }
  let convertPoolCreatedLogViem = (
    decodedEvent: Viem.decodedEvent<Types.FactoryContract.PoolCreatedEvent.eventArgs>,
    ~log: Ethers.log,
    ~blockTimestamp: int,
    ~chainId: int,
    ~txOrigin: option<Ethers.ethAddress>,
  ) => {
    let params: Types.FactoryContract.PoolCreatedEvent.eventArgs = {
      token0: decodedEvent.args.token0,
      token1: decodedEvent.args.token1,
      fee: decodedEvent.args.fee,
      tickSpacing: decodedEvent.args.tickSpacing,
      pool: decodedEvent.args.pool,
    }

    let poolCreatedLog: Types.eventLog<Types.FactoryContract.PoolCreatedEvent.eventArgs> = {
      params,
      chainId,
      txOrigin,
      blockNumber: log.blockNumber,
      blockTimestamp,
      blockHash: log.blockHash,
      srcAddress: log.address,
      transactionHash: log.transactionHash,
      transactionIndex: log.transactionIndex,
      logIndex: log.logIndex,
    }

    Types.FactoryContract_PoolCreated(poolCreatedLog)
  }

  let convertPoolCreatedDecodedEventParams = (
    decodedEvent: HyperSyncClient.Decoder.decodedEvent,
  ): Types.FactoryContract.PoolCreatedEvent.eventArgs => {
    open Belt
    let fields = ["token0", "token1", "fee", "tickSpacing", "pool"]
    let values =
      Array.concat(decodedEvent.indexed, decodedEvent.body)->Array.map(
        HyperSyncClient.Decoder.toUnderlying,
      )
    Array.zip(fields, values)->Js.Dict.fromArray->Obj.magic
  }
}

module NonfungiblePositionManager = {
  let convertIncreaseLiquidityViemDecodedEvent: Viem.decodedEvent<'a> => Viem.decodedEvent<
    Types.NonfungiblePositionManagerContract.IncreaseLiquidityEvent.eventArgs,
  > = Obj.magic

  let convertIncreaseLiquidityLogDescription = (
    log: Ethers.logDescription<'a>,
  ): Ethers.logDescription<
    Types.NonfungiblePositionManagerContract.IncreaseLiquidityEvent.eventArgs,
  > => {
    //Convert from the ethersLog type with indexs as keys to named key value object
    let ethersLog: Ethers.logDescription<
      Types.NonfungiblePositionManagerContract.IncreaseLiquidityEvent.ethersEventArgs,
    > =
      log->Obj.magic
    let {args, name, signature, topic} = ethersLog

    {
      name,
      signature,
      topic,
      args: {
        tokenId: args.tokenId,
        liquidity: args.liquidity,
        amount0: args.amount0,
        amount1: args.amount1,
      },
    }
  }

  let convertIncreaseLiquidityLog = (
    logDescription: Ethers.logDescription<
      Types.NonfungiblePositionManagerContract.IncreaseLiquidityEvent.eventArgs,
    >,
    ~log: Ethers.log,
    ~blockTimestamp: int,
    ~chainId: int,
    ~txOrigin: option<Ethers.ethAddress>,
  ) => {
    let params: Types.NonfungiblePositionManagerContract.IncreaseLiquidityEvent.eventArgs = {
      tokenId: logDescription.args.tokenId,
      liquidity: logDescription.args.liquidity,
      amount0: logDescription.args.amount0,
      amount1: logDescription.args.amount1,
    }

    let increaseLiquidityLog: Types.eventLog<
      Types.NonfungiblePositionManagerContract.IncreaseLiquidityEvent.eventArgs,
    > = {
      params,
      chainId,
      txOrigin,
      blockNumber: log.blockNumber,
      blockTimestamp,
      blockHash: log.blockHash,
      srcAddress: log.address,
      transactionHash: log.transactionHash,
      transactionIndex: log.transactionIndex,
      logIndex: log.logIndex,
    }

    Types.NonfungiblePositionManagerContract_IncreaseLiquidity(increaseLiquidityLog)
  }
  let convertIncreaseLiquidityLogViem = (
    decodedEvent: Viem.decodedEvent<
      Types.NonfungiblePositionManagerContract.IncreaseLiquidityEvent.eventArgs,
    >,
    ~log: Ethers.log,
    ~blockTimestamp: int,
    ~chainId: int,
    ~txOrigin: option<Ethers.ethAddress>,
  ) => {
    let params: Types.NonfungiblePositionManagerContract.IncreaseLiquidityEvent.eventArgs = {
      tokenId: decodedEvent.args.tokenId,
      liquidity: decodedEvent.args.liquidity,
      amount0: decodedEvent.args.amount0,
      amount1: decodedEvent.args.amount1,
    }

    let increaseLiquidityLog: Types.eventLog<
      Types.NonfungiblePositionManagerContract.IncreaseLiquidityEvent.eventArgs,
    > = {
      params,
      chainId,
      txOrigin,
      blockNumber: log.blockNumber,
      blockTimestamp,
      blockHash: log.blockHash,
      srcAddress: log.address,
      transactionHash: log.transactionHash,
      transactionIndex: log.transactionIndex,
      logIndex: log.logIndex,
    }

    Types.NonfungiblePositionManagerContract_IncreaseLiquidity(increaseLiquidityLog)
  }

  let convertIncreaseLiquidityDecodedEventParams = (
    decodedEvent: HyperSyncClient.Decoder.decodedEvent,
  ): Types.NonfungiblePositionManagerContract.IncreaseLiquidityEvent.eventArgs => {
    open Belt
    let fields = ["tokenId", "liquidity", "amount0", "amount1"]
    let values =
      Array.concat(decodedEvent.indexed, decodedEvent.body)->Array.map(
        HyperSyncClient.Decoder.toUnderlying,
      )
    Array.zip(fields, values)->Js.Dict.fromArray->Obj.magic
  }
  let convertDecreaseLiquidityViemDecodedEvent: Viem.decodedEvent<'a> => Viem.decodedEvent<
    Types.NonfungiblePositionManagerContract.DecreaseLiquidityEvent.eventArgs,
  > = Obj.magic

  let convertDecreaseLiquidityLogDescription = (
    log: Ethers.logDescription<'a>,
  ): Ethers.logDescription<
    Types.NonfungiblePositionManagerContract.DecreaseLiquidityEvent.eventArgs,
  > => {
    //Convert from the ethersLog type with indexs as keys to named key value object
    let ethersLog: Ethers.logDescription<
      Types.NonfungiblePositionManagerContract.DecreaseLiquidityEvent.ethersEventArgs,
    > =
      log->Obj.magic
    let {args, name, signature, topic} = ethersLog

    {
      name,
      signature,
      topic,
      args: {
        tokenId: args.tokenId,
        liquidity: args.liquidity,
        amount0: args.amount0,
        amount1: args.amount1,
      },
    }
  }

  let convertDecreaseLiquidityLog = (
    logDescription: Ethers.logDescription<
      Types.NonfungiblePositionManagerContract.DecreaseLiquidityEvent.eventArgs,
    >,
    ~log: Ethers.log,
    ~blockTimestamp: int,
    ~chainId: int,
    ~txOrigin: option<Ethers.ethAddress>,
  ) => {
    let params: Types.NonfungiblePositionManagerContract.DecreaseLiquidityEvent.eventArgs = {
      tokenId: logDescription.args.tokenId,
      liquidity: logDescription.args.liquidity,
      amount0: logDescription.args.amount0,
      amount1: logDescription.args.amount1,
    }

    let decreaseLiquidityLog: Types.eventLog<
      Types.NonfungiblePositionManagerContract.DecreaseLiquidityEvent.eventArgs,
    > = {
      params,
      chainId,
      txOrigin,
      blockNumber: log.blockNumber,
      blockTimestamp,
      blockHash: log.blockHash,
      srcAddress: log.address,
      transactionHash: log.transactionHash,
      transactionIndex: log.transactionIndex,
      logIndex: log.logIndex,
    }

    Types.NonfungiblePositionManagerContract_DecreaseLiquidity(decreaseLiquidityLog)
  }
  let convertDecreaseLiquidityLogViem = (
    decodedEvent: Viem.decodedEvent<
      Types.NonfungiblePositionManagerContract.DecreaseLiquidityEvent.eventArgs,
    >,
    ~log: Ethers.log,
    ~blockTimestamp: int,
    ~chainId: int,
    ~txOrigin: option<Ethers.ethAddress>,
  ) => {
    let params: Types.NonfungiblePositionManagerContract.DecreaseLiquidityEvent.eventArgs = {
      tokenId: decodedEvent.args.tokenId,
      liquidity: decodedEvent.args.liquidity,
      amount0: decodedEvent.args.amount0,
      amount1: decodedEvent.args.amount1,
    }

    let decreaseLiquidityLog: Types.eventLog<
      Types.NonfungiblePositionManagerContract.DecreaseLiquidityEvent.eventArgs,
    > = {
      params,
      chainId,
      txOrigin,
      blockNumber: log.blockNumber,
      blockTimestamp,
      blockHash: log.blockHash,
      srcAddress: log.address,
      transactionHash: log.transactionHash,
      transactionIndex: log.transactionIndex,
      logIndex: log.logIndex,
    }

    Types.NonfungiblePositionManagerContract_DecreaseLiquidity(decreaseLiquidityLog)
  }

  let convertDecreaseLiquidityDecodedEventParams = (
    decodedEvent: HyperSyncClient.Decoder.decodedEvent,
  ): Types.NonfungiblePositionManagerContract.DecreaseLiquidityEvent.eventArgs => {
    open Belt
    let fields = ["tokenId", "liquidity", "amount0", "amount1"]
    let values =
      Array.concat(decodedEvent.indexed, decodedEvent.body)->Array.map(
        HyperSyncClient.Decoder.toUnderlying,
      )
    Array.zip(fields, values)->Js.Dict.fromArray->Obj.magic
  }
  let convertTransferViemDecodedEvent: Viem.decodedEvent<'a> => Viem.decodedEvent<
    Types.NonfungiblePositionManagerContract.TransferEvent.eventArgs,
  > = Obj.magic

  let convertTransferLogDescription = (log: Ethers.logDescription<'a>): Ethers.logDescription<
    Types.NonfungiblePositionManagerContract.TransferEvent.eventArgs,
  > => {
    //Convert from the ethersLog type with indexs as keys to named key value object
    let ethersLog: Ethers.logDescription<
      Types.NonfungiblePositionManagerContract.TransferEvent.ethersEventArgs,
    > =
      log->Obj.magic
    let {args, name, signature, topic} = ethersLog

    {
      name,
      signature,
      topic,
      args: {
        from: args.from,
        to: args.to,
        tokenId: args.tokenId,
      },
    }
  }

  let convertTransferLog = (
    logDescription: Ethers.logDescription<
      Types.NonfungiblePositionManagerContract.TransferEvent.eventArgs,
    >,
    ~log: Ethers.log,
    ~blockTimestamp: int,
    ~chainId: int,
    ~txOrigin: option<Ethers.ethAddress>,
  ) => {
    let params: Types.NonfungiblePositionManagerContract.TransferEvent.eventArgs = {
      from: logDescription.args.from,
      to: logDescription.args.to,
      tokenId: logDescription.args.tokenId,
    }

    let transferLog: Types.eventLog<
      Types.NonfungiblePositionManagerContract.TransferEvent.eventArgs,
    > = {
      params,
      chainId,
      txOrigin,
      blockNumber: log.blockNumber,
      blockTimestamp,
      blockHash: log.blockHash,
      srcAddress: log.address,
      transactionHash: log.transactionHash,
      transactionIndex: log.transactionIndex,
      logIndex: log.logIndex,
    }

    Types.NonfungiblePositionManagerContract_Transfer(transferLog)
  }
  let convertTransferLogViem = (
    decodedEvent: Viem.decodedEvent<
      Types.NonfungiblePositionManagerContract.TransferEvent.eventArgs,
    >,
    ~log: Ethers.log,
    ~blockTimestamp: int,
    ~chainId: int,
    ~txOrigin: option<Ethers.ethAddress>,
  ) => {
    let params: Types.NonfungiblePositionManagerContract.TransferEvent.eventArgs = {
      from: decodedEvent.args.from,
      to: decodedEvent.args.to,
      tokenId: decodedEvent.args.tokenId,
    }

    let transferLog: Types.eventLog<
      Types.NonfungiblePositionManagerContract.TransferEvent.eventArgs,
    > = {
      params,
      chainId,
      txOrigin,
      blockNumber: log.blockNumber,
      blockTimestamp,
      blockHash: log.blockHash,
      srcAddress: log.address,
      transactionHash: log.transactionHash,
      transactionIndex: log.transactionIndex,
      logIndex: log.logIndex,
    }

    Types.NonfungiblePositionManagerContract_Transfer(transferLog)
  }

  let convertTransferDecodedEventParams = (
    decodedEvent: HyperSyncClient.Decoder.decodedEvent,
  ): Types.NonfungiblePositionManagerContract.TransferEvent.eventArgs => {
    open Belt
    let fields = ["from", "to", "tokenId"]
    let values =
      Array.concat(decodedEvent.indexed, decodedEvent.body)->Array.map(
        HyperSyncClient.Decoder.toUnderlying,
      )
    Array.zip(fields, values)->Js.Dict.fromArray->Obj.magic
  }
}

module Pool = {
  let convertSwapViemDecodedEvent: Viem.decodedEvent<'a> => Viem.decodedEvent<
    Types.PoolContract.SwapEvent.eventArgs,
  > = Obj.magic

  let convertSwapLogDescription = (log: Ethers.logDescription<'a>): Ethers.logDescription<
    Types.PoolContract.SwapEvent.eventArgs,
  > => {
    //Convert from the ethersLog type with indexs as keys to named key value object
    let ethersLog: Ethers.logDescription<Types.PoolContract.SwapEvent.ethersEventArgs> =
      log->Obj.magic
    let {args, name, signature, topic} = ethersLog

    {
      name,
      signature,
      topic,
      args: {
        sender: args.sender,
        recipient: args.recipient,
        amount0: args.amount0,
        amount1: args.amount1,
        sqrtPriceX96: args.sqrtPriceX96,
        liquidity: args.liquidity,
        tick: args.tick,
      },
    }
  }

  let convertSwapLog = (
    logDescription: Ethers.logDescription<Types.PoolContract.SwapEvent.eventArgs>,
    ~log: Ethers.log,
    ~blockTimestamp: int,
    ~chainId: int,
    ~txOrigin: option<Ethers.ethAddress>,
  ) => {
    let params: Types.PoolContract.SwapEvent.eventArgs = {
      sender: logDescription.args.sender,
      recipient: logDescription.args.recipient,
      amount0: logDescription.args.amount0,
      amount1: logDescription.args.amount1,
      sqrtPriceX96: logDescription.args.sqrtPriceX96,
      liquidity: logDescription.args.liquidity,
      tick: logDescription.args.tick,
    }

    let swapLog: Types.eventLog<Types.PoolContract.SwapEvent.eventArgs> = {
      params,
      chainId,
      txOrigin,
      blockNumber: log.blockNumber,
      blockTimestamp,
      blockHash: log.blockHash,
      srcAddress: log.address,
      transactionHash: log.transactionHash,
      transactionIndex: log.transactionIndex,
      logIndex: log.logIndex,
    }

    Types.PoolContract_Swap(swapLog)
  }
  let convertSwapLogViem = (
    decodedEvent: Viem.decodedEvent<Types.PoolContract.SwapEvent.eventArgs>,
    ~log: Ethers.log,
    ~blockTimestamp: int,
    ~chainId: int,
    ~txOrigin: option<Ethers.ethAddress>,
  ) => {
    let params: Types.PoolContract.SwapEvent.eventArgs = {
      sender: decodedEvent.args.sender,
      recipient: decodedEvent.args.recipient,
      amount0: decodedEvent.args.amount0,
      amount1: decodedEvent.args.amount1,
      sqrtPriceX96: decodedEvent.args.sqrtPriceX96,
      liquidity: decodedEvent.args.liquidity,
      tick: decodedEvent.args.tick,
    }

    let swapLog: Types.eventLog<Types.PoolContract.SwapEvent.eventArgs> = {
      params,
      chainId,
      txOrigin,
      blockNumber: log.blockNumber,
      blockTimestamp,
      blockHash: log.blockHash,
      srcAddress: log.address,
      transactionHash: log.transactionHash,
      transactionIndex: log.transactionIndex,
      logIndex: log.logIndex,
    }

    Types.PoolContract_Swap(swapLog)
  }

  let convertSwapDecodedEventParams = (
    decodedEvent: HyperSyncClient.Decoder.decodedEvent,
  ): Types.PoolContract.SwapEvent.eventArgs => {
    open Belt
    let fields = ["sender", "recipient", "amount0", "amount1", "sqrtPriceX96", "liquidity", "tick"]
    let values =
      Array.concat(decodedEvent.indexed, decodedEvent.body)->Array.map(
        HyperSyncClient.Decoder.toUnderlying,
      )
    Array.zip(fields, values)->Js.Dict.fromArray->Obj.magic
  }
}

exception ParseError(Ethers.Interface.parseLogError)
exception UnregisteredContract(Ethers.ethAddress)

let parseEventEthers = (
  ~log,
  ~blockTimestamp,
  ~contractInterfaceManager,
  ~chainId,
  ~txOrigin,
): Belt.Result.t<Types.event, _> => {
  let logDescriptionResult = contractInterfaceManager->ContractInterfaceManager.parseLogEthers(~log)
  switch logDescriptionResult {
  | Error(e) =>
    switch e {
    | ParseError(parseError) => ParseError(parseError)
    | UndefinedInterface(contractAddress) => UnregisteredContract(contractAddress)
    }->Error

  | Ok(logDescription) =>
    switch contractInterfaceManager->ContractInterfaceManager.getContractNameFromAddress(
      ~contractAddress=log.address,
    ) {
    | None => Error(UnregisteredContract(log.address))
    | Some(contractName) =>
      let event = switch eventStringToEvent(logDescription.name, contractName) {
      | Factory_PoolCreated =>
        logDescription
        ->Factory.convertPoolCreatedLogDescription
        ->Factory.convertPoolCreatedLog(~log, ~blockTimestamp, ~chainId, ~txOrigin)
      | NonfungiblePositionManager_IncreaseLiquidity =>
        logDescription
        ->NonfungiblePositionManager.convertIncreaseLiquidityLogDescription
        ->NonfungiblePositionManager.convertIncreaseLiquidityLog(
          ~log,
          ~blockTimestamp,
          ~chainId,
          ~txOrigin,
        )
      | NonfungiblePositionManager_DecreaseLiquidity =>
        logDescription
        ->NonfungiblePositionManager.convertDecreaseLiquidityLogDescription
        ->NonfungiblePositionManager.convertDecreaseLiquidityLog(
          ~log,
          ~blockTimestamp,
          ~chainId,
          ~txOrigin,
        )
      | NonfungiblePositionManager_Transfer =>
        logDescription
        ->NonfungiblePositionManager.convertTransferLogDescription
        ->NonfungiblePositionManager.convertTransferLog(~log, ~blockTimestamp, ~chainId, ~txOrigin)
      | Pool_Swap =>
        logDescription
        ->Pool.convertSwapLogDescription
        ->Pool.convertSwapLog(~log, ~blockTimestamp, ~chainId, ~txOrigin)
      }

      Ok(event)
    }
  }
}

let makeEventLog = (
  params: 'args,
  ~log: Ethers.log,
  ~blockTimestamp: int,
  ~chainId: int,
  ~txOrigin: option<Ethers.ethAddress>,
): Types.eventLog<'args> => {
  chainId,
  params,
  txOrigin,
  blockNumber: log.blockNumber,
  blockTimestamp,
  blockHash: log.blockHash,
  srcAddress: log.address,
  transactionHash: log.transactionHash,
  transactionIndex: log.transactionIndex,
  logIndex: log.logIndex,
}

let convertDecodedEvent = (
  event: HyperSyncClient.Decoder.decodedEvent,
  ~contractInterfaceManager,
  ~log: Ethers.log,
  ~blockTimestamp,
  ~chainId,
  ~txOrigin: option<Ethers.ethAddress>,
): result<Types.event, _> => {
  switch contractInterfaceManager->ContractInterfaceManager.getContractNameFromAddress(
    ~contractAddress=log.address,
  ) {
  | None => Error(UnregisteredContract(log.address))
  | Some(contractName) =>
    let event = switch Types.eventTopicToEventName(contractName, log.topics[0]) {
    | Factory_PoolCreated =>
      event
      ->Factory.convertPoolCreatedDecodedEventParams
      ->makeEventLog(~log, ~blockTimestamp, ~chainId, ~txOrigin)
      ->Types.FactoryContract_PoolCreated
    | NonfungiblePositionManager_IncreaseLiquidity =>
      event
      ->NonfungiblePositionManager.convertIncreaseLiquidityDecodedEventParams
      ->makeEventLog(~log, ~blockTimestamp, ~chainId, ~txOrigin)
      ->Types.NonfungiblePositionManagerContract_IncreaseLiquidity
    | NonfungiblePositionManager_DecreaseLiquidity =>
      event
      ->NonfungiblePositionManager.convertDecreaseLiquidityDecodedEventParams
      ->makeEventLog(~log, ~blockTimestamp, ~chainId, ~txOrigin)
      ->Types.NonfungiblePositionManagerContract_DecreaseLiquidity
    | NonfungiblePositionManager_Transfer =>
      event
      ->NonfungiblePositionManager.convertTransferDecodedEventParams
      ->makeEventLog(~log, ~blockTimestamp, ~chainId, ~txOrigin)
      ->Types.NonfungiblePositionManagerContract_Transfer
    | Pool_Swap =>
      event
      ->Pool.convertSwapDecodedEventParams
      ->makeEventLog(~log, ~blockTimestamp, ~chainId, ~txOrigin)
      ->Types.PoolContract_Swap
    }
    Ok(event)
  }
}

let parseEvent = (
  ~log,
  ~blockTimestamp,
  ~contractInterfaceManager,
  ~chainId,
  ~txOrigin,
): Belt.Result.t<Types.event, _> => {
  let decodedEventResult = contractInterfaceManager->ContractInterfaceManager.parseLogViem(~log)
  switch decodedEventResult {
  | Error(e) =>
    switch e {
    | ParseError(parseError) => ParseError(parseError)
    | UndefinedInterface(contractAddress) => UnregisteredContract(contractAddress)
    }->Error

  | Ok(decodedEvent) =>
    switch contractInterfaceManager->ContractInterfaceManager.getContractNameFromAddress(
      ~contractAddress=log.address,
    ) {
    | None => Error(UnregisteredContract(log.address))
    | Some(contractName) =>
      let event = switch eventStringToEvent(decodedEvent.eventName, contractName) {
      | Factory_PoolCreated =>
        decodedEvent
        ->Factory.convertPoolCreatedViemDecodedEvent
        ->Factory.convertPoolCreatedLogViem(~log, ~blockTimestamp, ~chainId, ~txOrigin)
      | NonfungiblePositionManager_IncreaseLiquidity =>
        decodedEvent
        ->NonfungiblePositionManager.convertIncreaseLiquidityViemDecodedEvent
        ->NonfungiblePositionManager.convertIncreaseLiquidityLogViem(
          ~log,
          ~blockTimestamp,
          ~chainId,
          ~txOrigin,
        )
      | NonfungiblePositionManager_DecreaseLiquidity =>
        decodedEvent
        ->NonfungiblePositionManager.convertDecreaseLiquidityViemDecodedEvent
        ->NonfungiblePositionManager.convertDecreaseLiquidityLogViem(
          ~log,
          ~blockTimestamp,
          ~chainId,
          ~txOrigin,
        )
      | NonfungiblePositionManager_Transfer =>
        decodedEvent
        ->NonfungiblePositionManager.convertTransferViemDecodedEvent
        ->NonfungiblePositionManager.convertTransferLogViem(
          ~log,
          ~blockTimestamp,
          ~chainId,
          ~txOrigin,
        )
      | Pool_Swap =>
        decodedEvent
        ->Pool.convertSwapViemDecodedEvent
        ->Pool.convertSwapLogViem(~log, ~blockTimestamp, ~chainId, ~txOrigin)
      }

      Ok(event)
    }
  }
}

let decodeRawEventWith = (
  rawEvent: Types.rawEventsEntity,
  ~decoder: Spice.decoder<'a>,
  ~variantAccessor: Types.eventLog<'a> => Types.event,
  ~chain,
  ~txOrigin: option<Ethers.ethAddress>,
): Spice.result<Types.eventBatchQueueItem> => {
  switch rawEvent.params->Js.Json.parseExn {
  | exception exn =>
    let message =
      exn
      ->Js.Exn.asJsExn
      ->Belt.Option.flatMap(jsexn => jsexn->Js.Exn.message)
      ->Belt.Option.getWithDefault("No message on exn")

    Spice.error(`Failed at JSON.parse. Error: ${message}`, rawEvent.params->Obj.magic)
  | v => Ok(v)
  }
  ->Belt.Result.flatMap(json => {
    json->decoder
  })
  ->Belt.Result.map(params => {
    let event = {
      chainId: rawEvent.chainId,
      txOrigin,
      blockNumber: rawEvent.blockNumber,
      blockTimestamp: rawEvent.blockTimestamp,
      blockHash: rawEvent.blockHash,
      srcAddress: rawEvent.srcAddress,
      transactionHash: rawEvent.transactionHash,
      transactionIndex: rawEvent.transactionIndex,
      logIndex: rawEvent.logIndex,
      params,
    }->variantAccessor

    let queueItem: Types.eventBatchQueueItem = {
      timestamp: rawEvent.blockTimestamp,
      chain,
      blockNumber: rawEvent.blockNumber,
      logIndex: rawEvent.logIndex,
      event,
    }

    queueItem
  })
}

let parseRawEvent = (
  rawEvent: Types.rawEventsEntity,
  ~chain,
  ~txOrigin: option<Ethers.ethAddress>,
): Spice.result<Types.eventBatchQueueItem> => {
  rawEvent.eventType
  ->Types.eventName_decode
  ->Belt.Result.flatMap(eventName => {
    switch eventName {
    | Factory_PoolCreated =>
      rawEvent->decodeRawEventWith(
        ~decoder=Types.FactoryContract.PoolCreatedEvent.eventArgs_decode,
        ~variantAccessor=Types.factoryContract_PoolCreated,
        ~chain,
        ~txOrigin,
      )
    | NonfungiblePositionManager_IncreaseLiquidity =>
      rawEvent->decodeRawEventWith(
        ~decoder=Types.NonfungiblePositionManagerContract.IncreaseLiquidityEvent.eventArgs_decode,
        ~variantAccessor=Types.nonfungiblePositionManagerContract_IncreaseLiquidity,
        ~chain,
        ~txOrigin,
      )
    | NonfungiblePositionManager_DecreaseLiquidity =>
      rawEvent->decodeRawEventWith(
        ~decoder=Types.NonfungiblePositionManagerContract.DecreaseLiquidityEvent.eventArgs_decode,
        ~variantAccessor=Types.nonfungiblePositionManagerContract_DecreaseLiquidity,
        ~chain,
        ~txOrigin,
      )
    | NonfungiblePositionManager_Transfer =>
      rawEvent->decodeRawEventWith(
        ~decoder=Types.NonfungiblePositionManagerContract.TransferEvent.eventArgs_decode,
        ~variantAccessor=Types.nonfungiblePositionManagerContract_Transfer,
        ~chain,
        ~txOrigin,
      )
    | Pool_Swap =>
      rawEvent->decodeRawEventWith(
        ~decoder=Types.PoolContract.SwapEvent.eventArgs_decode,
        ~variantAccessor=Types.poolContract_Swap,
        ~chain,
        ~txOrigin,
      )
    }
  })
}
