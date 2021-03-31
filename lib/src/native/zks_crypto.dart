import 'dart:ffi';
import 'dart:io';
import 'dart:typed_data';
import 'package:ffi/ffi.dart';
import 'package:web3dart/crypto.dart';

import 'package:zksync/src/native/zks_crypto_bindings.dart';

class ZksCrypto {
  static final ZksCrypto _instance = ZksCrypto.load();
  final ZksCryptoBindings _dylib;

  const ZksCrypto._internal(ZksCryptoBindings bindings) : _dylib = bindings;

  factory ZksCrypto() {
    return _instance;
  }

  static ZksCrypto load() {
    final LD_LIBRARY_PATH = "";
    final bindings =
        new ZksCryptoBindings(DynamicLibrary.open(LD_LIBRARY_PATH));
    bindings.zks_crypto_init();
    return ZksCrypto._internal(bindings);
  }

  Pointer<ZksPrivateKey> generatePrivateKeyFromSeed(Uint8List seed) {
    var data = allocate<Uint8>(count: seed.length);
    data.asTypedList(seed.length).setAll(0, seed);
    var result = allocate<ZksPrivateKey>();
    _dylib.zks_crypto_private_key_from_seed(data, seed.length, result);
    return result;
  }

  Pointer<ZksPrivateKey> generatePrivateKeyFromRaw(Uint8List raw) {
    assert(raw.length == 32);
    var result = allocate<ZksPrivateKey>();
    var data = result.ref.data;
    for (var i = 0; i < 32; i++) {
      data[i] = raw[i];
    }
    return result;
  }

  Pointer<ZksPackedPublicKey> getPublicKey(Pointer<ZksPrivateKey> privateKey) {
    var result = allocate<ZksPackedPublicKey>();
    _dylib.zks_crypto_private_key_to_public_key(privateKey, result);
    return result;
  }

  Pointer<ZksPubkeyHash> getPublicKeyHash(
      Pointer<ZksPackedPublicKey> publicKey) {
    var result = allocate<ZksPubkeyHash>();
    _dylib.zks_crypto_public_key_to_pubkey_hash(publicKey, result);
    return result;
  }

  Pointer<ZksSignature> sign(
      Pointer<ZksPrivateKey> privateKey, Uint8List message) {
    var data = allocate<Uint8>(count: message.length);
    data.asTypedList(message.length).setAll(0, message);
    var result = allocate<ZksSignature>();
    _dylib.zks_crypto_sign_musig(privateKey, data, message.length, result);
    return result;
  }

  bool verify(Pointer<ZksPackedPublicKey> publicKey,
      Pointer<ZksSignature> signature, Uint8List message) {
    var data = allocate<Uint8>(count: message.length);
    data.asTypedList(message.length).setAll(0, message);
    final result = _dylib.zks_crypto_verify_musig(
        data, message.length, publicKey, signature);

    return result == 0;
  }
}

String _platformPath(String name, {String path}) {
  if (path == null) path = "";
  if (Platform.isLinux || Platform.isAndroid || Platform.isFuchsia)
    return path + "lib" + name + ".so";
  if (Platform.isMacOS) return path + "lib" + name + ".dylib";
  if (Platform.isWindows) return path + name + ".dll";
  throw Exception("Platform not implemented");
}

DynamicLibrary dlopenPlatformSpecific(String name, {String path}) {
  String fullPath = _platformPath(name, path: path);
  return DynamicLibrary.open(fullPath);
}

extension PublicKeyToString on Pointer<ZksPackedPublicKey> {
  String toHexString() {
    var data = Uint8List(32);
    final refData = this.ref.data;
    for (var i = 0; i < data.length; i++) {
      data[i] = refData[i];
    }
    return bytesToHex(data);
  }
}

extension PubkeyHashToString on Pointer<ZksPubkeyHash> {
  String toHexString() {
    var data = Uint8List(20);
    final refData = this.ref.data;
    for (var i = 0; i < data.length; i++) {
      data[i] = refData[i];
    }
    return bytesToHex(data);
  }
}
