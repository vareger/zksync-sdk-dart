part of 'package:zksync/zksync.dart';

enum _CacheKey { AccountId, Address }

class Wallet<Zk extends ZkSyncClient, Eth extends EthereumClient,
    Signer extends ZksSigner, Auth extends EthSigner> {
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
    final type = onchainAuth
        ? TransactionType.LEGACY_CHANGE_PUB_KEY_ONCHAIN_AUTH
        : TransactionType.LEGACY_CHANGE_PUB_KEY;
    final transaction = ChangePubKey(
      await this.getAccountId(),
      await this.getAddress(),
      pubKeyhash,
      token,
      await this._OrFee(type, fee, await this.getAddress(), token),
      nonce ?? await this.getNonce(),
      timeRange ?? TimeRange.def(),
    );
    if (onchainAuth) {
      transaction.setAuth(ChangePubKeyOnchainVariant());
    } else {
      final authSignature = await this._auth.signAuth(transaction);
      transaction.setAuth(ChangePubKeyECDSAVariant.single(authSignature));
    }
    final signed = await this._signer.sign(transaction);
    return this._zksync.submitTx(signed);
  }

  Future<String> transfer(EthereumAddress to, BigInt amount,
      {Token token, TransactionFee fee, int nonce, TimeRange timeRange}) async {
    final transaction = Transfer(
        await this.getAccountId(),
        await this.getAddress(),
        to,
        token,
        amount,
        await this._OrFee(TransactionType.TRANSFER, fee, to, token),
        nonce ?? await this.getNonce(),
        timeRange ?? TimeRange.def());
    final signed = await this._signer.sign(transaction);
    final authSignature = await this._auth.sign(transaction);
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
    final type =
        fast ? TransactionType.FAST_WITHDRAW : TransactionType.WITHDRAW;
    final transaction = Withdraw(
        await this.getAccountId(),
        await this.getAddress(),
        to,
        token,
        amount,
        await this._OrFee(type, fee, to, token),
        nonce ?? await this.getNonce(),
        timeRange ?? TimeRange.def());
    final signed = await this._signer.sign(transaction);
    final authSignature = await this._auth.sign(transaction);
    if (fast) {
      return this._zksync.submitFastTx(signed, authSignature);
    } else {
      return this._zksync.submitTx(signed, authSignature);
    }
  }

  Future<String> forcedExit(EthereumAddress to,
      {Token token, TransactionFee fee, int nonce, TimeRange timeRange}) async {
    final transaction = ForcedExit(
        await this.getAccountId(),
        to,
        token,
        await this._OrFee(TransactionType.FORCED_EXIT, fee, to, token),
        nonce ?? await this.getNonce(),
        timeRange ?? TimeRange.def());
    final signed = await this._signer.sign(transaction);
    final authSignature = await this._auth.sign(transaction);
    return this._zksync.submitTx(signed, authSignature);
  }

  Future<String> mintNft(EthereumAddress to, Uint8List contentHash,
      {Token token, TransactionFee fee, int nonce}) async {
    final transaction = MintNft(
        await this.getAccountId(),
        await this.getAddress(),
        contentHash,
        to,
        token,
        await this._OrFee(TransactionType.MINT_NFT, fee, to, token),
        nonce ?? await this.getNonce());
    final signed = await this._signer.sign(transaction);
    final authSignature = await this._auth.sign(transaction);
    return this._zksync.submitTx(signed, authSignature);
  }

  Future<String> withdrawNft(EthereumAddress to, NFT nft,
      {Token token,
      TransactionFee fee,
      int nonce,
      TimeRange timeRange,
      bool fast = false}) async {
    final type =
        fast ? TransactionType.FAST_WITHDRAW : TransactionType.WITHDRAW;
    final transaction = WithdrawNft(
        token,
        await this.getAccountId(),
        await this.getAddress(),
        to,
        nft,
        await this._OrFee(type, fee, to, token),
        nonce ?? await this.getNonce(),
        timeRange ?? TimeRange.def());
    final signed = await this._signer.sign(transaction);
    final authSignature = await this._auth.sign(transaction);
    return this._zksync.submitTx(signed, authSignature);
  }

  Future<List<String>> transferNft(EthereumAddress to, NFT nft,
      {Token token, TransactionFee fee, int nonce, TimeRange timeRange}) async {
    final feeToUse = fee ??
        await _zksync.getTransactionBatchFee(
            [TransactionType.TRANSFER, TransactionType.TRANSFER],
            [to, await this.getAddress()],
            TokenLike.id(token.id));
    final nonceToUse = nonce ?? await this.getNonce();
    final transferNft = Transfer(
        await this.getAccountId(),
        await this.getAddress(),
        to,
        nft,
        BigInt.one,
        BigInt.zero,
        nonceToUse,
        timeRange ?? TimeRange.def());
    final payFee = Transfer(
        await this.getAccountId(),
        await this.getAddress(),
        await this.getAddress(),
        token,
        BigInt.zero,
        feeToUse.totalFee,
        nonceToUse + 1,
        timeRange ?? TimeRange.def());
    final signedTransferNft = await this._signer.sign(transferNft);
    final signedPayFee = await this._signer.sign(payFee);
    final authSignature = await this._auth.signBatch([transferNft, payFee]);
    return this
        ._zksync
        .submitBatchTx([signedTransferNft, signedPayFee], authSignature);
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

  Future<BigInt> _OrFee(TransactionType type, TransactionFee fee,
      EthereumAddress address, Token token) async {
    if (fee != null) {
      return fee.totalFee;
    } else {
      return this
          ._zksync
          .getTransactionFee(type, address, TokenLike.id(token.id))
          .then((v) => v.totalFee);
    }
  }
}
