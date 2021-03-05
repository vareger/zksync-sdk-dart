part of 'package:zksync/client.dart';

abstract class Transaction {
  final type = '';

  BigInt fee;
  int nonce;
  TimeRange timeRange;

  Map<String, dynamic> toJson();
}

abstract class FundingTransaction extends Transaction {
  int accountId;
  EthereumAddress from;
  EthereumAddress to;
  int token;
  BigInt amount;
}

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
