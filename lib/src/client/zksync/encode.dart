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
          transfer.token.id.uint32BigEndianBytes(),
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
          withdraw.token.id.uint32BigEndianBytes(),
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
          changePubKey.token.id.uint32BigEndianBytes(),
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
          forcedExit.token.id.uint32BigEndianBytes(),
          packFeeAmount(forcedExit.fee),
          forcedExit.nonce.uint32BigEndianBytes(),
          forcedExit.timeRange.validFromSeconds.uint64BigEndianBytes(),
          forcedExit.timeRange.validUntilSeconds.uint64BigEndianBytes(),
        ];
        return Uint8List.fromList(bytes.expand((x) => x).toList());
      case "MintNFT":
        final mintNft = this as MintNft;
        final bytes = [
          [9],
          mintNft.creatorId.uint32BigEndianBytes(),
          mintNft.creatorAddress.addressBytes,
          mintNft.contentHash,
          mintNft.recipientAddress.addressBytes,
          mintNft.token.id.uint32BigEndianBytes(),
          packFeeAmount(mintNft.fee),
          mintNft.nonce.uint32BigEndianBytes(),
        ];
        return Uint8List.fromList(bytes.expand((x) => x).toList());
      case "WithdrawNFT":
        final withdraw = this as WithdrawNft;
        final bytes = [
          [10],
          withdraw.accountId.uint32BigEndianBytes(),
          withdraw.from.addressBytes,
          withdraw.to.addressBytes,
          withdraw.nft.id.uint32BigEndianBytes(),
          withdraw.token.id.uint32BigEndianBytes(),
          packFeeAmount(withdraw.fee),
          withdraw.nonce.uint32BigEndianBytes(),
          withdraw.timeRange.validFromSeconds.uint64BigEndianBytes(),
          withdraw.timeRange.validUntilSeconds.uint64BigEndianBytes(),
        ];
        return Uint8List.fromList(bytes.expand((x) => x).toList());
    }
    return Uint8List(0);
  }
}

extension ToEthereumMessage<T extends Transaction> on T {
  String toEthereumSignMessage({bool nonce = false}) {
    var result = '';
    final token = this.token;
    switch (this.type) {
      case 'Transfer':
      case 'Withdraw':
        {
          final tx = this as FundingTransaction;
          if (tx.amount == BigInt.zero) {
            break;
          }
          result =
              "${tx.type} ${formatUnit(tx.amount.toString(), token.decimals)} ${token.symbol} to: ${tx.to.hex}";
        }
        break;
      case 'WithdrawNFT':
        {
          final tx = this as WithdrawNft;
          result = "${tx.type} ${tx.token.id} to: ${tx.to}";
        }
        break;
      case 'ForcedExit':
        {
          final tx = this as ForcedExit;
          result = "${tx.type} ${token.symbol} to: ${tx.target.hex}";
        }
        break;
      case 'ChangePubKey':
        {
          final tx = this as ChangePubKey;
          result = "Set signing key: ${tx.newPkHash.hexHash}";
        }
        break;
      case 'MintNFT':
        {
          final tx = this as MintNft;
          result =
              "${tx.type} ${bytesToHex(tx.contentHash, include0x: true)} for: ${tx.recipientAddress.hex}";
        }
        break;
      default:
        throw 'Invalid transaction type';
    }
    if (this.fee.compareTo(BigInt.zero) > 0) {
      result = this.appendFee(result, token);
    }
    if (nonce) {
      result = this.appendNonce(result);
    }
    return result;
  }

  String appendFee(String message, TokenId token) {
    var result = '';
    if (message.isNotEmpty) {
      result += message + "\n";
    }
    result +=
        "Fee: ${formatUnit(this.fee.toString(), token.decimals)} ${token.symbol}";
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
      bigIntegerToBytes(
          BigInt.zero, 32) // FIXME: Change to correctness support batch sign
    ];

    return Uint8List.fromList(data.expand((x) => x).toList());
  }
}
