part of 'package:zksync/client.dart';

class MintNft extends Transaction {
  @override
  get type => "MintNFT";

  int creatorId;
  EthereumAddress creatorAddress;
  Uint8List contentHash;
  EthereumAddress recipientAddress;

  MintNft(int creatorId, EthereumAddress creatorAddress, Uint8List contentHash,
      EthereumAddress recipientAddress, Token token, BigInt fee, int nonce) {
    this.creatorId = creatorId;
    this.creatorAddress = creatorAddress;
    this.contentHash = contentHash;
    this.recipientAddress = recipientAddress;
    this.token = token;
    this.nonce = nonce;
    this.fee = fee;
    this.timeRange = null;
  }

  @override
  Map<String, dynamic> toJson() => {
        "type": this.type,
        "creatorId": this.creatorId,
        "creatorAddress": this.creatorAddress.hex,
        "contentHash": bytesToHex(this.contentHash, include0x: true),
        "recipient": this.recipientAddress.hex,
        "feeToken": this.token.id,
        "fee": this.fee.toString(),
        "nonce": this.nonce,
      };
}
