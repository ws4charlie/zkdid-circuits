
### On-chain contracts:

1. The issuer will deploy an NFT (SBT) contract "QuickKYC ZKCred V1 (QZK)"

   Deploy a non-transferable NFT smart contract (zkCredential issuer will be the owner) to EVM with following APIs
    - Use Openzeppelin `ERC721Mintable` (https://docs.openzeppelin.com/contracts/2.x/api/token/erc721#ERC721Mintable)
      as base and remove transfer-related methods.

    - `constructor` will take single parameter of zkCredential type (e.g., "https://ld.findora.org/creddential-kyc/v1").

      `constructor(string credType)`

    - `mint` function will take 2 parameters

      `mint(address to, string(or bytes) commitment)`

    - `credType` returns zk credential type

      `credType() public view returns (string _credType)`

    - `commitment` returns zkCredential's commitment

      `commitment(uint256 tokenId) public view returns (string commitment)`

<br/>

2. The issuer also deploys 2 smart contracts to provide zk proof verification service.

     - https://github.com/FindoraNetwork/zkdid-circuits/blob/main/src/circuits/build/zkcredit/zkcredit_700_js/zkcredit_650_verifier.sol
     - https://github.com/FindoraNetwork/zkdid-circuits/blob/main/src/circuits/build/zkcredit/zkcredit_700_js/zkcredit_700_verifier.sol
     - `verifyProof` returns true only when proof is valid AND matching the input
<pre>
       verifyProof(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[2] memory input
        ) public view returns (bool r)
</pre>

<br/>

3. The verifier deploys a smart contract "ZKVerifier" to EVM with following APIs
    - `whiteList` takes 3 parameters for whitelisting:
      - `credType` (e.g., "https://ld.findora.org/creddential-kyc/v1")
      - `token` (the SBT token address)
      - `verifier` (the one deployed by issuer)
      - `whiteList(string credType, address token, address verifier)`

      Note: A "ZKVerifier" can whitelist many verifiers to support different types of zk credentials (and different checks) issued by different credential issuers.

    - `credTypes` returns full list of whitelisted credential types.

      `credTypes() public view returns (string[] memory)`

    - `verify` checks token, proof passed by the user according to credType
<pre>
       verify(
           string credType,
           uint256 tokenId,
           uint[2] memory a,
           uint[2][2] memory b,
           uint[2] memory c,
           uint[2] memory input) public view returns (bool r)
</pre>

        check1>: check and see if credType is whitelisted or not
        check2>: check ownership(msg.sender) of the tokenId if already whitelisted
        check3>: get commitment by tokenId from the SBT
        check4>: get whitelisted verifier contract address and call `verifyProof` function with above commitment.
        return>: true/false
<br/>

### Off-chain server:

1. Host an credential issuer server [SpruceID HTTP Server](https://www.spruceid.dev/didkit/didkit-packages/http-server)

2. Host an [SIEW](https://github.com/spruceid/siwe-quickstart) (if have time) to verify ownership of Metamask wallet.


3. A zkCredential issue server to issue SBT to user's Metamask address
   - `address`: user metamask
   - `cred`: the credential struct
   - return: transaction Hash

   `fn (address: string, cred: Credential) -> string`
<br/>


### Demo credential

transparent: https://github.com/FindoraNetwork/zkdid-circuits/blob/main/creds/credential-signed.jsonld#L22

zero-knoledge: https://github.com/FindoraNetwork/zkdid-circuits/blob/main/creds/zk-credential-signed.jsonld#L3

<br/>

### Demo credential encoding
<pre>
{
  dob:    12546000  ==> HEX:   00000000000000000000000000BF6FD0
                    ==> Input: 12546000

  name:   Bob       ==> HEX:   00000000000000000000000000426F62
                    ==> Input: 4353890

  ssn:    433543937 ==> HEX:   00000000000000000000000019D75B01
                    ==> Input: 433543937

  credit: 702       ==> HEX:   000000000000000000000000000002BE
                    ==> Input: 702
}

DATA: 00000000000000000000000000BF6FD000000000000000000000000000426F6200000000000000000000000019D75B01000000000000000000000000000002BE
HASH: 8d9d6f7e9202abc8d7143a7562bb9e8299c75c454c9d79669328cca5615e0ae0
</pre>

<br/>

### How to generate zkProof using CLI

1. Create a input file (e.g., `input.json`) and fill in credential data.
```
echo "{\"dob\": \"12546000\", \"name\": \"4353890\", \"ssn\": \"433543937\", \"credit\": \"702\"}" > input.json
```

2. Compute witness with WebAssembly (and input file) on circuit `zkcredit_650.circom`.
```
JS_DIR=src/circuits/build/zkcredit/zkcredit_650_js && node $JS_DIR/generate_witness.js $JS_DIR/zkcredit_650.wasm input.json witness.wtns
```

3. Generate zero-knowledge proof with witness and proving key
```
JS_DIR=src/circuits/build/zkcredit/zkcredit_650_js && snarkjs groth16 prove $JS_DIR/zkcredit_0001.zkey witness.wtns proof.json public.json
```

### [How to generate zkProof in browser](https://www.npmjs.com/package/snarkjs?activeTab=readme)
