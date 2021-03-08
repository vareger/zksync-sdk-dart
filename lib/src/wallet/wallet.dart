part of 'package:zksync/zksync.dart';

enum _CacheKey { AccountId, Address }

class Wallet<Zk extends ZkSyncClient, Eth extends EthereumClient,
    Signer extends ZksSigher, Auth extends EthSigner> {
  final _cache = MapCache<_CacheKey, dynamic>();
  final Zk _zksync;
  final Signer _signer;
  final Auth _auth;
  final EthereumClient _ethereum;

  Wallet(Zk zksClient, Eth ethereumClient, Signer signer, Auth auth)
      : this._zksync = zksClient,
        this._ethereum = ethereumClient,
        this._signer = signer,
        this._auth = auth;
  Future<String> setSigningKey(ZksPubkeyHash pubKeyhash,
      {Token token,
      TransactionFee fee,
      int nonce,
      bool onchainAuth = false,
      TimeRange timeRange}) async {
    final transaction = ChangePubKey(
      await this.getAccountId(),
      await this.getAddress(),
      pubKeyhash,
      token.id,
      fee.totalFee,
      nonce ?? await this.getNonce(),
      timeRange ?? TimeRange.def(),
      onchainAuth
          ? ChangePubKeyOnchainVariant()
          : null, // TODO: make signing ethereum message data to ecdsa authentication
    );
    final signed = await this._signer.sign(transaction);
    return this._zksync.submitTx(signed);
  }

  Future<String> transfer(EthereumAddress to, BigInt amount,
      {Token token, TransactionFee fee, int nonce, TimeRange timeRange}) async {
    final transaction = Transfer(
        await this.getAccountId(),
        await this.getAddress(),
        to,
        token.id,
        amount,
        fee.totalFee,
        nonce ?? await this.getNonce(),
        timeRange ?? TimeRange.def());
    final signed = await this._signer.sign(transaction);
    final authSignature = await this._auth.sign(transaction, token);
    return this._zksync.submitTx(
          signed,
          authSignature,
        );
  }

  Future<String> withdraw(EthereumAddress to, BigInt amount,
      {Token token,
      TransactionFee fee,
      int nonce,
      TimeRange timeRange,
      bool fast = false}) async {
    final transaction = Withdraw(
        await this.getAccountId(),
        await this.getAddress(),
        to,
        token.id,
        amount,
        fee.totalFee,
        nonce ?? await this.getNonce(),
        timeRange ?? TimeRange.def());
    final signed = await this._signer.sign(transaction);
    if (fast) {
      return this._zksync.submitFastTx(signed);
    } else {
      return this._zksync.submitTx(signed);
    }
  }

  Future<String> forcedExit(EthereumAddress to,
      {Token token, TransactionFee fee, int nonce, TimeRange timeRange}) async {
    final transaction = ForcedExit(
        await this.getAccountId(),
        to,
        token.id,
        fee.totalFee,
        nonce ?? await this.getNonce(),
        timeRange ?? TimeRange.def());
    final signed = await this._signer.sign(transaction);
    return this._zksync.submitTx(signed);
  }

  Future<bool> isSigningKeySet() async {
    final current = (await this.getState()).commited.pubKeyHash;
    return current == this._signer.publicKeyHash;
  }

  Future<AccountState> getState() async {
    return this._zksync.getState(await this.getAddress());
  }

  Future<int> getAccountId() async {
    int accountId = await this._cache.get(_CacheKey.AccountId, ifAbsent: (_) {
      return this._getAccountId();
    });
    return accountId;
  }

  Future<EthereumAddress> getAddress() async {
    final address = await this._cache.get(_CacheKey.Address, ifAbsent: (_) {
      return this._getAddress();
    });
    return address as EthereumAddress;
  }

  Future<int> getNonce() async {
    return (await this.getState()).commited.nonce;
  }

  Future<EthereumAddress> _getAddress() async {
    return this._ethereum.credentials.extractAddress();
  }

  Future<int> _getAccountId() async {
    return (await this.getState()).id;
  }
}
