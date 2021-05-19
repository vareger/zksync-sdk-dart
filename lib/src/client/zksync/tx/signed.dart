part of 'package:zksync/client.dart';

class SignedTransaction<T extends Transaction> {
  final T transaction;
  final Signature signature;

  const SignedTransaction(this.transaction, this.signature);

  Map<String, dynamic> toJson() =>
      transaction.toJson()..addAll({"signature": this.signature?.toJson()});
}

class Signature {
  final String pubKey;
  final String signature;

  const Signature(this.pubKey, this.signature);

  Map<String, dynamic> toJson() =>
      {"pubKey": this.pubKey, "signature": this.signature};
}

class EthSignature {
  SignatureType type;
  Uint8List signature;

  EthSignature(this.type, this.signature);

  Map<String, dynamic> toJson() => {
        "type": this.type.toParam(),
        "signature": '0x' + hex.encode(this.signature)
      };
}

enum SignatureType { EthereumSignature, EIP1271Signature }

extension SignatureTypeToParam on SignatureType {
  String toParam() {
    switch (this) {
      case SignatureType.EthereumSignature:
        return 'EthereumSignature';
      case SignatureType.EIP1271Signature:
        return 'EIP1271Signature';
      default:
        throw 'Unsupported signature type';
    }
  }
}
