part of 'package:zksync/client.dart';

class TransactionFee {
  String gasTxAmount;
  String gasPriceWei;
  String gasFee;
  String zkpFee;
  String totalFee;

  TransactionFee.fromJson(Map<String, dynamic> json)
      : gasTxAmount = json["gasTxAmount"],
        gasPriceWei = json["gasPriceWei"],
        gasFee = json["gasFee"],
        zkpFee = json["zkpFee"],
        totalFee = json["totalFee"];
}

class TimeRange {
  final DateTime _from, _until;

  const TimeRange(this._from, this._until);
  TimeRange.raw(int from, int until)
      : this._from = DateTime.fromMillisecondsSinceEpoch(from * 1000),
        this._until = DateTime.fromMillisecondsSinceEpoch(until * 1000);

  DateTime get validFrom => _from;
  DateTime get validUntil => _until;

  int get validFromSeconds => _from.millisecondsSinceEpoch ~/ 1000;
  int get validUntilSeconds => _until.millisecondsSinceEpoch ~/ 1000;
}

enum TransactionType {
  WITHDRAW,
  TRANSFER,
  FAST_WITHDRAW,
  CHANGE_PUB_KEY,
  CHANGE_PUB_KEY_ONCHAIN_AUTH,
  FORCED_EXIT
}

enum ChangePubKeyType {
  ONCHAIN,
  ECDSA,
  CREATE2,
}

abstract class ChangePubKeyVariant {
  ChangePubKeyType get type;
  Uint8List get bytes;

  const ChangePubKeyVariant();
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
}

class ChangePubKeyECDSAVariant extends ChangePubKeyVariant {
  String ethSignature;
  String batchHash;

  @override
  ChangePubKeyType get type => ChangePubKeyType.ECDSA;

  @override
  Uint8List get bytes => hexToBytes(batchHash);
}

class ChangePubKeyCREATE2Variant extends ChangePubKeyVariant {
  EthereumAddress creatorAddress;
  String saltArg;
  String codeHash;

  @override
  ChangePubKeyType get type => ChangePubKeyType.CREATE2;

  @override
  Uint8List get bytes => bigIntegerToBytes(BigInt.zero, 32);
}

extension ToParam on TransactionType {
  dynamic type() {
    switch (this) {
      case TransactionType.WITHDRAW:
        return "Withdraw";
      case TransactionType.TRANSFER:
        return "Transfer";
      case TransactionType.FAST_WITHDRAW:
        return "FastWithdraw";
      case TransactionType.CHANGE_PUB_KEY:
        return {
          "ChangePubKey": {"onchainPubkeyAuth": false}
        };
      case TransactionType.CHANGE_PUB_KEY_ONCHAIN_AUTH:
        return {
          "ChangePubKey": {"onchainPubkeyAuth": true}
        };
      case TransactionType.FORCED_EXIT:
        return "ForcedExit";
      default:
        return "";
    }
  }
}

abstract class Transaction {
  final type = '';

  Signature signature;
  BigInt fee;
  int nonce;
  TimeRange timeRange;
}

abstract class FundingTransaction extends Transaction {
  int accountId;
  EthereumAddress from;
  EthereumAddress to;
  int token;
  BigInt amount;
}

class Transfer extends FundingTransaction {
  @override
  get type => "Transfer";

  Transfer(int accountId, EthereumAddress from, EthereumAddress to, int token,
      BigInt amount, BigInt fee, int nonce, TimeRange timeRange,
      [Signature signature]) {
    this.accountId = accountId;
    this.from = from;
    this.to = to;
    this.token = token;
    this.amount = amount;
    this.fee = fee;
    this.nonce = nonce;
    this.timeRange = timeRange;

    if (signature != null) {
      this.signature = signature;
    }
  }
}

class Withdraw extends FundingTransaction {
  @override
  get type => "Withdraw";

  Withdraw(int accountId, EthereumAddress from, EthereumAddress to, int token,
      BigInt amount, BigInt fee, int nonce, TimeRange timeRange,
      [Signature signature]) {
    this.accountId = accountId;
    this.from = from;
    this.to = to;
    this.token = token;
    this.amount = amount;
    this.fee = fee;
    this.nonce = nonce;
    this.timeRange = timeRange;

    if (signature != null) {
      this.signature = signature;
    }
  }
}

class ForcedExit extends Transaction {
  @override
  get type => "ForcedExit";

  int initiatorAccountId;
  EthereumAddress target;
  int token;

  ForcedExit(int initiatorAccountId, EthereumAddress target, int token,
      BigInt fee, int nonce, TimeRange timeRange,
      [Signature signature]) {
    this.initiatorAccountId = initiatorAccountId;
    this.target = target;
    this.token = token;
    this.fee = fee;
    this.nonce = nonce;
    this.timeRange = timeRange;

    if (signature != null) {
      this.signature = signature;
    }
  }
}

class ChangePubKey<T extends ChangePubKeyVariant> extends Transaction {
  @override
  get type => "ChangePubKey";

  int accountId;
  EthereumAddress account;
  ZksPubkeyHash newPkHash;
  int feeToken;
  String ethSignature;
  T ethAuthData;

  ChangePubKey(int accountId, EthereumAddress account, ZksPubkeyHash newPkHash,
      int feeToken, BigInt fee, int nonce, TimeRange timeRange, T ethAuthData,
      [Signature signature]) {
    this.accountId = accountId;
    this.account = account;
    this.newPkHash = newPkHash;
    this.feeToken = feeToken;
    this.ethSignature = ethSignature;
    this.fee = fee;
    this.nonce = nonce;
    this.timeRange = timeRange;
    this.ethAuthData = ethAuthData;

    if (signature != null) {
      this.signature = signature;
    }
  }
}

class Signature {
  String pubKey;
  String signature;
}

class EthSignature {
  SignatureType type;
  String signature;
}

class SignedTransaction<T extends Transaction> {
  T transaction;
  EthSignature ethereumSignature;
}

enum SignatureType { EthereumSignature, EIP1271Signature }

class SystemContract {
  final EthereumAddress mainContract;
  final EthereumAddress govContract;

  SystemContract.fromJson(Map<String, dynamic> json)
      : mainContract = EthereumAddress.fromHex(json["mainContract"]),
        govContract = EthereumAddress.fromHex(json["govContract"]);
}

class TransactionStatus {
  bool executed;
  bool success;
  String failReason;
  BlockInfo block;

  TransactionStatus.fromJson(Map<String, dynamic> json)
      : executed = json["executed"],
        success = json["success"],
        failReason = json["failReason"],
        block = BlockInfo.fromJson(json["block"]);
}

extension ToBytes<T extends Transaction> on T {
  Uint8List toBytes() {
    switch (this.type) {
      case "Transfer":
        final transfer = this as Transfer;
        final bytes = [
          [5],
          transfer.accountId.uint32BigEndianBytes(),
          transfer.from.addressBytes,
          transfer.to.addressBytes,
          transfer.token.uint16BigEndianBytes(),
          packTokenAmount(transfer.amount),
          packFeeAmount(transfer.fee),
          transfer.nonce.uint32BigEndianBytes(),
          transfer.timeRange.validFromSeconds.uint64BigEndianBytes(),
          transfer.timeRange.validUntilSeconds.uint64BigEndianBytes(),
        ];
        return Uint8List.fromList(bytes.expand((x) => x).toList());
      case "Withdraw":
        final withdraw = this as Withdraw;
        final bytes = [
          [3],
          withdraw.accountId.uint32BigEndianBytes(),
          withdraw.from.addressBytes,
          withdraw.to.addressBytes,
          withdraw.token.uint16BigEndianBytes(),
          bigIntegerToBytes(withdraw.amount, 16),
          packFeeAmount(withdraw.fee),
          withdraw.nonce.uint32BigEndianBytes(),
          withdraw.timeRange.validFromSeconds.uint64BigEndianBytes(),
          withdraw.timeRange.validUntilSeconds.uint64BigEndianBytes(),
        ];
        return Uint8List.fromList(bytes.expand((x) => x).toList());
      case "ChangePubKey":
        final changePubKey = this as ChangePubKey;
        final bytes = [
          [7],
          changePubKey.accountId.uint32BigEndianBytes(),
          changePubKey.account.addressBytes,
          changePubKey.newPkHash.addressBytes,
          changePubKey.feeToken.uint16BigEndianBytes(),
          packFeeAmount(changePubKey.fee),
          changePubKey.nonce.uint32BigEndianBytes(),
          changePubKey.timeRange.validFromSeconds.uint64BigEndianBytes(),
          changePubKey.timeRange.validUntilSeconds.uint64BigEndianBytes(),
        ];
        return Uint8List.fromList(bytes.expand((x) => x).toList());
      case "ForcedExit":
        final forcedExit = this as ForcedExit;
        final bytes = [
          [8],
          forcedExit.initiatorAccountId.uint32BigEndianBytes(),
          forcedExit.target.addressBytes,
          forcedExit.token.uint16BigEndianBytes(),
          packFeeAmount(forcedExit.fee),
          forcedExit.nonce.uint32BigEndianBytes(),
          forcedExit.timeRange.validFromSeconds.uint64BigEndianBytes(),
          forcedExit.timeRange.validUntilSeconds.uint64BigEndianBytes(),
        ];
        return Uint8List.fromList(bytes.expand((x) => x).toList());
    }
    return Uint8List(0);
  }
}

extension ToEthereumMessage<T extends Transaction> on T {
  String toEthereumSignMessage(String tokenSymbol, int decimals,
      {bool nonce = false}) {
    var result = '';
    switch (this.type) {
      case 'Transfer':
      case 'Withdraw':
        {
          final tx = this as FundingTransaction;
          result =
              "${tx.type} ${formatUnit(tx.amount.toString(), decimals)} $tokenSymbol to: ${tx.to.hex}";
        }
        break;
      case 'ForcedExit':
        {
          final tx = this as ForcedExit;
          result = "${tx.type} $tokenSymbol to: ${tx.target.hex}";
        }
        break;
      case 'ChangePubKey':
        {
          final tx = this as ChangePubKey;
          result = "Set signing key: ${tx.newPkHash.hexHash}";
        }
        break;
      default:
        throw 'Invalid transaction type';
    }
    if (this.fee.compareTo(BigInt.zero) > 0) {
      result +=
          "\nFee: ${formatUnit(this.fee.toString(), decimals)} $tokenSymbol";
    }
    if (nonce) {
      result = this.appendNonce(result);
    }
    return result;
  }

  String appendNonce(String message) {
    return message + "\nNonce: ${this.nonce}";
  }
}

extension ToEthereumSignData on ChangePubKey {
  Uint8List toEthereumSignData() {
    final data = [
      this.newPkHash.addressBytes,
      this.nonce.uint32BigEndianBytes(),
      this.accountId.uint32BigEndianBytes(),
      this.ethAuthData.bytes
    ];

    return Uint8List.fromList(data.expand((x) => x).toList());
  }
}
