import hre from 'hardhat'
const { ethers } = hre

// Router Helpers
export const MAX_UINT = '0xffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffffff'
export const MAX_UINT160 = '0xffffffffffffffffffffffffffffffffffffffff'
export const DEADLINE = 2000000000
export const CONTRACT_BALANCE = 0
export const ALICE_ADDRESS = '0xf977814e90da44bfa03b6295a0616a897441acec'
export const ETH_ADDRESS = ethers.constants.AddressZero
export const ONE_PERCENT_BIPS = 100

// Protocol Data
export const OPENSEA_CONDUIT = '0x1e0049783f008a0085193e00003d00cd54003c71'
export const OPENSEA_CONDUIT_KEY = '0x0000007b02230091a7ed01230072f7006a004d60a8d4e71d599b8104250f0000'

// NFT Addresses
export const COVEN_ADDRESS = '0x5180db8f5c931aae63c74266b211f580155ecac8'
export const TWERKY_ADDRESS = '0xf4680c917a873e2dd6ead72f9f433e74eb9c623c'
export const ALPHABETTIES_ADDRESS = '0x6d05064fe99e40f1c3464e7310a23ffaded56e20'
export const CRYPTOPUNKS_MARKET_ADDRESS = '0xb47e3cd837dDF8e4c57F05d70Ab865de6e193BBB'
export const NFTX_COVEN_VAULT = '0xd89b16331f39ab3878daf395052851d3ac8cf3cd'
export const NFTX_COVEN_VAULT_ID = '333'
export const NFTX_ERC_1155_VAULT = '0x78e09c5ec42d505742a52fd10078a57ea186002a'
export const NFTX_ERC_1155_VAULT_ID = '61'

// Constructor Params
export const V2_FACTORY_MAINNET = '0x5C69bEe701ef814a2B6a3EDD4B1652CB9cc5aA6f'
export const V3_FACTORY_MAINNET = '0x1F98431c8aD98523631AE4a59f267346ea31F984'
export const V3_INIT_CODE_HASH_MAINNET = '0xe34f199b19b2b4f47f68442619d555527d244f78a3297ea89325f843f87b8b54'
export const V2_INIT_CODE_HASH_MAINNET = '0x96e8ac4277198ff8b6f785478aa9a39f403cb768dd02cbee326c3e7da348845f'

export const SOURCE_MSG_SENDER: boolean = true
export const SOURCE_ROUTER: boolean = false

export const ROUTER_REWARDS_DISTRIBUTOR = '0x0000000000000000000000000000000000000000'
export const LOOKSRARE_REWARDS_DISTRIBUTOR = '0x0554f068365eD43dcC98dcd7Fd7A8208a5638C72'
export const LOOKSRARE_TOKEN = '0xf4d2888d29D722226FafA5d9B24F9164c092421E'
