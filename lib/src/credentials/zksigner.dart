import 'dart:convert';
import 'dart:ffi';
import 'dart:typed_data';

import 'package:web3dart/crypto.dart';
import 'package:web3dart/web3dart.dart' as web3;
import 'package:zksync/client.dart';
import 'package:zksync/src/native/zks_crypto.dart';
import 'package:zksync/src/native/zks_crypto_bindings.dart';

const String MESSAGE =
    "Access zkSync account.\n\nOnly sign this message for a trusted client!";

class EthSigner {
  web3.Credentials _credentials;

  EthSigner.raw(Uint8List rawKey) {
    _credentials = web3.EthPrivateKey(rawKey);
  }

  EthSigner.hex(String hexKey) {
    _credentials = web3.EthPrivateKey.fromHex(hexKey);
  }

  Future<Uint8List> signPersonalMessage(Uint8List payload, {int chainId}) {
    return _credentials.signPersonalMessage(payload, chainId: chainId);
  }

  Future<Uint8List> signFunding<T extends FundingTransaction>(T transaction) {}
  Future<Uint8List> signChangePubKey(ChangePubKey transaction) {}
}

class ZksSigher {
  static final _lib = ZksCrypto();

  Pointer<ZksPrivateKey> _privateKey;
  Pointer<ZksPackedPublicKey> _publicKey;
  Pointer<ZksPubkeyHash> _pubkeyHash;

  ZksSigher.raw(Uint8List rawKey) {
    _privateKey = _lib.generatePrivateKeyFromRaw(rawKey);
    _publicKey = _lib.getPublicKey(_privateKey);
    _pubkeyHash = _lib.getPublicKeyHash(_publicKey);
  }

  ZksSigher.hex(String hexKey) {
    final rawKey = hexToBytes(hexKey);
    _privateKey = _lib.generatePrivateKeyFromRaw(rawKey);
    _publicKey = _lib.getPublicKey(_privateKey);
    _pubkeyHash = _lib.getPublicKeyHash(_publicKey);
  }

  ZksSigher.seed(Uint8List seed) {
    _privateKey = _lib.generatePrivateKeyFromSeed(seed);
    _publicKey = _lib.getPublicKey(_privateKey);
    _pubkeyHash = _lib.getPublicKeyHash(_publicKey);
  }

  static Future<ZksSigher> fromEthSigner(
      EthSigner ethereum, ChainId chainId) async {
    var message = MESSAGE;
    if (chainId != ChainId.Mainnet) {
      message = "$message\nChain ID: ${chainId.getChainId()}.";
    }
    final data = Utf8Encoder().convert(message);
    Uint8List signature =
        await ethereum.signPersonalMessage(data, chainId: chainId.getChainId());

    return ZksSigher.seed(signature);
  }

  String get publicKey => _publicKey.toHexString();

  String get publicKeyHash => "sync:" + _pubkeyHash.toHexString();

  Future<Uint8List> sign<T extends Transaction>(T transaction) async {
    final data = transaction.toBytes();
    final signature = _lib.sign(_privateKey, data);
    final refData = signature.ref.data;
    var result = Uint8List(64);
    for (int i = 0; i < result.length; i++) {
      result[i] = refData[i];
    }
    return result;
  }
}
