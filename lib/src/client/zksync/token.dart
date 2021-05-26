part of 'package:zksync/client.dart';

abstract class TokenId {
  final int id = 0;
  final String symbol = "ETH";

  int get decimals;
}

class Token implements TokenId {
  static final Token eth = Token(
      0,
      EthereumAddress.fromHex("0x0000000000000000000000000000000000000000"),
      "ETH",
      18);

  @override
  final int id;
  @override
  final String symbol;

  final EthereumAddress address;
  final int decimals;

  Token(this.id, this.address, this.symbol, this.decimals);

  Token.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        address = EthereumAddress.fromHex(json["address"]),
        symbol = json["symbol"],
        decimals = json["decimals"];

  bool operator ==(other) {
    return (other is Token) &&
        other.id == id &&
        other.address == address &&
        other.symbol == symbol &&
        other.decimals == decimals;
  }
}

class NFT implements TokenId {
  @override
  final int id;
  @override
  final String symbol;

  int get decimals => 0;

  final int creatorId;
  final Uint8List contentHash;
  final EthereumAddress creatorAddress;
  final int serialId;
  final EthereumAddress address;

  NFT(this.id, this.symbol, this.creatorId, this.contentHash,
      this.creatorAddress, this.serialId, this.address);

  NFT.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        creatorId = json["creatorId"],
        symbol = json["symbol"],
        contentHash = hexToBytes(json["contentHash"]),
        creatorAddress = EthereumAddress.fromHex(json["creatorAddress"]),
        serialId = json["serialId"],
        address = EthereumAddress.fromHex(json["address"]);

  bool operator ==(other) {
    return (other is NFT) &&
        other.id == id &&
        other.symbol == symbol &&
        other.creatorId == creatorId &&
        other.contentHash == contentHash;
  }
}

class TokenLike {
  final dynamic value;

  TokenLike.id(int id) : value = id;
  TokenLike.address(EthereumAddress address) : value = address.hex;
  TokenLike.symbol(String symbol) : value = symbol;
}
