## zkdid-circuits

This Github repo contains the circuits for zero-knowledge credentials.


### Prerequisites

#### Install Rust
```
curl --proto '=https' --tlsv1.2 https://sh.rustup.rs -sSf | sh
```

#### Install circom
```
cargo install --path circom
```

#### Install snarkjs
```
npm install -g snarkjs
```

### Install dependencies

```
npm install
```

### Download ptau files for bn128
```
./download_ptau.sh
```

### Build Circuits
```
./build.sh
```

### How Does it Work

Zero-knowledge proofs allow you to prove that your ZK credential fits certain criterion without disclosing your information.
