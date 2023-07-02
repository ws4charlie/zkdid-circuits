#!/usr/bin/env bash


#!/usr/bin/env bash

if [ "$#" -ne 3 ]
then
  echo "Usage: build_circuit.sh zkcredit zkcredit_650 powersOfTau28_hez_final_17.ptau"
  exit 1
fi

CIRCUIT="$1/$2.circom"
OUTPUT="build/$1"
OUTPUT_JS="build/$1/$2_js"
R1CS="$2.r1cs"
WASM="$2.wasm"
PTAU="../../../ptau/$3"
INPUT="input.json"

# clean
mkdir -p $OUTPUT && rm -rf $OUTPUT_JS

# build circuit
echo -e "building $CIRCUIT ..."

circom $CIRCUIT --r1cs --wasm -o $OUTPUT && mv $OUTPUT/$R1CS $OUTPUT_JS && cp $1/$INPUT $OUTPUT_JS/$INPUT

cd "$OUTPUT_JS"

node generate_witness.js $WASM $INPUT witness.wtns

snarkjs groth16 setup $R1CS $PTAU "$2.zkey"

snarkjs zkey contribute "$2.zkey" "$2_final.zkey" --name="1st Contributor Name" -v

snarkjs zkey export verificationkey "$2_final.zkey" verification_key.json

snarkjs groth16 prove "$2_final.zkey" witness.wtns proof.json public.json

snarkjs groth16 verify verification_key.json public.json proof.json

snarkjs zkey export solidityverifier "$2_final.zkey" "$2_verifier.sol"
