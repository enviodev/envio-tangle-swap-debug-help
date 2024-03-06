import { createPublicClient, http } from 'viem'

export const viemClient = createPublicClient({
  transport: http('https://json-rpc.evm.shimmer.network', {
    retryCount: 3,
    retryDelay: 250
  })
})
