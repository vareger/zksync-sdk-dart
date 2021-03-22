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
        0,
        BigInt.from(1000000000),
        13,
        TimeRange.raw(0, 4294967295));
    changePubKey.setAuth(ChangePubKeyOnchainVariant());

    final signed = await zkSigner.sign(changePubKey);

    final payload =
        '{"type":"ChangePubKey","accountId":55,"account":"0xede35562d3555e61120a151b3c8e8e91d83a378a","newPkHash":"sync:18e8446d7748f2de52b28345bdbc76160e6b35eb","feeToken":0,"fee":"1000000000","nonce":13,"signature":{"pubKey":"40771354dc314593e071eaf4d0f42ccb1fad6c7006c57464feeb7ab5872b7490","signature":"3c206b2d9b6dc055aba53ccbeca6c1620a42fc45bdd66282618fd1f055fdf90c00101973507694fb66edaa5d4591a2b4f56bbab876dc7579a17c7fe309c80301"},"ethAuthData":{"type":"Onchain"},"validFrom":0,"validUntil":4294967295}';
    final expected = json.decode(payload) as Map<String, dynamic>;
    expect(signed.toJson(), equals(expected));
  });

  test('encode signed transfer to Json', () async {
    final transfer = Transfer(
        44,
        EthereumAddress.fromHex('0xede35562d3555e61120a151b3c8e8e91d83a378a'),
        EthereumAddress.fromHex('0x19aa2ed8712072e918632259780e587698ef58df'),
        0,
        BigInt.from(1000000000000),
        BigInt.from(1000000),
        12,
        TimeRange.raw(0, 4294967295));

    final signed = await zkSigner.sign(transfer);

    final payload =
        '{"type":"Transfer","accountId":44,"from":"0xede35562d3555e61120a151b3c8e8e91d83a378a","to":"0x19aa2ed8712072e918632259780e587698ef58df","token":0,"amount":"1000000000000","fee":"1000000","nonce":12,"signature":{"pubKey":"40771354dc314593e071eaf4d0f42ccb1fad6c7006c57464feeb7ab5872b7490","signature":"849281ea1b3a97b3fe30fbd25184db3e7860db96e3be9d53cf643bd5cf7805a30dbf685c1e63fd75968a61bd83d3a1fb3a0b1c68c71fe87d96f1c1cb7de45b05"},"validFrom":0,"validUntil":4294967295}';
    final expected = json.decode(payload) as Map<String, dynamic>;
    expect(signed.toJson(), equals(expected));
  });

  test('encode signed withdraw to Json', () async {
    final transfer = Withdraw(
        44,
        EthereumAddress.fromHex('0xede35562d3555e61120a151b3c8e8e91d83a378a'),
        EthereumAddress.fromHex('0x19aa2ed8712072e918632259780e587698ef58df'),
        0,
        BigInt.from(1000000000000),
        BigInt.from(1000000),
        12,
        TimeRange.raw(0, 4294967295));

    final signed = await zkSigner.sign(transfer);

    final payload =
        '{"type":"Withdraw","accountId":44,"from":"0xede35562d3555e61120a151b3c8e8e91d83a378a","to":"0x19aa2ed8712072e918632259780e587698ef58df","token":0,"amount":"1000000000000","fee":"1000000","nonce":12,"signature":{"pubKey":"40771354dc314593e071eaf4d0f42ccb1fad6c7006c57464feeb7ab5872b7490","signature":"ee8b58e252ecdf76fc4275e87c88072d0c4d50b53c40ac3fd83a396f0989d108d92983a943f08c7ca5a63d9be891185867b89c2450f4d9b73526e1c35c4bf600"},"validFrom":0,"validUntil":4294967295}';
    final expected = json.decode(payload) as Map<String, dynamic>;
    expect(signed.toJson(), equals(expected));
  });
}
