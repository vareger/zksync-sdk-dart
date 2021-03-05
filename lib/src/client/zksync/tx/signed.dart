part of 'package:zksync/client.dart';

class SignedTransaction<T extends Transaction> {
  final T transaction;
  final Signature signature;

  const SignedTransaction(this.transaction, this.signature);

  Map<String, dynamic> toJson() =>
      transaction.toJson()..addAll({"signature": this.signature.toJson()});
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
  String signature;

  Map<String, dynamic> toJson() =>
      {"type": this.type, "signature": this.signature};
}

enum SignatureType { EthereumSignature, EIP1271Signature }
