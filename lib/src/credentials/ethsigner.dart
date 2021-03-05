part of 'package:zksync/credentials.dart';

class EthSigner {
  web3.EthPrivateKey _credentials;
  int chainId;

  EthSigner.raw(Uint8List rawKey, {int chainId}) {
    _credentials = web3.EthPrivateKey(rawKey);
    chainId = chainId;
  }

  EthSigner.hex(String hexKey, {int chainId}) {
    _credentials = web3.EthPrivateKey.fromHex(hexKey);
    chainId = chainId;
  }

  EthSigner(this._credentials, [this.chainId]);

  Future<web3.EthereumAddress> address() async {
    return _credentials.extractAddress();
  }

  Future<Uint8List> signPersonalMessage(Uint8List payload) {
    return _credentials.signPersonalMessage(payload, chainId: chainId);
  }

  Future<Uint8List> sign<T extends Transaction>(
      T transaction, Token token) async {
    final message = transaction
        .toEthereumSignMessage(token.symbol, token.decimals, nonce: true);
    return _credentials.signPersonalMessage(Utf8Encoder().convert(message),
        chainId: chainId);
  }

  Future<Uint8List> signBatch(
      List<Transaction> transactions, Token token) async {
    final first = transactions.first;
    final prepared = transactions
        .map((t) =>
            t.toEthereumSignMessage(token.symbol, token.decimals, nonce: false))
        .join("\n");
    final message = first.appendNonce(prepared);
    final signature = await _credentials
        .signPersonalMessage(Utf8Encoder().convert(message), chainId: chainId);

    return signature;
  }

  Future<Uint8List> signAuth(ChangePubKey transaction) {}
}
