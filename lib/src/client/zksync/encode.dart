part of 'package:zksync/client.dart';

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
