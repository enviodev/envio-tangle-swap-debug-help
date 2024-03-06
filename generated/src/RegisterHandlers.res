@val external require: string => unit = "require"

let registerContractHandlers = (
  ~contractName,
  ~handlerPathRelativeToGeneratedSrc,
  ~handlerPathRelativeToConfig,
) => {
  try {
    require(handlerPathRelativeToGeneratedSrc)
  } catch {
  | exn =>
    let params = {
      "Contract Name": contractName,
      "Expected Handler Path": handlerPathRelativeToConfig,
      "Code": "EE500",
    }
    let logger = Logging.createChild(~params)

    let errHandler = exn->ErrorHandling.make(~msg="Failed to import handler file", ~logger)
    errHandler->ErrorHandling.log
    errHandler->ErrorHandling.raiseExn
  }
}

let registerAllHandlers = () => {
  registerContractHandlers(
    ~contractName="Factory",
    ~handlerPathRelativeToGeneratedSrc="../../src/event-handlers/Factory.ts",
    ~handlerPathRelativeToConfig="src/event-handlers/Factory.ts",
  )
  registerContractHandlers(
    ~contractName="NonfungiblePositionManager",
    ~handlerPathRelativeToGeneratedSrc="../../src/event-handlers/NonfungiblePositionManager.ts",
    ~handlerPathRelativeToConfig="src/event-handlers/NonfungiblePositionManager.ts",
  )
  registerContractHandlers(
    ~contractName="Pool",
    ~handlerPathRelativeToGeneratedSrc="../../src/event-handlers/Pool.ts",
    ~handlerPathRelativeToConfig="src/event-handlers/Pool.ts",
  )
}
