part of 'package:zksync/client.dart';

class ZkSyncClient {
  final JsonRPC _jsonRpc;
  final Client _client;

  ///Whether errors, handled or not, should be printed to the console.
  bool printErrors = false;

  ZkSyncClient(String url, Client httpClient)
      : _jsonRpc = JsonRPC(url, httpClient),
        _client = httpClient;

  ZkSyncClient.fromChainId(ChainId chainId)
      : this(chainId.getDefaultUrl(), Client());

  Future<T> _makeRPCCall<T>(String function, [List<dynamic> params]) async {
    try {
      final data = await _jsonRpc.call(function, params);
      // ignore: only_throw_errors
      if (data is Error || data is Exception) throw data;

      return data.result as T;
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      if (printErrors) print(e);

      rethrow;
    }
  }

  Future<AccountState> getState(EthereumAddress accountAddress) async {
    final result = await _makeRPCCall<Map<String, dynamic>>(
        "account_info", [accountAddress.hexEip55]);
    return AccountState.fromJson(result);
  }

  Future<TransactionFee> getTransactionFee(TransactionType type,
      EthereumAddress accountAddress, TokenLike token) async {
    final result = await _makeRPCCall<Map<String, dynamic>>(
        "get_tx_fee", [type.type(), accountAddress.hexEip55, token.value]);
    return TransactionFee.fromJson(result);
  }

  Future<Map<String, Token>> getTokens() async {
    final result = await _makeRPCCall<Map<String, dynamic>>("tokens");
    return result.map((k, v) => MapEntry(k, Token.fromJson(v)));
  }

  Future<double> getTokenPrice(TokenLike token) async {
    final result = await _makeRPCCall<String>("get_token_price", [token.value]);
    return double.parse(result);
  }

  Future<SystemContract> getContractAddress() async {
    final result = await _makeRPCCall<Map<String, dynamic>>("tokens");
    return SystemContract.fromJson(result);
  }

  Future<TransactionStatus> getTransactionStatus(String txHash) async {
    final result =
        await _makeRPCCall<Map<String, dynamic>>("tx_info", [txHash]);
    return TransactionStatus.fromJson(result);
  }

  Future<EthOpInfo> getEthOpInfo(int priority) async {
    final result =
        await _makeRPCCall<Map<String, dynamic>>("ethop_info", [priority]);
    return EthOpInfo.fromJson(result);
  }

  Future<int> getConfirmationsForEthOpAmount() async {
    return await _makeRPCCall<int>("get_confirmations_for_eth_op_amount");
  }

  Future<String> getEthTransactionForWithdrawal(String txHash) async {
    return await _makeRPCCall<String>("get_eth_tx_for_withdrawal");
  }

  Future<String> submitTx<T extends Transaction>(T transaction, bool fast,
      [EthSignature signature]) async {}
}

enum ChainId { Mainnet, Ropsten, Rinkeby, Localhost }

extension ChainIdNum on ChainId {
  int getChainId() {
    switch (this) {
      case ChainId.Mainnet:
        return 1;
      case ChainId.Ropsten:
        return 3;
      case ChainId.Rinkeby:
        return 4;
      case ChainId.Localhost:
        return 9;
      default:
        return -1;
    }
  }
}

extension DefaultUrl on ChainId {
  String getDefaultUrl() {
    switch (this) {
      case ChainId.Mainnet:
        return 'https://api.zksync.io/jsrpc';
      case ChainId.Ropsten:
        return 'https://ropsten-api.zksync.io/jsrpc';
      case ChainId.Rinkeby:
        return 'https://rinkeby-api.zksync.io/jsrpc';
      case ChainId.Localhost:
        return 'http://127.0.0.1:3030';
      default:
        return '';
    }
  }
}
