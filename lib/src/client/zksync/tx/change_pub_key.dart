part of 'package:zksync/client.dart';

enum ChangePubKeyType {
  ONCHAIN,
  ECDSA,
  CREATE2,
}

extension AuthTypeParam on ChangePubKeyType {
  String toParam() {
    switch (this) {
      case ChangePubKeyType.ONCHAIN:
        return "Onchain";
      case ChangePubKeyType.ECDSA:
        return "ECDSA";
      case ChangePubKeyType.CREATE2:
        return "CREATE2";
      default:
        throw 'Incorrect ChangePubKey auth type';
    }
  }
}

abstract class ChangePubKeyVariant {
  ChangePubKeyType get type;
  Uint8List get bytes;

  const ChangePubKeyVariant();

  Map<String, dynamic> toJson();
}

class ChangePubKeyOnchainVariant extends ChangePubKeyVariant {
  static const ChangePubKeyOnchainVariant _internal =
      ChangePubKeyOnchainVariant._create();

  factory ChangePubKeyOnchainVariant() {
    return _internal;
  }

  const ChangePubKeyOnchainVariant._create();

  @override
  ChangePubKeyType get type => ChangePubKeyType.ONCHAIN;

  @override
  Uint8List get bytes => bigIntegerToBytes(BigInt.zero, 32);

  @override
  Map<String, dynamic> toJson() => {"type": this.type.toParam()};
}

class ChangePubKeyECDSAVariant extends ChangePubKeyVariant {
  Uint8List ethSignature;
  Uint8List batchHash;

  ChangePubKeyECDSAVariant.single(Uint8List signature)
      : this.ethSignature = signature,
        this.batchHash = bigIntegerToBytes(BigInt.zero, 32);

  @override
  ChangePubKeyType get type => ChangePubKeyType.ECDSA;

  @override
  Uint8List get bytes => batchHash;

  @override
  Map<String, dynamic> toJson() => {
        "type": this.type.toParam(),
        "ethSignature": bytesToHex(this.ethSignature, include0x: true),
        "batchHash": bytesToHex(this.batchHash, include0x: true),
      };
}

class ChangePubKeyCREATE2Variant extends ChangePubKeyVariant {
  EthereumAddress creatorAddress;
  String saltArg;
  String codeHash;

  @override
  ChangePubKeyType get type => ChangePubKeyType.CREATE2;

  @override
  Uint8List get bytes => bigIntegerToBytes(BigInt.zero, 32);

  @override
  Map<String, dynamic> toJson() => {
        "type": this.type.toParam(),
        "creatorAddress": this.creatorAddress.hex,
        "saltArg": this.saltArg,
        "codeHash": this.codeHash,
      };
}

class ChangePubKey extends Transaction {
  @override
  get type => "ChangePubKey";

  int accountId;
  EthereumAddress account;
  ZksPubkeyHash newPkHash;
  int feeToken;
  ChangePubKeyVariant ethAuthData;

  ChangePubKey(int accountId, EthereumAddress account, ZksPubkeyHash newPkHash,
      int feeToken, BigInt fee, int nonce, TimeRange timeRange) {
    this.accountId = accountId;
    this.account = account;
    this.newPkHash = newPkHash;
    this.feeToken = feeToken;
    this.fee = fee;
    this.nonce = nonce;
    this.timeRange = timeRange;
  }

  void setAuth(ChangePubKeyVariant auth) {
    this.ethAuthData = auth;
  }

  @override
  Map<String, dynamic> toJson() => {
        "type": this.type,
        "accountId": this.accountId,
        "account": this.account.hex,
        "newPkHash": this.newPkHash.hexHashPrefix,
        "feeToken": this.feeToken,
        "ethAuthData": this.ethAuthData.toJson(),
        "fee": this.fee.toString(),
        "nonce": this.nonce,
        "validFrom": this.timeRange.validFromSeconds,
        "validUntil": this.timeRange.validUntilSeconds,
      };
}
