part of 'package:zksync/client.dart';

class WithdrawNft extends FundingTransaction {
  @override
  get type => "WithdrawNFT";

  NFT nft;

  WithdrawNft(Token feeToken, int accountId, EthereumAddress from,
      EthereumAddress to, NFT nft, BigInt fee, int nonce, TimeRange timeRange) {
    this.token = feeToken;
    this.accountId = accountId;
    this.from = from;
    this.to = to;
    this.nft = nft;
    this.amount = BigInt.zero;
    this.fee = fee;
    this.nonce = nonce;
    this.timeRange = timeRange;
  }

  @override
  Map<String, dynamic> toJson() => {
        "type": this.type,
        "feeToken": this.token.id,
        "accountId": this.accountId,
        "from": this.from.hex,
        "to": this.to.hex,
        "token": this.nft.id,
        "fee": this.fee.toString(),
        "nonce": this.nonce,
        "validFrom": this.timeRange.validFromSeconds,
        "validUntil": this.timeRange.validUntilSeconds,
      };
}
