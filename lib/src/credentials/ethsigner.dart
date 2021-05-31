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

  Future<EthSignature> sign<T extends Transaction>(T transaction) async {
    final message = transaction.toEthereumSignMessage(nonce: true);
    final signature = await _credentials
        .signPersonalMessage(Utf8Encoder().convert(message), chainId: chainId);
    return EthSignature(SignatureType.EthereumSignature, signature);
  }

  Future<EthSignature> signBatch(List<Transaction> transactions) async {
    final first = transactions.first;
    final prepared = transactions
        .map((t) => t.toEthereumSignMessage(nonce: false))
        .join("\n");
    final message = first.appendNonce(prepared);
    final signature = await _credentials
        .signPersonalMessage(Utf8Encoder().convert(message), chainId: chainId);

    return EthSignature(SignatureType.EthereumSignature, signature);
  }

  Future<Uint8List> signAuth(ChangePubKey transaction) {
    final message = transaction.toEthereumSignData();
    return _credentials.signPersonalMessage(message, chainId: chainId);
  }

  Credentials get credentials => this._credentials;
}
