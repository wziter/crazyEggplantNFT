from web3 import Web3, HTTPProvider
from eth_account.messages import encode_defunct

def genSignature():
    private_key = "0x227dbb8586117d55284e26620bc76534dfbd2394be34cf4a09cb775d593b6f2b"
    account = "0x5B38Da6a701c568545dCfcB03FcB875f56beddC4"
    tokenId = 0
    rpc = "https://rpc.ankr.com/eth"
    signer = "0xe16C1623c1AA7D919cd2241d8b36d9E79C1Be2A2"  #公钥，用来在solidity中验证签名的

    w3 = Web3(HTTPProvider(rpc))
    msg = Web3.solidity_keccak(["address", "uint256"], [account, tokenId])
    # print(msg.hex())

    etfMessage = encode_defunct(hexstr = msg.hex())
    # print(etfMessage)

    signedMessage = w3.eth.account.sign_message(etfMessage, private_key)
    # print(signedMessage)
    # SignedMessage(message_hash=
    # HexBytes('0xb42ca4636f721c7a331923e764587e98ec577cea1a185f60dfcc14dbb9bd900b'), 
    # r=25805576465518500104433991856593424968167929899608770960989279157854960973629, 
    # s=38720583321114016822984218271803256473221326760278332316709218814629445602084, 
    # v=28, 
    # signature=HexBytes('0x390d704d7ab732ce034203599ee93dd5d3cb0d4d1d7c600ac11726659489773d559b12d220f99f41d17651b0c1c6a669d346a397f8541760d6b32a5725378b241c'))
    return signedMessage