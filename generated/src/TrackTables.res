%%raw(`globalThis.fetch = require('node-fetch')`)
open Fetch

%%private(let envSafe = EnvSafe.make())

let hasuraGraphqlEndpoint = EnvUtils.getStringEnvVar(
  ~envSafe,
  ~fallback="http://localhost:8080/v1/metadata",
  "HASURA_GRAPHQL_ENDPOINT",
)

let hasuraRole = EnvUtils.getStringEnvVar(~envSafe, ~fallback="admin", "HASURA_GRAPHQL_ROLE")

let hasuraSecret = EnvUtils.getStringEnvVar(
  ~envSafe,
  ~fallback="testing",
  "HASURA_GRAPHQL_ADMIN_SECRET",
)

let headers = {
  "Content-Type": "application/json",
  "X-Hasura-Role": hasuraRole,
  "X-Hasura-Admin-Secret": hasuraSecret,
}

@spice
type hasuraErrorResponse = {code: string, error: string, path: string}
type validHasuraResponse = QuerySucceeded | AlreadyDone

let validateHasuraResponse = (~statusCode: int, ~responseJson: Js.Json.t): Belt.Result.t<
  validHasuraResponse,
  unit,
> =>
  if statusCode == 200 {
    Ok(QuerySucceeded)
  } else {
    switch responseJson->hasuraErrorResponse_decode {
    | Ok(decoded) =>
      switch decoded.code {
      | "already-exists"
      | "already-tracked" =>
        Ok(AlreadyDone)
      | _ =>
        //If the code is not known return it as an error
        Error()
      }
    //If we couldn't decode just return it as an error
    | Error(_e) => Error()
    }
  }

let clearHasuraMetadata = async () => {
  let body = {
    "type": "clear_metadata",
    "args": Js.Obj.empty(),
  }

  let response = await fetch(
    hasuraGraphqlEndpoint,
    {
      method: #POST,
      body: body->Js.Json.stringifyAny->Belt.Option.getExn->Body.string,
      headers: Headers.fromObject(headers),
    },
  )

  let responseJson = await response->Response.json
  let statusCode = response->Response.status

  switch validateHasuraResponse(~statusCode, ~responseJson) {
  | Error(_) =>
    Logging.error({
      "msg": `EE806: There was an issue clearing metadata in hasura - indexing may still work - but you may have issues querying the data in hasura.`,
      "requestStatusCode": statusCode,
      "requestResponseJson": responseJson,
    })
  | Ok(case) =>
    let msg = switch case {
    | QuerySucceeded => "Metadata Cleared"
    | AlreadyDone => "Metadata Already Cleared"
    }
    Logging.trace({
      "msg": msg,
      "requestStatusCode": statusCode,
      "requestResponseJson": responseJson,
    })
  }
}

let trackTable = async (~tableName: string) => {
  let body = {
    "type": "pg_track_table",
    "args": {
      "source": "public",
      "schema": "public",
      "name": tableName,
    },
  }

  let response = await fetch(
    hasuraGraphqlEndpoint,
    {
      method: #POST,
      body: body->Js.Json.stringifyAny->Belt.Option.getExn->Body.string,
      headers: Headers.fromObject(headers),
    },
  )

  let responseJson = await response->Response.json
  let statusCode = response->Response.status

  switch validateHasuraResponse(~statusCode, ~responseJson) {
  | Error(_) =>
    Logging.error({
      "msg": `EE807: There was an issue tracking the ${tableName} table in hasura - indexing may still work - but you may have issues querying the data in hasura.`,
      "tableName": tableName,
      "requestStatusCode": statusCode,
      "requestResponseJson": responseJson,
    })
  | Ok(case) =>
    let msg = switch case {
    | QuerySucceeded => "Table Tracked"
    | AlreadyDone => "Table Already Tracked"
    }
    Logging.trace({
      "msg": msg,
      "tableName": tableName,
      "requestStatusCode": statusCode,
      "requestResponseJson": responseJson,
    })
  }
}

let createSelectPermissions = async (~tableName: string) => {
  let body = {
    "type": "pg_create_select_permission",
    "args": {
      "table": tableName,
      "role": "public",
      "source": "default",
      "permission": {
        "columns": "*",
        "filter": Js.Obj.empty(),
        "limit": Env.hasuraResponseLimit,
      },
    },
  }

  let response = await fetch(
    hasuraGraphqlEndpoint,
    {
      method: #POST,
      body: body->Js.Json.stringifyAny->Belt.Option.getExn->Body.string,
      headers: Headers.fromObject(headers),
    },
  )

  let responseJson = await response->Response.json
  let statusCode = response->Response.status

  switch validateHasuraResponse(~statusCode, ~responseJson) {
  | Error(_) =>
    Logging.error({
      "msg": `EE808: There was an issue setting up view permissions for the ${tableName} table in hasura - indexing may still work - but you may have issues querying the data in hasura.`,
      "tableName": tableName,
      "requestStatusCode": statusCode,
      "requestResponseJson": responseJson,
    })
  | Ok(case) =>
    let msg = switch case {
    | QuerySucceeded => "Hasura select permissions created"
    | AlreadyDone => "Hasura select permissions already created"
    }
    Logging.trace({
      "msg": msg,
      "tableName": tableName,
      "requestStatusCode": statusCode,
      "requestResponseJson": responseJson,
    })
  }
}

let createEntityRelationship = async (
  ~tableName: string,
  ~relationshipType: string,
  ~relationalKey: string,
  ~objectName: string,
  ~mappedEntity: string,
  ~isDerivedFrom: bool,
) => {
  let derivedFromTo = isDerivedFrom ? `"id": "${relationalKey}"` : `"${relationalKey}_id" : "id"`

  let bodyString = `{"type": "pg_create_${relationshipType}_relationship","args": {"table": "${tableName}","name": "${objectName}","source": "default","using": {"manual_configuration": {"remote_table": "${mappedEntity}","column_mapping": {${derivedFromTo}}}}}}`

  let response = await fetch(
    hasuraGraphqlEndpoint,
    {
      method: #POST,
      body: bodyString->Body.string,
      headers: Headers.fromObject(headers),
    },
  )

  let responseJson = await response->Response.json
  let statusCode = response->Response.status

  switch validateHasuraResponse(~statusCode, ~responseJson) {
  | Error(_) =>
    Logging.error({
      "msg": `EE808: There was an issue setting up view permissions for the ${tableName} table in hasura - indexing may still work - but you may have issues querying the data in hasura.`,
      "tableName": tableName,
      "requestStatusCode": statusCode,
      "requestResponseJson": responseJson,
    })
  | Ok(case) =>
    let msg = switch case {
    | QuerySucceeded => "Hasura derived field permissions created"
    | AlreadyDone => "Hasura derived field permissions already created"
    }
    Logging.trace({
      "msg": msg,
      "tableName": tableName,
      "requestStatusCode": statusCode,
      "requestResponseJson": responseJson,
    })
  }
}

let trackAllTables = async () => {
  Logging.info("Tracking tables in Hasura")
  let _ = await clearHasuraMetadata()
  let _ = await trackTable(~tableName="raw_events")
  let _ = await createSelectPermissions(~tableName="raw_events")
  let _ = await trackTable(~tableName="chain_metadata")
  let _ = await createSelectPermissions(~tableName="chain_metadata")
  let _ = await trackTable(~tableName="dynamic_contract_registry")
  let _ = await createSelectPermissions(~tableName="dynamic_contract_registry")
  let _ = await trackTable(~tableName="persisted_state")
  let _ = await createSelectPermissions(~tableName="persisted_state")
  let _ = await trackTable(~tableName="event_sync_state")
  let _ = await createSelectPermissions(~tableName="event_sync_state")
  let _ = await trackTable(~tableName="Bundle")
  let _ = await createSelectPermissions(~tableName="Bundle")
  let _ = await trackTable(~tableName="Burn")
  let _ = await createSelectPermissions(~tableName="Burn")
  let _ = await trackTable(~tableName="Collect")
  let _ = await createSelectPermissions(~tableName="Collect")
  let _ = await trackTable(~tableName="Factory")
  let _ = await createSelectPermissions(~tableName="Factory")
  let _ = await trackTable(~tableName="Flash")
  let _ = await createSelectPermissions(~tableName="Flash")
  let _ = await trackTable(~tableName="Mint")
  let _ = await createSelectPermissions(~tableName="Mint")
  let _ = await trackTable(~tableName="Pool")
  let _ = await createSelectPermissions(~tableName="Pool")
  let _ = await trackTable(~tableName="PoolDayData")
  let _ = await createSelectPermissions(~tableName="PoolDayData")
  let _ = await trackTable(~tableName="PoolHourData")
  let _ = await createSelectPermissions(~tableName="PoolHourData")
  let _ = await trackTable(~tableName="Position")
  let _ = await createSelectPermissions(~tableName="Position")
  let _ = await trackTable(~tableName="PositionSnapshot")
  let _ = await createSelectPermissions(~tableName="PositionSnapshot")
  let _ = await trackTable(~tableName="Swap")
  let _ = await createSelectPermissions(~tableName="Swap")
  let _ = await trackTable(~tableName="Tick")
  let _ = await createSelectPermissions(~tableName="Tick")
  let _ = await trackTable(~tableName="TickDayData")
  let _ = await createSelectPermissions(~tableName="TickDayData")
  let _ = await trackTable(~tableName="TickHourData")
  let _ = await createSelectPermissions(~tableName="TickHourData")
  let _ = await trackTable(~tableName="Token")
  let _ = await createSelectPermissions(~tableName="Token")
  let _ = await trackTable(~tableName="TokenDayData")
  let _ = await createSelectPermissions(~tableName="TokenDayData")
  let _ = await trackTable(~tableName="TokenHourData")
  let _ = await createSelectPermissions(~tableName="TokenHourData")
  let _ = await trackTable(~tableName="TokenPoolWhitelist")
  let _ = await createSelectPermissions(~tableName="TokenPoolWhitelist")
  let _ = await trackTable(~tableName="Transaction")
  let _ = await createSelectPermissions(~tableName="Transaction")
  let _ = await trackTable(~tableName="UniswapDayData")
  let _ = await createSelectPermissions(~tableName="UniswapDayData")
  let _ = await createEntityRelationship(
    ~tableName="Burn",
    ~relationshipType="object",
    ~isDerivedFrom=false,
    ~objectName="transaction",
    ~relationalKey="transaction",
    ~mappedEntity="Transaction",
  )
  let _ = await createEntityRelationship(
    ~tableName="Burn",
    ~relationshipType="object",
    ~isDerivedFrom=false,
    ~objectName="token0",
    ~relationalKey="token0",
    ~mappedEntity="Token",
  )
  let _ = await createEntityRelationship(
    ~tableName="Burn",
    ~relationshipType="object",
    ~isDerivedFrom=false,
    ~objectName="pool",
    ~relationalKey="pool",
    ~mappedEntity="Pool",
  )
  let _ = await createEntityRelationship(
    ~tableName="Burn",
    ~relationshipType="object",
    ~isDerivedFrom=false,
    ~objectName="token1",
    ~relationalKey="token1",
    ~mappedEntity="Token",
  )
  let _ = await createEntityRelationship(
    ~tableName="Collect",
    ~relationshipType="object",
    ~isDerivedFrom=false,
    ~objectName="transaction",
    ~relationalKey="transaction",
    ~mappedEntity="Transaction",
  )
  let _ = await createEntityRelationship(
    ~tableName="Collect",
    ~relationshipType="object",
    ~isDerivedFrom=false,
    ~objectName="pool",
    ~relationalKey="pool",
    ~mappedEntity="Pool",
  )
  let _ = await createEntityRelationship(
    ~tableName="Flash",
    ~relationshipType="object",
    ~isDerivedFrom=false,
    ~objectName="pool",
    ~relationalKey="pool",
    ~mappedEntity="Pool",
  )
  let _ = await createEntityRelationship(
    ~tableName="Flash",
    ~relationshipType="object",
    ~isDerivedFrom=false,
    ~objectName="transaction",
    ~relationalKey="transaction",
    ~mappedEntity="Transaction",
  )
  let _ = await createEntityRelationship(
    ~tableName="Mint",
    ~relationshipType="object",
    ~isDerivedFrom=false,
    ~objectName="token0",
    ~relationalKey="token0",
    ~mappedEntity="Token",
  )
  let _ = await createEntityRelationship(
    ~tableName="Mint",
    ~relationshipType="object",
    ~isDerivedFrom=false,
    ~objectName="transaction",
    ~relationalKey="transaction",
    ~mappedEntity="Transaction",
  )
  let _ = await createEntityRelationship(
    ~tableName="Mint",
    ~relationshipType="object",
    ~isDerivedFrom=false,
    ~objectName="pool",
    ~relationalKey="pool",
    ~mappedEntity="Pool",
  )
  let _ = await createEntityRelationship(
    ~tableName="Mint",
    ~relationshipType="object",
    ~isDerivedFrom=false,
    ~objectName="token1",
    ~relationalKey="token1",
    ~mappedEntity="Token",
  )
  let _ = await createEntityRelationship(
    ~tableName="Pool",
    ~relationshipType="object",
    ~isDerivedFrom=false,
    ~objectName="token1",
    ~relationalKey="token1",
    ~mappedEntity="Token",
  )
  let _ = await createEntityRelationship(
    ~tableName="Pool",
    ~relationshipType="object",
    ~isDerivedFrom=false,
    ~objectName="token0",
    ~relationalKey="token0",
    ~mappedEntity="Token",
  )
  let _ = await createEntityRelationship(
    ~tableName="Pool",
    ~relationshipType="array",
    ~isDerivedFrom=true,
    ~objectName="poolDayData",
    ~relationalKey="pool_id",
    ~mappedEntity="PoolDayData",
  )
  let _ = await createEntityRelationship(
    ~tableName="Pool",
    ~relationshipType="array",
    ~isDerivedFrom=true,
    ~objectName="burns",
    ~relationalKey="pool_id",
    ~mappedEntity="Burn",
  )
  let _ = await createEntityRelationship(
    ~tableName="Pool",
    ~relationshipType="array",
    ~isDerivedFrom=true,
    ~objectName="swaps",
    ~relationalKey="pool_id",
    ~mappedEntity="Swap",
  )
  let _ = await createEntityRelationship(
    ~tableName="Pool",
    ~relationshipType="array",
    ~isDerivedFrom=true,
    ~objectName="ticks",
    ~relationalKey="pool_id",
    ~mappedEntity="Tick",
  )
  let _ = await createEntityRelationship(
    ~tableName="Pool",
    ~relationshipType="array",
    ~isDerivedFrom=true,
    ~objectName="whitelistPools",
    ~relationalKey="pool_id",
    ~mappedEntity="TokenPoolWhitelist",
  )
  let _ = await createEntityRelationship(
    ~tableName="Pool",
    ~relationshipType="array",
    ~isDerivedFrom=true,
    ~objectName="mints",
    ~relationalKey="pool_id",
    ~mappedEntity="Mint",
  )
  let _ = await createEntityRelationship(
    ~tableName="Pool",
    ~relationshipType="array",
    ~isDerivedFrom=true,
    ~objectName="poolHourData",
    ~relationalKey="pool_id",
    ~mappedEntity="PoolHourData",
  )
  let _ = await createEntityRelationship(
    ~tableName="Pool",
    ~relationshipType="array",
    ~isDerivedFrom=true,
    ~objectName="collects",
    ~relationalKey="pool_id",
    ~mappedEntity="Collect",
  )
  let _ = await createEntityRelationship(
    ~tableName="PoolDayData",
    ~relationshipType="object",
    ~isDerivedFrom=false,
    ~objectName="pool",
    ~relationalKey="pool",
    ~mappedEntity="Pool",
  )
  let _ = await createEntityRelationship(
    ~tableName="PoolHourData",
    ~relationshipType="object",
    ~isDerivedFrom=false,
    ~objectName="pool",
    ~relationalKey="pool",
    ~mappedEntity="Pool",
  )
  let _ = await createEntityRelationship(
    ~tableName="Position",
    ~relationshipType="object",
    ~isDerivedFrom=false,
    ~objectName="token1",
    ~relationalKey="token1",
    ~mappedEntity="Token",
  )
  let _ = await createEntityRelationship(
    ~tableName="Position",
    ~relationshipType="object",
    ~isDerivedFrom=false,
    ~objectName="token0",
    ~relationalKey="token0",
    ~mappedEntity="Token",
  )
  let _ = await createEntityRelationship(
    ~tableName="Position",
    ~relationshipType="object",
    ~isDerivedFrom=false,
    ~objectName="tickLower",
    ~relationalKey="tickLower",
    ~mappedEntity="Tick",
  )
  let _ = await createEntityRelationship(
    ~tableName="Position",
    ~relationshipType="object",
    ~isDerivedFrom=false,
    ~objectName="transaction",
    ~relationalKey="transaction",
    ~mappedEntity="Transaction",
  )
  let _ = await createEntityRelationship(
    ~tableName="Position",
    ~relationshipType="object",
    ~isDerivedFrom=false,
    ~objectName="pool",
    ~relationalKey="pool",
    ~mappedEntity="Pool",
  )
  let _ = await createEntityRelationship(
    ~tableName="Position",
    ~relationshipType="object",
    ~isDerivedFrom=false,
    ~objectName="tickUpper",
    ~relationalKey="tickUpper",
    ~mappedEntity="Tick",
  )
  let _ = await createEntityRelationship(
    ~tableName="PositionSnapshot",
    ~relationshipType="object",
    ~isDerivedFrom=false,
    ~objectName="pool",
    ~relationalKey="pool",
    ~mappedEntity="Pool",
  )
  let _ = await createEntityRelationship(
    ~tableName="PositionSnapshot",
    ~relationshipType="object",
    ~isDerivedFrom=false,
    ~objectName="position",
    ~relationalKey="position",
    ~mappedEntity="Position",
  )
  let _ = await createEntityRelationship(
    ~tableName="PositionSnapshot",
    ~relationshipType="object",
    ~isDerivedFrom=false,
    ~objectName="transaction",
    ~relationalKey="transaction",
    ~mappedEntity="Transaction",
  )
  let _ = await createEntityRelationship(
    ~tableName="Swap",
    ~relationshipType="object",
    ~isDerivedFrom=false,
    ~objectName="tick",
    ~relationalKey="tick",
    ~mappedEntity="Tick",
  )
  let _ = await createEntityRelationship(
    ~tableName="Swap",
    ~relationshipType="object",
    ~isDerivedFrom=false,
    ~objectName="transaction",
    ~relationalKey="transaction",
    ~mappedEntity="Transaction",
  )
  let _ = await createEntityRelationship(
    ~tableName="Swap",
    ~relationshipType="object",
    ~isDerivedFrom=false,
    ~objectName="token1",
    ~relationalKey="token1",
    ~mappedEntity="Token",
  )
  let _ = await createEntityRelationship(
    ~tableName="Swap",
    ~relationshipType="object",
    ~isDerivedFrom=false,
    ~objectName="token0",
    ~relationalKey="token0",
    ~mappedEntity="Token",
  )
  let _ = await createEntityRelationship(
    ~tableName="Swap",
    ~relationshipType="object",
    ~isDerivedFrom=false,
    ~objectName="pool",
    ~relationalKey="pool",
    ~mappedEntity="Pool",
  )
  let _ = await createEntityRelationship(
    ~tableName="Tick",
    ~relationshipType="array",
    ~isDerivedFrom=true,
    ~objectName="swaps",
    ~relationalKey="tick_id",
    ~mappedEntity="Swap",
  )
  let _ = await createEntityRelationship(
    ~tableName="Tick",
    ~relationshipType="object",
    ~isDerivedFrom=false,
    ~objectName="pool",
    ~relationalKey="pool",
    ~mappedEntity="Pool",
  )
  let _ = await createEntityRelationship(
    ~tableName="TickDayData",
    ~relationshipType="object",
    ~isDerivedFrom=false,
    ~objectName="pool",
    ~relationalKey="pool",
    ~mappedEntity="Pool",
  )
  let _ = await createEntityRelationship(
    ~tableName="TickDayData",
    ~relationshipType="object",
    ~isDerivedFrom=false,
    ~objectName="tick",
    ~relationalKey="tick",
    ~mappedEntity="Tick",
  )
  let _ = await createEntityRelationship(
    ~tableName="TickHourData",
    ~relationshipType="object",
    ~isDerivedFrom=false,
    ~objectName="tick",
    ~relationalKey="tick",
    ~mappedEntity="Tick",
  )
  let _ = await createEntityRelationship(
    ~tableName="TickHourData",
    ~relationshipType="object",
    ~isDerivedFrom=false,
    ~objectName="pool",
    ~relationalKey="pool",
    ~mappedEntity="Pool",
  )
  let _ = await createEntityRelationship(
    ~tableName="Token",
    ~relationshipType="array",
    ~isDerivedFrom=true,
    ~objectName="whitelistPools",
    ~relationalKey="token_id",
    ~mappedEntity="TokenPoolWhitelist",
  )
  let _ = await createEntityRelationship(
    ~tableName="Token",
    ~relationshipType="array",
    ~isDerivedFrom=true,
    ~objectName="tokenDayData",
    ~relationalKey="token_id",
    ~mappedEntity="TokenDayData",
  )
  let _ = await createEntityRelationship(
    ~tableName="TokenDayData",
    ~relationshipType="object",
    ~isDerivedFrom=false,
    ~objectName="token",
    ~relationalKey="token",
    ~mappedEntity="Token",
  )
  let _ = await createEntityRelationship(
    ~tableName="TokenHourData",
    ~relationshipType="object",
    ~isDerivedFrom=false,
    ~objectName="token",
    ~relationalKey="token",
    ~mappedEntity="Token",
  )
  let _ = await createEntityRelationship(
    ~tableName="TokenPoolWhitelist",
    ~relationshipType="object",
    ~isDerivedFrom=false,
    ~objectName="token",
    ~relationalKey="token",
    ~mappedEntity="Token",
  )
  let _ = await createEntityRelationship(
    ~tableName="TokenPoolWhitelist",
    ~relationshipType="object",
    ~isDerivedFrom=false,
    ~objectName="pool",
    ~relationalKey="pool",
    ~mappedEntity="Pool",
  )
}
