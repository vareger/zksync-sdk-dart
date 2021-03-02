part of 'package:zksync/credentials.dart';

/// Represents an ZkSync address.
@immutable
class ZksPubkeyHash {
  static final RegExp _basicAddress =
      RegExp(r'^(sync:)?[0-9a-f]{40}', caseSensitive: false);

  static const addressByteLength = 20;

  final Uint8List addressBytes;

  ZksPubkeyHash(this.addressBytes)
      : assert(addressBytes.length == addressByteLength);

  factory ZksPubkeyHash.fromHex(String hexHash) {
    if (!_basicAddress.hasMatch(hexHash)) {
      throw ArgumentError.value(hexHash, 'address',
          'Must be a hex string with a length of 40, optionally prefixed with "sync:"');
    }

    final address = _stripPrefix(hexHash);

    return ZksPubkeyHash(Uint8List.fromList(hex.decode(address)));
  }

  String get hexHash => _toHex(addressBytes, includePrefix: false);

  String get hexHashPrefix => _toHex(addressBytes, includePrefix: true);

  // @override
  // String toString() => hex;

  @override
  bool operator ==(other) {
    return identical(this, other) ||
        (other is ZksPubkeyHash && other.hexHash == hexHash);
  }

  @override
  int get hashCode {
    return hex.hashCode;
  }
}

String _stripPrefix(String s) {
  if (s.startsWith("sync:")) {
    return s.substring("sync:".length);
  } else {
    return s;
  }
}

String _toHex(Uint8List s, {bool includePrefix}) {
  if (includePrefix) {
    return "sync:" + hex.encode(s);
  } else {
    return hex.encode(s);
  }
}
