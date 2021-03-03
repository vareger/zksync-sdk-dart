import 'package:test/test.dart';
import 'package:web3dart/web3dart.dart';
import 'package:zksync/client.dart';
import 'package:zksync/credentials.dart';

void main() {
  test('convert transfer transaction into byte array', () {
    final address = "0x46a23E25df9A0F6c18729ddA9Ad1aF3b6A131160".toLowerCase();
    final transaction = Transfer(
        123,
        EthereumAddress.fromHex(address),
        EthereumAddress.fromHex(address),
        1,
        BigInt.from(10000000),
        BigInt.from(10000),
        42,
        TimeRange.raw(1, 123456789));
    final result = transaction.toBytes();
    expect(
        result,
        equals([
          5,
          0,
          0,
          0,
          123,
          70,
          162,
          62,
          37,
          223,
          154,
          15,
          108,
          24,
          114,
          157,
          218,
          154,
          209,
          175,
          59,
          106,
          19,
          17,
          96,
          70,
          162,
          62,
          37,
          223,
          154,
          15,
          108,
          24,
          114,
          157,
          218,
          154,
          209,
          175,
          59,
          106,
          19,
          17,
          96,
          0,
          1,
          0,
          19,
          18,
          208,
          0,
          125,
          1,
          0,
          0,
          0,
          42,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
          0,
          0,
          0,
          7,
          91,
          205,
          21
        ]));
  });

  test('convert withdraw transaction into byte array', () {
    final address = "0x46a23E25df9A0F6c18729ddA9Ad1aF3b6A131160".toLowerCase();
    final transaction = Withdraw(
        123,
        EthereumAddress.fromHex(address),
        EthereumAddress.fromHex(address),
        1,
        BigInt.from(10000000),
        BigInt.from(10000),
        42,
        TimeRange.raw(1, 123456789));
    final result = transaction.toBytes();
    expect(
        result,
        equals([
          3,
          0,
          0,
          0,
          123,
          70,
          162,
          62,
          37,
          223,
          154,
          15,
          108,
          24,
          114,
          157,
          218,
          154,
          209,
          175,
          59,
          106,
          19,
          17,
          96,
          70,
          162,
          62,
          37,
          223,
          154,
          15,
          108,
          24,
          114,
          157,
          218,
          154,
          209,
          175,
          59,
          106,
          19,
          17,
          96,
          0,
          1,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          152,
          150,
          128,
          125,
          1,
          0,
          0,
          0,
          42,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
          0,
          0,
          0,
          7,
          91,
          205,
          21
        ]));
  });

  test('convert change pubkey transaction into byte array', () {
    final address = "0x46a23E25df9A0F6c18729ddA9Ad1aF3b6A131160".toLowerCase();
    final zksaddr = "sync:2841296e8e99ec2605e86467fd6e62f3e5f3320d";
    final transaction = ChangePubKey(
        123,
        EthereumAddress.fromHex(address),
        ZksPubkeyHash.fromHex(zksaddr),
        1,
        BigInt.from(10000),
        42,
        TimeRange.raw(1, 123456789),
        ChangePubKeyOnchainVariant());
    final result = transaction.toBytes();
    expect(
        result,
        equals([
          7,
          0,
          0,
          0,
          123,
          70,
          162,
          62,
          37,
          223,
          154,
          15,
          108,
          24,
          114,
          157,
          218,
          154,
          209,
          175,
          59,
          106,
          19,
          17,
          96,
          40,
          65,
          41,
          110,
          142,
          153,
          236,
          38,
          5,
          232,
          100,
          103,
          253,
          110,
          98,
          243,
          229,
          243,
          50,
          13,
          0,
          1,
          125,
          1,
          0,
          0,
          0,
          42,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
          0,
          0,
          0,
          7,
          91,
          205,
          21
        ]));
  });

  test('convert forced exit transaction into byte array', () {
    final address = "0x46a23E25df9A0F6c18729ddA9Ad1aF3b6A131160".toLowerCase();
    final transaction = ForcedExit(123, EthereumAddress.fromHex(address), 1,
        BigInt.from(10000), 42, TimeRange.raw(1, 123456789));
    final result = transaction.toBytes();
    expect(
        result,
        equals([
          8,
          0,
          0,
          0,
          123,
          70,
          162,
          62,
          37,
          223,
          154,
          15,
          108,
          24,
          114,
          157,
          218,
          154,
          209,
          175,
          59,
          106,
          19,
          17,
          96,
          0,
          1,
          125,
          1,
          0,
          0,
          0,
          42,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          1,
          0,
          0,
          0,
          0,
          7,
          91,
          205,
          21
        ]));
  });

  test('convert transfer transaction into ethereum sign message', () {
    final address = "0x46a23E25df9A0F6c18729ddA9Ad1aF3b6A131160".toLowerCase();
    final transaction = Transfer(
        123,
        EthereumAddress.fromHex(address),
        EthereumAddress.fromHex(address),
        1,
        BigInt.from(10000000),
        BigInt.from(10000),
        42,
        TimeRange.raw(1, 123456789));
    final result = transaction.toEthereumSignMessage("ETH", 18, nonce: true);
    expect(
        result,
        equals(
            "Transfer 0.00000000001 ETH to: 0x46a23e25df9a0f6c18729dda9ad1af3b6a131160\nFee: 0.00000000000001 ETH\nNonce: 42"));
  });

  test('convert withdraw transaction into ethereum sign message', () {
    final address = "0x46a23E25df9A0F6c18729ddA9Ad1aF3b6A131160".toLowerCase();
    final transaction = Withdraw(
        123,
        EthereumAddress.fromHex(address),
        EthereumAddress.fromHex(address),
        1,
        BigInt.from(10000000),
        BigInt.from(10000),
        42,
        TimeRange.raw(1, 123456789));
    final result = transaction.toEthereumSignMessage("ETH", 18, nonce: true);
    expect(
        result,
        equals(
            "Withdraw 0.00000000001 ETH to: 0x46a23e25df9a0f6c18729dda9ad1af3b6a131160\nFee: 0.00000000000001 ETH\nNonce: 42"));
  });

  test('convert forced exit transaction into ethereum sign message', () {
    final address = "0x46a23E25df9A0F6c18729ddA9Ad1aF3b6A131160".toLowerCase();
    final transaction = ForcedExit(123, EthereumAddress.fromHex(address), 1,
        BigInt.from(10000), 42, TimeRange.raw(1, 123456789));
    final result = transaction.toEthereumSignMessage("ETH", 18, nonce: true);
    expect(
        result,
        equals(
            "ForcedExit ETH to: 0x46a23e25df9a0f6c18729dda9ad1af3b6a131160\nFee: 0.00000000000001 ETH\nNonce: 42"));
  });

  test('convert change public key transaction into ethereum sign message', () {
    final address = "0x46a23E25df9A0F6c18729ddA9Ad1aF3b6A131160".toLowerCase();
    final zksaddr = "sync:2841296e8e99ec2605e86467fd6e62f3e5f3320d";
    final transaction = ChangePubKey(
        123,
        EthereumAddress.fromHex(address),
        ZksPubkeyHash.fromHex(zksaddr),
        1,
        BigInt.from(10000),
        42,
        TimeRange.raw(1, 123456789),
        ChangePubKeyOnchainVariant());
    final result = transaction.toEthereumSignMessagePart("ETH", 18);
    expect(
        result,
        equals(
            "Set signing key: 2841296e8e99ec2605e86467fd6e62f3e5f3320d\nFee: 0.00000000000001 ETH"));
  });

  test('convert change public key onchain transaction into ethereum sign data',
      () {
    final address = "0x46a23E25df9A0F6c18729ddA9Ad1aF3b6A131160".toLowerCase();
    final zksaddr = "sync:2841296e8e99ec2605e86467fd6e62f3e5f3320d";
    final transaction = ChangePubKey(
        123,
        EthereumAddress.fromHex(address),
        ZksPubkeyHash.fromHex(zksaddr),
        1,
        BigInt.from(10000),
        42,
        TimeRange.raw(1, 123456789),
        ChangePubKeyOnchainVariant());
    final result = transaction.toEthereumSignData();
    expect(
        result,
        equals([
          40,
          65,
          41,
          110,
          142,
          153,
          236,
          38,
          5,
          232,
          100,
          103,
          253,
          110,
          98,
          243,
          229,
          243,
          50,
          13,
          0,
          0,
          0,
          42,
          0,
          0,
          0,
          123,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0,
          0
        ]));
  });
}
