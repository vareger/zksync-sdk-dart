part of 'package:zksync/client.dart';

class Token {
  static final Token eth = Token(
      0,
      EthereumAddress.fromHex("0x0000000000000000000000000000000000000000"),
      "ETH",
      18);

  final int id;
  final EthereumAddress address;
  final String symbol;
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

class NFT {
  final int id;
  final String symbol;
  final EthereumAddress creatorId;
  final Uint8List contentHash;

  NFT.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        creatorId = EthereumAddress.fromHex(json["creatorId"]),
        symbol = json["symbol"],
        contentHash = hexToBytes(json["contentHash"]);

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
