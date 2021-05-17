part of 'package:zksync/client.dart';

class WithdrawNft extends FundingTransaction {
  @override
  get type => "WithdrawNFT";

  int feeToken;

  WithdrawNft(
      int feeToken,
      int accountId,
      EthereumAddress from,
      EthereumAddress to,
      int token,
      BigInt fee,
      int nonce,
      TimeRange timeRange) {
    this.feeToken = feeToken;
    this.accountId = accountId;
    this.from = from;
    this.to = to;
    this.token = token;
    this.amount = BigInt.zero;
    this.fee = fee;
    this.nonce = nonce;
    this.timeRange = timeRange;
  }

  @override
  Map<String, dynamic> toJson() => {
        "type": this.type,
        "feeToken": this.feeToken,
        "accountId": this.accountId,
        "from": this.from.hex,
        "to": this.to.hex,
        "token": this.token,
        "fee": this.fee.toString(),
        "nonce": this.nonce,
        "validFrom": this.timeRange.validFromSeconds,
        "validUntil": this.timeRange.validUntilSeconds,
      };
}
