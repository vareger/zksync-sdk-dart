part of 'package:zksync/client.dart';

class Token {
  static const Token eth =
      Token(0, "0x0000000000000000000000000000000000000000", "ETH", 18);

  final int id;
  final String address;
  final String symbol;
  final int decimals;

  const Token(this.id, this.address, this.symbol, this.decimals);

  Token.fromJson(Map<String, dynamic> json)
      : id = json["id"],
        address = json["address"],
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

class TokenLike {
  final dynamic value;

  TokenLike.id(int id) : value = id;
  TokenLike.address(EthereumAddress address) : value = address.hex;
  TokenLike.symbol(String symbol) : value = symbol;
}
