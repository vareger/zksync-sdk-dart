import 'dart:convert';

import 'package:test/test.dart';
import 'package:web3dart/web3dart.dart';
import 'package:zksync/client.dart';
import 'package:zksync/credentials.dart';

void main() async {
  final privateKey =
      '000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f';

  final ethSigner =
      EthSigner.hex(privateKey, chainId: ChainId.Mainnet.getChainId());
  final zkSigner = await ZksSigner.fromEthSigner(ethSigner, ChainId.Mainnet);

  test('encode signed changePubKey to Json', () async {
    final changePubKey = ChangePubKey(
        55,
        EthereumAddress.fromHex('0xede35562d3555e61120a151b3c8e8e91d83a378a'),
        ZksPubkeyHash.fromHex('sync:18e8446d7748f2de52b28345bdbc76160e6b35eb'),
        Token.eth,
        BigInt.from(1000000000),
        13,
        TimeRange.raw(0, 4294967295));
    changePubKey.setAuth(ChangePubKeyOnchainVariant());

    final signed = await zkSigner.sign(changePubKey);

    final payload =
        '{"type":"ChangePubKey","accountId":55,"account":"0xede35562d3555e61120a151b3c8e8e91d83a378a","newPkHash":"sync:18e8446d7748f2de52b28345bdbc76160e6b35eb","feeToken":0,"fee":"1000000000","nonce":13,"signature":{"pubKey":"40771354dc314593e071eaf4d0f42ccb1fad6c7006c57464feeb7ab5872b7490","signature":"31a6be992eeb311623eb466a49d54cb1e5b3d44e7ccc27d55f82969fe04824aa92107fefa6b0a2d7a07581ace7f6366a5904176fae4aadec24d75d3d76028500"},"ethAuthData":{"type":"Onchain"},"validFrom":0,"validUntil":4294967295}';
    final expected = json.decode(payload) as Map<String, dynamic>;
    expect(signed.toJson(), equals(expected));
  });

  test('encode signed transfer to Json', () async {
    final transfer = Transfer(
        44,
        EthereumAddress.fromHex('0xede35562d3555e61120a151b3c8e8e91d83a378a'),
        EthereumAddress.fromHex('0x19aa2ed8712072e918632259780e587698ef58df'),
        Token.eth,
        BigInt.from(1000000000000),
        BigInt.from(1000000),
        12,
        TimeRange.raw(0, 4294967295));

    final signed = await zkSigner.sign(transfer);

    final payload =
        '{"type":"Transfer","accountId":44,"from":"0xede35562d3555e61120a151b3c8e8e91d83a378a","to":"0x19aa2ed8712072e918632259780e587698ef58df","token":0,"amount":"1000000000000","fee":"1000000","nonce":12,"signature":{"pubKey":"40771354dc314593e071eaf4d0f42ccb1fad6c7006c57464feeb7ab5872b7490","signature":"5c3304c8d1a8917580c9a3f8edb9d8698cbe9e6e084af93c13ac3564fa052588b93830785b3d0f60a1a193ec4fff61f81b95f0d16bf128ee21a6ceb09ef88602"},"validFrom":0,"validUntil":4294967295}';
    final expected = json.decode(payload) as Map<String, dynamic>;
    expect(signed.toJson(), equals(expected));
  });

  test('encode signed withdraw to Json', () async {
    final transfer = Withdraw(
        44,
        EthereumAddress.fromHex('0xede35562d3555e61120a151b3c8e8e91d83a378a'),
        EthereumAddress.fromHex('0x19aa2ed8712072e918632259780e587698ef58df'),
        Token.eth,
        BigInt.from(1000000000000),
        BigInt.from(1000000),
        12,
        TimeRange.raw(0, 4294967295));

    final signed = await zkSigner.sign(transfer);

    final payload =
        '{"type":"Withdraw","accountId":44,"from":"0xede35562d3555e61120a151b3c8e8e91d83a378a","to":"0x19aa2ed8712072e918632259780e587698ef58df","token":0,"amount":"1000000000000","fee":"1000000","nonce":12,"signature":{"pubKey":"40771354dc314593e071eaf4d0f42ccb1fad6c7006c57464feeb7ab5872b7490","signature":"3e2866bb00f892170cc3592d48aec7eb4afba75bdd0a530780fa1dcbdf857d07d75deb774142a93e3d1ca3be29e614e50892b95702b6461f86ddf78b9ab11a01"},"validFrom":0,"validUntil":4294967295}';
    final expected = json.decode(payload) as Map<String, dynamic>;
    expect(signed.toJson(), equals(expected));
  });
}
