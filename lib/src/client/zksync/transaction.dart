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

enum TransactionType {
  WITHDRAW,
  TRANSFER,
  FAST_WITHDRAW,
  CHANGE_PUB_KEY,
  CHANGE_PUB_KEY_ONCHAIN_AUTH,
  FORCED_EXIT
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
      BigInt amount, BigInt fee, int nonce,
      [Signature signature]) {
    this.accountId = accountId;
    this.from = from;
    this.to = to;
    this.token = token;
    this.amount = amount;
    this.fee = fee;
    this.nonce = nonce;

    if (signature != null) {
      this.signature = signature;
    }
  }
}

class Withdraw extends FundingTransaction {
  @override
  get type => "Withdraw";

  Withdraw(int accountId, EthereumAddress from, EthereumAddress to, int token,
      BigInt amount, BigInt fee, int nonce,
      [Signature signature]) {
    this.accountId = accountId;
    this.from = from;
    this.to = to;
    this.token = token;
    this.amount = amount;
    this.fee = fee;
    this.nonce = nonce;

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
      BigInt fee, int nonce,
      [Signature signature]) {
    this.initiatorAccountId = initiatorAccountId;
    this.target = target;
    this.token = token;
    this.fee = fee;
    this.nonce = nonce;

    if (signature != null) {
      this.signature = signature;
    }
  }
}

class ChangePubKey extends Transaction {
  @override
  get type => "ChangePubKey";

  int accountId;
  EthereumAddress account;
  ZksPubkeyHash newPkHash;
  int feeToken;
  String ethSignature;

  ChangePubKey(int accountId, EthereumAddress account, ZksPubkeyHash newPkHash,
      int feeToken, BigInt fee, int nonce,
      [String ethSignature, Signature signature]) {
    this.accountId = accountId;
    this.account = account;
    this.newPkHash = newPkHash;
    this.feeToken = feeToken;
    this.ethSignature = ethSignature;
    this.fee = fee;
    this.nonce = nonce;

    if (ethSignature != null) {
      this.ethSignature = ethSignature;
    }

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
        ];
        return Uint8List.fromList(bytes.expand((x) => x).toList());
    }
    return Uint8List(0);
  }
}

extension ToEthereumMessage<T extends FundingTransaction> on T {
  String toEthereumSignMessage(String tokenSymbol, int decimals) {
    return "${this.type} ${formatUnit(this.amount.toString(), decimals)} $tokenSymbol\n" +
        "To: ${this.to.hex}\n" +
        "Nonce: ${this.nonce}\n" +
        "Fee: ${formatUnit(this.fee.toString(), decimals)} $tokenSymbol\n" +
        "Account Id: ${this.accountId}";
  }
}

extension ToEthereumMessageChangePubKey on ChangePubKey {
  String toEthereumSignMessage() {
    return "Register zkSync pubkey:\n\n" +
        "${this.newPkHash.hexHash}\n" +
        "nonce: 0x${hex.encode(this.nonce.uint32BigEndianBytes())}\n" +
        "account id: 0x${hex.encode(this.accountId.uint32BigEndianBytes())}\n\n" +
        "Only sign this message for a trusted client!";
  }
}
