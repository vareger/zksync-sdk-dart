part of 'package:zksync/client.dart';

class Transfer extends FundingTransaction {
  @override
  get type => "Transfer";

  Transfer(
      int accountId,
      EthereumAddress from,
      EthereumAddress to,
      TokenId token,
      BigInt amount,
      BigInt fee,
      int nonce,
      TimeRange timeRange) {
    this.accountId = accountId;
    this.from = from;
    this.to = to;
    this.token = token;
    this.amount = amount;
    this.fee = fee;
    this.nonce = nonce;
    this.timeRange = timeRange;
  }

  @override
  Map<String, dynamic> toJson() => {
        "type": this.type,
        "accountId": this.accountId,
        "from": this.from.hex,
        "to": this.to.hex,
        "token": this.token.id,
        "amount": this.amount.toString(),
        "fee": this.fee.toString(),
        "nonce": this.nonce,
        "validFrom": this.timeRange.validFromSeconds,
        "validUntil": this.timeRange.validUntilSeconds,
      };
}
