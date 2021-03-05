import 'package:convert/convert.dart';
import 'package:test/test.dart';
import 'package:web3dart/web3dart.dart';
import 'package:zksync/client.dart';
import 'package:zksync/credentials.dart';

void main() async {
  final mockToken = Token(
      0,
      EthereumAddress.fromHex('0x0000000000000000000000000000000000000000'),
      'ETH',
      0);

  final privateKey =
      '000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f';

  final ethSigner =
      EthSigner.hex(privateKey, chainId: ChainId.Mainnet.getChainId());
  final zkSigner = await ZksSigher.fromEthSigner(ethSigner, ChainId.Mainnet);

  final transfer = Transfer(
      44,
      EthereumAddress.fromHex('0xede35562d3555e61120a151b3c8e8e91d83a378a'),
      EthereumAddress.fromHex('0x19aa2ed8712072e918632259780e587698ef58df'),
      0,
      BigInt.from(1000000000000),
      BigInt.from(1000000),
      12,
      TimeRange.raw(0, 4294967295));

  final withdraw = Withdraw(
      44,
      EthereumAddress.fromHex('0xede35562d3555e61120a151b3c8e8e91d83a378a'),
      EthereumAddress.fromHex('0x19aa2ed8712072e918632259780e587698ef58df'),
      0,
      BigInt.from(1000000000000),
      BigInt.from(1000000),
      12,
      TimeRange.raw(0, 4294967295));

  final changePubKey = ChangePubKey(
      55,
      EthereumAddress.fromHex('0xede35562d3555e61120a151b3c8e8e91d83a378a'),
      ZksPubkeyHash.fromHex('sync:18e8446d7748f2de52b28345bdbc76160e6b35eb'),
      0,
      BigInt.from(1000000000),
      13,
      TimeRange.raw(0, 4294967295),
      ChangePubKeyOnchainVariant());

  final forcedExit = ForcedExit(
      44,
      EthereumAddress.fromHex('0x19aa2ed8712072e918632259780e587698ef58df'),
      0,
      BigInt.from(1000000),
      12,
      TimeRange.raw(0, 4294967295));

  test('generate public key (zk)', () async {
    final zkSigner = ZksSigher.seed(hex.decode(
        '000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f'));
    final expectedPublicKey =
        '17f3708f5e2b2c39c640def0cf0010fd9dd9219650e389114ea9da47f5874184';
    final expectedSignature =
        "5462c3083d92b832d540c9068eed0a0450520f6dd2e4ab169de1a46585b394a4292896a2ebca3c0378378963a6bc1710b64c573598e73de3a33d6cec2f5d7403";

    final resultSignature = hex.encode(await zkSigner.signMessage(hex.decode(
        '000102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f202122232425262728292a2b2c2d2e2f303132333435363738393a3b3c3d3e3f')));
    final resultPublicKey = zkSigner.publicKey;

    expect(resultPublicKey, equals(expectedPublicKey));
    expect(resultSignature, equals(expectedSignature));
  });

  test('sign single transfer (zk)', () async {
    final expected =
        '849281ea1b3a97b3fe30fbd25184db3e7860db96e3be9d53cf643bd5cf7805a30dbf685c1e63fd75968a61bd83d3a1fb3a0b1c68c71fe87d96f1c1cb7de45b05';
    final result = await zkSigner.sign(transfer);
    expect(result.signature.signature, equals(expected));
  });

  test('sign single withdraw (zk)', () async {
    final expected =
        'ee8b58e252ecdf76fc4275e87c88072d0c4d50b53c40ac3fd83a396f0989d108d92983a943f08c7ca5a63d9be891185867b89c2450f4d9b73526e1c35c4bf600';
    final result = await zkSigner.sign(withdraw);
    expect(result.signature.signature, equals(expected));
  });

  test('sign single change pubkey (zk)', () async {
    final expected =
        '3c206b2d9b6dc055aba53ccbeca6c1620a42fc45bdd66282618fd1f055fdf90c00101973507694fb66edaa5d4591a2b4f56bbab876dc7579a17c7fe309c80301';
    final result = await zkSigner.sign(changePubKey);
    expect(result.signature.signature, equals(expected));
  });

  test('sign single forced exit (zk)', () async {
    final expected =
        '5e5089771f94222d64ad7d4a8853bf83d53bf3c063b91250ece46ccefd45d19a1313aee79f19e73dcf11f12ae0fb8c3fdb83bf4fa704384c5c82b4de0831ea03';
    final result = await zkSigner.sign(forcedExit);
    expect(result.signature.signature, equals(expected));
  });

  test('sign single transfer (eth)', () async {
    final expected =
        '4684a8f03c5da84676ff4eae89984f20057ce288b3a072605cbf93ef4bcc8a021306b13a88c6d3adc68347f4b68b1cbdf967861005e934afa50ce2e0c5bced791b';
    final result = await ethSigner.sign(transfer, mockToken);
    expect(hex.encode(result), equals(expected));
  });

  test('sign single withdraw (eth)', () async {
    final expected =
        'a87d458c96f2b78c8b615c7703540d5af0c0b5266b12dbd648d8f6824958ed907f40cae683fa77e7a8a5780381cae30a94acf67f880ed30483c5a8480816fc9d1c';
    final result = await ethSigner.sign(withdraw, mockToken);
    expect(hex.encode(result), equals(expected));
  });
}
