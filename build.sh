#!/usr/bin/env bash

cd src/circuits

# zkcredit_650
./build_circuit.sh zkcredit zkcredit_650 powersOfTau28_hez_final_17.ptau

# zkcredit_700
./build_circuit.sh zkcredit zkcredit_700 powersOfTau28_hez_final_17.ptau

# zkcredit_v2_700_2004
./build_circuit.sh zkcredit_v2 zkcredit_v2_700_2004 powersOfTau28_hez_final_17.ptau
