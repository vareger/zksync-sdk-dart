---
title: 'ZkSync Dart SDK'
disqus: hackmd
---

ZkSync SDK
===

<!-- ![downloads](https://img.shields.io/github/downloads/atom/atom/total.svg)
![build](https://img.shields.io/appveyor/ci/:user/:repo.svg)
![chat](https://img.shields.io/discord/:serverId.svg) -->

## Table of Contents

[TOC]

## Getting started

1. Connect to the zkSync network.
2. Deposit assets from Ethereum into zkSync.
3. Make transfers.
4. Withdraw funds back to Ethereum mainnet (or testnet).

### Adding dependencies

Library requres precompiled binary of zkSync cryptography implementation.
You can download it from [official repo](https://github.com/zksync-sdk/zksync-crypto-c/releases)

Here you need only add just one dependency into your build configuration.

```yaml=
name: <your_app_name>
...

environment:
  sdk: '>=2.10.0 <3.0.0'

dependencies:
  zksync: ^0.0.1
  ...
```

Native library built for these platforms:

##### Desktop

- Linux x86_64
- OSX x86_64 (MacOS 11 BigSur included)
- Windows x86_64

##### Android

- Arm64-v8a
- Armeabi-v7a
- x86
- x86_64

##### iOS

- i386
- x86_64

### Imports

Client library divided to three separate package. Just add imports to `imports` block of your main file;

```dart
import 'package:zksync/client.dart'; // ZkSync RPC/REST client
import 'package:zksync/credentials.dart'; // Crypto Credentials
import 'package:zksync/zksync.dart'; // Main Wallet
```

### Creating signers

All operation messages in zkSync network must be signed by your secured private key. We're split thats keys as Level 1 (L1) for Ethereum and Level 2 (L2) for zkSync network.

For using zkSync network you need to create `ZkSigner` instance. You can do it using one of the next options:

Using seed bytes (like MNEMONIC phrase). Must have length >= 32

```dart
final zkSigner = ZksSigner.seed(SEED);
```

Using raw private key

```dart
final rawPrivateKey = hex.decode('0x...');

final zkSigner = ZksSigner.raw(rawPrivateKey);
```

Using raw private key in hex

```dart
final zkSigner = ZksSigner.hex('0x...');
```

Using EthSigner (explained below). The private key used by ZkSigner is implicitly derived from Ethereum signature of a special message.

```dart
final ethSigner = ...;

final zkSigner = await ZksSigher.fromEthSigner(ethSigner, ChainId.Rinkeby);
```

---

In case of interacting with Ethereum network like `Deposit` or onchain `Withdraw` and for creating ZkSigner you may need to create `EthSigner`.

Using raw private key in hex

```dart
final ethSigner = EthSigner.hex(privateKey, chainId: ChainId.Rinkeby.getChainId());
```

Using raw private key

```dart
final rawPrivateKey = hex.decode('0x...');

final ethSigner = EthSigner.raw(privateKey);
```

Using `Credentials` from Web3dart

```dart
import 'package:web3dart/web3dart.dart' as web3;
```

```dart
final credentials = web3.EthPrivateKey.fromHex(hexKey);
```

### Connecting to zkSync network

For interact with both zkSync and Ethereum networks you need to create providers with endpoints to blockchain nodes

#### zkSync client

Library has predefined URLs for the next networks `ChainId.Mainnet`, `ChainId.Ropsten`, `ChainId.Rinkeby` that officially supports by MatterLabs. Also you can use local node for testing `ChainId.Localhost` set to `http://127.0.0.1:3030`

```dart
final zksync = ZkSyncClient.fromChainId(ChainId.Rinkeby);
```

You can create `ZkSyncClient` with any custom URL

```dart
import 'package:http/http.dart';
```

```dart
final zksync = ZkSyncClient('http://localhost:3030', Client());
```

#### Ethereum client

For onchain operation in Ethereum network you may create `EthereumClient`

```dart
final ethSigner = ...;

final ethereum =
      EthereumClient('http://localhost:8545', ethSigner.credentials, ChainId.Rinkeby);
```

### Creating a Wallet

To control your account in zkSync, use the `Wallet`. It can sign transactions with keys stored in `ZkSigner` and `EthSigner` and send transaction to zkSync network using `ZkSyncClient`.

```dart
final ethSigner = ...;
final zkSigner = ...;
final ethClient = ...;
final zksClient = ...;

final wallet = Wallet(zksClient, ethClient, zkSigner, ethSigner);
```

### Depositing assets from Ethereum into zkSync

Let's try to deposit 1.0 ETH to our zkSync account.

```dart
final ethSigner = ...;
final ethClient = ...;

final receiver = await ethSigner.extractAddress();

final depositTx = await ethClient.deposit(Token.eth,
      EtherAmount.fromUnitAndValue(EtherUnit.ether, 1).getInWei, receiver);
```

### Checking your zkSync balance

You should be want to check your balance in zkSync network after deposit.

```dart
final wallet = ...;

final state = await wallet.getState();
final balance = state.commited.balances['ETH'];
```

### Unlocking zkSync account

To make any transaction in zkSync network, you must register your ZkSigner's public key to your account provided EthSigner.

```dart
final zkSigner = ...;
final wallet = ...;

final authTx = await wallet.setSigningKey(
      ZksPubkeyHash.fromHex(zkSigner.publicKeyHash),
      token: Token.eth);
print(authTx);
```

### Making transfer funds in zkSync

Now after `Deposit` and `Unlocking` your account you can create second account and transfer some funds to it.

> Note that we can send assets to any fresh Ethereum account, without preliminary registration!

We're going to transfer 0.1 ETH

```dart
final wallet = ...;

final receiver =
      EthereumAddress.fromHex('0x...');

final tx = await wallet.transfer(
      receiver, EtherAmount.fromUnitAndValue(EtherUnit.eth, 0.1).getInWei,
      token: Token.eth);
print(tx);
```

### Withdrawing funds back to Ethereum

All your funds can be withdrawn back to any yours account in Ethereum.

```dart
final wallet = ...;

final withdrawTx = await wallet.withdraw(
      receiver, EtherAmount.fromUnitAndValue(EtherUnit.eth, 0.5).getInWei,
      token: Token.eth);
print(withdrawTx);
```

Assets will be withdrawn to the target wallet after the zero-knowledge proof of zkSync block with this operation is generated and verified by the mainnet contract.

### Forced and Full exit

Also you can withdraw all your funds back to your onchain account

On zkSync

```dart
final wallet = ...;

final exitTx = await wallet.forcedExit(receiver, token: Token.eth);
print(exitTx);
```

On Ethereum (onchain)

```dart
final ethClient = ...;
final wallet = ...;

final exitTx =
      await ethClient.fullExit(Token.eth, await wallet.getAccountId());
print(exitTx);
```
