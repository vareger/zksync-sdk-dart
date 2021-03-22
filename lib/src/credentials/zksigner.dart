part of 'package:zksync/credentials.dart';

const String MESSAGE =
    "Access zkSync account.\n\nOnly sign this message for a trusted client!";

class ZksSigner {
  static final _lib = ZksCrypto();

  Pointer<binding.ZksPrivateKey> _privateKey;
  Pointer<binding.ZksPackedPublicKey> _publicKey;
  Pointer<binding.ZksPubkeyHash> _pubkeyHash;

  ZksSigner.raw(Uint8List rawKey) {
    _privateKey = _lib.generatePrivateKeyFromRaw(rawKey);
    _publicKey = _lib.getPublicKey(_privateKey);
    _pubkeyHash = _lib.getPublicKeyHash(_publicKey);
  }

  ZksSigner.hex(String hexKey) {
    final rawKey = hexToBytes(hexKey);
    _privateKey = _lib.generatePrivateKeyFromRaw(rawKey);
    _publicKey = _lib.getPublicKey(_privateKey);
    _pubkeyHash = _lib.getPublicKeyHash(_publicKey);
  }

  ZksSigner.seed(Uint8List seed) {
    _privateKey = _lib.generatePrivateKeyFromSeed(seed);
    _publicKey = _lib.getPublicKey(_privateKey);
    _pubkeyHash = _lib.getPublicKeyHash(_publicKey);
  }

  static Future<ZksSigner> fromEthSigner(
      EthSigner ethereum, ChainId chainId) async {
    var message = MESSAGE;
    if (chainId != ChainId.Mainnet) {
      message = "$message\nChain ID: ${chainId.getChainId()}.";
    }
    final data = Utf8Encoder().convert(message);
    Uint8List signature = await ethereum.signPersonalMessage(data);

    return ZksSigner.seed(signature);
  }

  String get publicKey => _publicKey.toHexString();

  String get publicKeyHash => "sync:" + _pubkeyHash.toHexString();

  Future<SignedTransaction<T>> sign<T extends Transaction>(
      T transaction) async {
    final data = transaction.toBytes();
    final signature = _lib.sign(_privateKey, data);
    final refData = signature.ref.data;
    var result = Uint8List(64);
    for (int i = 0; i < result.length; i++) {
      result[i] = refData[i];
    }
    final signatureOb = Signature(this.publicKey, hex.encode(result));
    return SignedTransaction(transaction, signatureOb);
  }

  Future<Uint8List> signMessage(Uint8List payload) async {
    final signature = _lib.sign(_privateKey, payload);
    final refData = signature.ref.data;
    var result = Uint8List(64);
    for (int i = 0; i < result.length; i++) {
      result[i] = refData[i];
    }
    return result;
  }
}
