part of 'package:zksync/client.dart';

class DepositingState {
  Map<String, DepositingBalance> balances;

  DepositingState.fromJson(Map<String, dynamic> json) {
    balances = new Map<String, DepositingBalance>();
    json.forEach((k, v) => balances[k] = DepositingBalance.fromJson(v));
  }
}

class DepositingBalance {
  String amount;
  BigInt expectedBlockNumber;

  DepositingBalance.fromJson(Map<String, dynamic> json)
      : amount = json["amount"],
        expectedBlockNumber = json["expectedBlockNumber"];
}

class State {
  int nonce;
  String pubKeyHash;
  Map<String, String> balances;
  Map<int, NFT> nfts;
  Map<int, NFT> mintedNfts;

  State.fromJson(Map<String, dynamic> json)
      : nonce = json["nonce"],
        pubKeyHash = json["pubKeyHash"] {
    balances = new Map<String, String>();
    nfts = new Map<int, NFT>();
    mintedNfts = new Map<int, NFT>();
    json["balances"].forEach((k, v) => balances[k] = v);
    json["nfts"].forEach((k, v) => nfts[int.parse(k)] = NFT.fromJson(v));
    json["mintedNfts"]
        .forEach((k, v) => mintedNfts[int.parse(k)] = NFT.fromJson(v));
  }
}

class BlockInfo {
  int blockNumber;
  bool committed;
  bool verified;

  BlockInfo.fromJson(Map<String, dynamic> json)
      : blockNumber = json["blockNumber"],
        committed = json["committed"],
        verified = json["verified"];
}

class EthOpInfo {
  bool executed;
  BlockInfo block;

  EthOpInfo.fromJson(Map<String, dynamic> json)
      : executed = json["executed"],
        block = BlockInfo.fromJson(json["block"]);
}
