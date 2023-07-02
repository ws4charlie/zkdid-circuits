pragma circom 2.0.0;

include "../../../node_modules/circomlib/circuits/sha256/sha256.circom";
include "../../../node_modules/circomlib/circuits/comparators.circom";
include "../../../node_modules/circomlib/circuits/bitify.circom";

template ZkCredit(C, D) {
    signal input dob;
    signal input name;
    signal input ssn;
    signal input credit;
    signal output out[2];

    // the DOB has to be earlier than D
    component lt = LessThan(128);
    lt.in[0] <== dob;
    lt.in[1] <== D;
    lt.out === 1;

    // the credit score has to be greater than or equal to minumum score
    component gt = GreaterEqThan(128);
    gt.in[0] <== credit;
    gt.in[1] <== C;
    gt.out === 1;

    // the root hash of sceret inputs have to match the commitment
    component num2bits[4];
    component bits2num[2];
    component sha = Sha256(512);

    num2bits[0] = Num2Bits(128);
    num2bits[1] = Num2Bits(128);
    num2bits[2] = Num2Bits(128);
    num2bits[3] = Num2Bits(128);

    bits2num[0] = Bits2Num(128);
    bits2num[1] = Bits2Num(128);

    // fill in 512-bit private data
    num2bits[0].in <== dob;
    num2bits[1].in <== name;
    num2bits[2].in <== ssn;
    num2bits[3].in <== credit;

    // convert private data to big-endian as sha256 input
    for (var i=0; i<128; i++) {
        sha.in[i] <== num2bits[0].out[127-i];
        sha.in[i+128] <== num2bits[1].out[127-i];
        sha.in[i+256] <== num2bits[2].out[127-i];
        sha.in[i+384] <== num2bits[3].out[127-i];
    }

    // convert `sha256` out (big-endian) back to numbers
    for (var k=0; k<128; k++) {
        bits2num[0].in[k] <== sha.out[127-k];
        bits2num[1].in[k] <== sha.out[255-k];
    }

    out[0] <== bits2num[0].out;
    out[1] <== bits2num[1].out;
}