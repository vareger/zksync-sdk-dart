import 'package:convert/convert.dart';
import 'package:test/test.dart';
import 'package:web3dart/crypto.dart';
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
  final contentHash = hexToBytes(
      "0000000000000000000000000000000000000000000000000000000000000123");
  final nft = NFT(100000, "NFT-100000", 44, contentHash);

  final ethSigner =
      EthSigner.hex(privateKey, chainId: ChainId.Mainnet.getChainId());
  final zkSigner = await ZksSigner.fromEthSigner(ethSigner, ChainId.Mainnet);

  final transfer = Transfer(
      44,
      EthereumAddress.fromHex('0xede35562d3555e61120a151b3c8e8e91d83a378a'),
      EthereumAddress.fromHex('0x19aa2ed8712072e918632259780e587698ef58df'),
      mockToken,
      BigInt.from(1000000000000),
      BigInt.from(1000000),
      12,
      TimeRange.raw(0, 4294967295));

  final withdraw = Withdraw(
      44,
      EthereumAddress.fromHex('0xede35562d3555e61120a151b3c8e8e91d83a378a'),
      EthereumAddress.fromHex('0x19aa2ed8712072e918632259780e587698ef58df'),
      mockToken,
      BigInt.from(1000000000000),
      BigInt.from(1000000),
      12,
      TimeRange.raw(0, 4294967295));

  final changePubKey = ChangePubKey(
      55,
      EthereumAddress.fromHex('0xede35562d3555e61120a151b3c8e8e91d83a378a'),
      ZksPubkeyHash.fromHex('sync:18e8446d7748f2de52b28345bdbc76160e6b35eb'),
      mockToken,
      BigInt.from(1000000000),
      13,
      TimeRange.raw(0, 4294967295));
  changePubKey.setAuth(ChangePubKeyOnchainVariant());

  final forcedExit = ForcedExit(
      44,
      EthereumAddress.fromHex('0x19aa2ed8712072e918632259780e587698ef58df'),
      mockToken,
      BigInt.from(1000000),
      12,
      TimeRange.raw(0, 4294967295));

  final mintNft = MintNft(
      44,
      EthereumAddress.fromHex('0xede35562d3555e61120a151b3c8e8e91d83a378a'),
      contentHash,
      EthereumAddress.fromHex('0x19aa2ed8712072e918632259780e587698ef58df'),
      mockToken,
      BigInt.from(1000000),
      12);

  final withdrawNft = WithdrawNft(
      mockToken,
      44,
      EthereumAddress.fromHex('0xede35562d3555e61120a151b3c8e8e91d83a378a'),
      EthereumAddress.fromHex('0x19aa2ed8712072e918632259780e587698ef58df'),
      nft,
      BigInt.from(1000000),
      12,
      TimeRange.raw(0, 4294967295));

  test('generate public key (zk)', () async {
    final zkSigner = ZksSigner.seed(hex.decode(
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
        '5c3304c8d1a8917580c9a3f8edb9d8698cbe9e6e084af93c13ac3564fa052588b93830785b3d0f60a1a193ec4fff61f81b95f0d16bf128ee21a6ceb09ef88602';
    final result = await zkSigner.sign(transfer);
    expect(result.signature.signature, equals(expected));
  });

  test('sign single withdraw (zk)', () async {
    final expected =
        '3e2866bb00f892170cc3592d48aec7eb4afba75bdd0a530780fa1dcbdf857d07d75deb774142a93e3d1ca3be29e614e50892b95702b6461f86ddf78b9ab11a01';
    final result = await zkSigner.sign(withdraw);
    expect(result.signature.signature, equals(expected));
  });

  test('sign single change pubkey (zk)', () async {
    final expected =
        '31a6be992eeb311623eb466a49d54cb1e5b3d44e7ccc27d55f82969fe04824aa92107fefa6b0a2d7a07581ace7f6366a5904176fae4aadec24d75d3d76028500';
    final result = await zkSigner.sign(changePubKey);
    expect(result.signature.signature, equals(expected));
  });

  test('sign single forced exit (zk)', () async {
    final expected =
        '50a9b498ffb54a24ba77fca2d9a72f4d906464d14c73c8f3b4a457e9149ba0885c6de37706ced49ae8401fb59000d4bcf9f37bcdaeab20a87476c3e08088b702';
    final result = await zkSigner.sign(forcedExit);
    expect(result.signature.signature, equals(expected));
  });

  test('sign single mint nft (zk)', () async {
    final expected =
        '8c119b01ff8ae75ba5aabaa4ad480690e6a56d6e99d430ecac3bc3beacbaba28b3740cb20574d130281874fc70daaab884ee8e03a510e9ca9c1c677a2412cf03';
    final result = await zkSigner.sign(mintNft);
    expect(result.signature.signature, equals(expected));
  });

  test('sign single withdraw nft (zk)', () async {
    final expected =
        '9d94324425f23d09bf76df52e520e8da4561718057eb29fe6d760945be986b8e3a1955d9c02cf415558f533b7d9573564798db9586cc5ba1fdc44f711e455e03';
    final result = await zkSigner.sign(withdrawNft);
    expect(result.signature.signature, equals(expected));
  });

  test('sign single transfer (eth)', () async {
    final expected =
        '4684a8f03c5da84676ff4eae89984f20057ce288b3a072605cbf93ef4bcc8a021306b13a88c6d3adc68347f4b68b1cbdf967861005e934afa50ce2e0c5bced791b';
    final result = await ethSigner.sign(transfer);
    expect(result.signature, equals(hex.decode(expected)));
  });

  test('sign single withdraw (eth)', () async {
    final expected =
        'a87d458c96f2b78c8b615c7703540d5af0c0b5266b12dbd648d8f6824958ed907f40cae683fa77e7a8a5780381cae30a94acf67f880ed30483c5a8480816fc9d1c';
    final result = await ethSigner.sign(withdraw);
    expect(result.signature, equals(hex.decode(expected)));
  });

  test('sign single mint nft (eth)', () async {
    final expected =
        'ac4f8b1ad65ea143dd2a940c72dd778ba3e07ee766355ed237a89a0b7e925fe76ead0a04e23db1cc1593399ee69faeb31b2e7e0c6fbec70d5061d6fbc431d64a1b';
    final result = await ethSigner.sign(mintNft);
    expect(result.signature, equals(hex.decode(expected)));
  });

  test('sign single withdraw nft (eth)', () async {
    final expected =
        '4a50341da6d2b1f0b64a4e37f753c02c43623e89cb0a291026c37fdcc723da9665453ce622f4dd6237bd98430ef0d75755694b1968f3b2d0ea8598f8bc43accf1b';
    final result = await ethSigner.sign(withdrawNft);
    expect(result.signature, equals(hex.decode(expected)));
  });
}
