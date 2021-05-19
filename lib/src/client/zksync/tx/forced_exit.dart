part of 'package:zksync/client.dart';

class ForcedExit extends Transaction {
  @override
  get type => "ForcedExit";

  int initiatorAccountId;
  EthereumAddress target;

  ForcedExit(int initiatorAccountId, EthereumAddress target, Token token,
      BigInt fee, int nonce, TimeRange timeRange) {
    this.initiatorAccountId = initiatorAccountId;
    this.target = target;
    this.token = token;
    this.fee = fee;
    this.nonce = nonce;
    this.timeRange = timeRange;
  }

  @override
  Map<String, dynamic> toJson() => {
        "type": this.type,
        "initiatorAccountId": this.initiatorAccountId,
        "target": this.target.hex,
        "token": this.token.id,
        "fee": this.fee.toString(),
        "nonce": this.nonce,
        "validFrom": this.timeRange.validFromSeconds,
        "validUntil": this.timeRange.validUntilSeconds,
      };
}
