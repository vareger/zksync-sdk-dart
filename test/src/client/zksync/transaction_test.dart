import 'package:test/test.dart';
import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart';
import 'package:zksync/client.dart';
import 'package:zksync/credentials.dart';

void main() {
  Token token = Token(
      1,
      EthereumAddress.fromHex("0x0000000000000000000000000000000000000000"),
      "ETH",
      18);
  final contentHash = hexToBytes(
      "0000000000000000000000000000000000000000000000000000000000000123");
  final nft = NFT(
      100000,
      "NFT-100000",
      44,
      contentHash,
      EthereumAddress.fromHex("0x0000000000000000000000000000000000000000"),
      2,
      EthereumAddress.fromHex("0x0000000000000000000000000000000000000000"));
  test('convert transfer transaction into byte array', () {
    final address = "0x46a23E25df9A0F6c18729ddA9Ad1aF3b6A131160".toLowerCase();
    final transaction = Transfer(
        123,
        EthereumAddress.fromHex(address),
        EthereumAddress.fromHex(address),
        token,
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
          0,
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
        token,
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
          0,
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
        token,
        BigInt.from(10000),
        42,
        TimeRange.raw(1, 123456789));
    transaction.setAuth(ChangePubKeyOnchainVariant());
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
          0,
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
    final transaction = ForcedExit(123, EthereumAddress.fromHex(address), token,
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
          0,
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

  test('convert mint nft transaction into byte array', () {
    final transaction = MintNft(
        44,
        EthereumAddress.fromHex('0xede35562d3555e61120a151b3c8e8e91d83a378a'),
        contentHash,
        EthereumAddress.fromHex('0x19aa2ed8712072e918632259780e587698ef58df'),
        token,
        BigInt.from(1000000),
        12);
    final result = transaction.toBytes();
    expect(
        result,
        equals([
          9,
          0,
          0,
          0,
          44,
          237,
          227,
          85,
          98,
          211,
          85,
          94,
          97,
          18,
          10,
          21,
          27,
          60,
          142,
          142,
          145,
          216,
          58,
          55,
          138,
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
          1,
          35,
          25,
          170,
          46,
          216,
          113,
          32,
          114,
          233,
          24,
          99,
          34,
          89,
          120,
          14,
          88,
          118,
          152,
          239,
          88,
          223,
          0,
          0,
          0,
          1,
          125,
          3,
          0,
          0,
          0,
          12
        ]));
  });

  test('convert withdraw nft transaction into byte array', () {
    final transaction = WithdrawNft(
        token,
        44,
        EthereumAddress.fromHex('0xede35562d3555e61120a151b3c8e8e91d83a378a'),
        EthereumAddress.fromHex('0x19aa2ed8712072e918632259780e587698ef58df'),
        nft,
        BigInt.from(1000000),
        12,
        TimeRange.raw(0, 4294967295));
    final result = transaction.toBytes();
    expect(
        result,
        equals([
          10,
          0,
          0,
          0,
          44,
          237,
          227,
          85,
          98,
          211,
          85,
          94,
          97,
          18,
          10,
          21,
          27,
          60,
          142,
          142,
          145,
          216,
          58,
          55,
          138,
          25,
          170,
          46,
          216,
          113,
          32,
          114,
          233,
          24,
          99,
          34,
          89,
          120,
          14,
          88,
          118,
          152,
          239,
          88,
          223,
          0,
          1,
          134,
          160,
          0,
          0,
          0,
          1,
          125,
          3,
          0,
          0,
          0,
          12,
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
          255,
          255,
          255,
          255
        ]));
  });

  test('convert transfer transaction into ethereum sign message', () {
    final address = "0x46a23E25df9A0F6c18729ddA9Ad1aF3b6A131160".toLowerCase();
    final transaction = Transfer(
        123,
        EthereumAddress.fromHex(address),
        EthereumAddress.fromHex(address),
        token,
        BigInt.from(10000000),
        BigInt.from(10000),
        42,
        TimeRange.raw(1, 123456789));
    final result = transaction.toEthereumSignMessage(nonce: true);
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
        token,
        BigInt.from(10000000),
        BigInt.from(10000),
        42,
        TimeRange.raw(1, 123456789));
    final result = transaction.toEthereumSignMessage(nonce: true);
    expect(
        result,
        equals(
            "Withdraw 0.00000000001 ETH to: 0x46a23e25df9a0f6c18729dda9ad1af3b6a131160\nFee: 0.00000000000001 ETH\nNonce: 42"));
  });

  test('convert forced exit transaction into ethereum sign message', () {
    final address = "0x46a23E25df9A0F6c18729ddA9Ad1aF3b6A131160".toLowerCase();
    final transaction = ForcedExit(123, EthereumAddress.fromHex(address), token,
        BigInt.from(10000), 42, TimeRange.raw(1, 123456789));
    final result = transaction.toEthereumSignMessage(nonce: true);
    expect(
        result,
        equals(
            "ForcedExit ETH to: 0x46a23e25df9a0f6c18729dda9ad1af3b6a131160\nFee: 0.00000000000001 ETH\nNonce: 42"));
  });

  test('convert mint nft transaction into ethereum sign message', () {
    final transaction = MintNft(
        44,
        EthereumAddress.fromHex('0xede35562d3555e61120a151b3c8e8e91d83a378a'),
        contentHash,
        EthereumAddress.fromHex('0x19aa2ed8712072e918632259780e587698ef58df'),
        token,
        BigInt.from(10000),
        42);
    final result = transaction.toEthereumSignMessage(nonce: true);
    expect(
        result,
        equals(
            "MintNFT 0x0000000000000000000000000000000000000000000000000000000000000123 for: 0x19aa2ed8712072e918632259780e587698ef58df\nFee: 0.00000000000001 ETH\nNonce: 42"));
  });

  test('convert withdraw nft transaction into ethereum sign message', () {
    final transaction = WithdrawNft(
        token,
        44,
        EthereumAddress.fromHex('0xede35562d3555e61120a151b3c8e8e91d83a378a'),
        EthereumAddress.fromHex('0x19aa2ed8712072e918632259780e587698ef58df'),
        nft,
        BigInt.from(10000),
        42,
        TimeRange.raw(0, 4294967295));
    final result = transaction.toEthereumSignMessage(nonce: true);
    expect(
        result,
        equals(
            "WithdrawNFT 100000 to: 0x19aa2ed8712072e918632259780e587698ef58df\nFee: 0.00000000000001 ETH\nNonce: 42"));
  });

  test('convert transfer nft transaction into ethereum sign message (batch)',
      () {
    final transferNft = Transfer(
        44,
        EthereumAddress.fromHex('0xede35562d3555e61120a151b3c8e8e91d83a378a'),
        EthereumAddress.fromHex('0x19aa2ed8712072e918632259780e587698ef58df'),
        nft,
        BigInt.one,
        BigInt.zero,
        42,
        TimeRange.raw(0, 4294967295));
    final payFee = Transfer(
        44,
        EthereumAddress.fromHex('0xede35562d3555e61120a151b3c8e8e91d83a378a'),
        EthereumAddress.fromHex('0x19aa2ed8712072e918632259780e587698ef58df'),
        token,
        BigInt.zero,
        BigInt.from(10000),
        42,
        TimeRange.raw(0, 4294967295));
    final prepared = [transferNft, payFee]
        .map((t) => t.toEthereumSignMessage(nonce: false))
        .join("\n");
    final result = transferNft.appendNonce(prepared);
    expect(
        result,
        equals(
            "Transfer 1.0 NFT-100000 to: 0x19aa2ed8712072e918632259780e587698ef58df\nFee: 0.00000000000001 ETH\nNonce: 42"));
  });

  test('convert change public key transaction into ethereum sign message', () {
    final address = "0x46a23E25df9A0F6c18729ddA9Ad1aF3b6A131160".toLowerCase();
    final zksaddr = "sync:2841296e8e99ec2605e86467fd6e62f3e5f3320d";
    final transaction = ChangePubKey(
        123,
        EthereumAddress.fromHex(address),
        ZksPubkeyHash.fromHex(zksaddr),
        token,
        BigInt.from(10000),
        42,
        TimeRange.raw(1, 123456789));
    transaction.setAuth(ChangePubKeyOnchainVariant());
    final result = transaction.toEthereumSignMessage(nonce: false);
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
        token,
        BigInt.from(10000),
        42,
        TimeRange.raw(1, 123456789));
    transaction.setAuth(ChangePubKeyOnchainVariant());
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
