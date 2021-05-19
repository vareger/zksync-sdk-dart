part of 'package:zksync/client.dart';

final MAX_APPROVE_AMOUNT = BigInt.two.pow(256) - BigInt.one;
final DEFAULT_THRESHOLD = BigInt.two.pow(255);

class EthereumClient {
  final Web3Client client;
  final DeployedContract contract;
  final Credentials credentials;

  EthereumClient(String url, Credentials credentials, ChainId chainId,
      {Client httpClient, EthereumAddress contractAddr})
      : client = Web3Client(url, httpClient ?? Client()),
        contract = DeployedContract(
            _zkSyncAbi, contractAddr ?? chainId.mainContract()),
        credentials = credentials;
  static Future<EthereumClient> load(
      ZkSyncClient client, String url, Credentials credentials,
      {Client httpClient}) async {
    final contract = await client.getContractAddress();
    return EthereumClient(url, credentials, null,
        contractAddr: contract.mainContract);
  }

  Future<String> approveDeposits(Token token, [BigInt limit]) async {
    final contract = DeployedContract(_erc20Abi, token.address);
    final approve = contract.function('approve');
    return this.client.sendTransaction(
        this.credentials,
        web3.Transaction.callContract(
          contract: contract,
          function: approve,
          parameters: [this.contract.address, limit ?? MAX_APPROVE_AMOUNT],
        ),
        fetchChainIdFromNetworkId: true);
  }

  Future<String> transfer(
      Token token, BigInt amount, EthereumAddress to) async {
    if (token == Token.eth) {
      return this.client.sendTransaction(this.credentials,
          web3.Transaction(to: to, value: EtherAmount.inWei(amount)),
          fetchChainIdFromNetworkId: true);
    } else {
      final contract = DeployedContract(_erc20Abi, token.address);
      final transfer = contract.function('transfer');
      return this.client.sendTransaction(
          this.credentials,
          web3.Transaction.callContract(
            contract: contract,
            function: transfer,
            parameters: [amount, to],
          ),
          fetchChainIdFromNetworkId: true);
    }
  }

  Future<String> deposit(
      Token token, BigInt amount, EthereumAddress userAddress) async {
    if (token == Token.eth) {
      final deposit = this.contract.function('depositETH');
      return this.client.sendTransaction(
          this.credentials,
          web3.Transaction.callContract(
            contract: this.contract,
            function: deposit,
            parameters: [userAddress],
            value: EtherAmount.inWei(amount),
          ),
          fetchChainIdFromNetworkId: true);
    } else {
      final deposit = this.contract.function('depositERC20');
      return this.client.sendTransaction(
          this.credentials,
          web3.Transaction.callContract(
              contract: this.contract,
              function: deposit,
              parameters: [token.address, amount, userAddress]),
          fetchChainIdFromNetworkId: true);
    }
  }

  Future<String> withdraw(Token token, BigInt amount) async {
    if (token == Token.eth) {
      final withdraw = this.contract.function('withdrawETH');
      return this.client.sendTransaction(
          this.credentials,
          web3.Transaction.callContract(
              contract: this.contract,
              function: withdraw,
              parameters: [amount]),
          fetchChainIdFromNetworkId: true);
    } else {
      final withdraw = this.contract.function('withdrawERC20');
      return this.client.sendTransaction(
          this.credentials,
          web3.Transaction.callContract(
              contract: this.contract,
              function: withdraw,
              parameters: [token.address, amount]),
          fetchChainIdFromNetworkId: true);
    }
  }

  Future<String> fullExit(Token token, int accountId) async {
    final fullExit = this.contract.function('requestFullExit');
    return this.client.sendTransaction(
        this.credentials,
        web3.Transaction.callContract(
            contract: this.contract,
            function: fullExit,
            parameters: [BigInt.from(accountId), token.address]),
        fetchChainIdFromNetworkId: true);
  }

  Future<String> setAuthPubkeyHash(
      ZksPubkeyHash pubKeyhash, BigInt nonce) async {
    final setAuthPubkeyHash = this.contract.function('setAuthPubkeyHash');
    return this.client.sendTransaction(
        this.credentials,
        web3.Transaction.callContract(
            contract: this.contract,
            function: setAuthPubkeyHash,
            parameters: [pubKeyhash.addressBytes, nonce]),
        fetchChainIdFromNetworkId: true);
  }

  Future<bool> isDepositApproved(Token token, [BigInt threshold]) async {
    final contract = DeployedContract(_erc20Abi, token.address);
    final allowance = contract.function('allowance');
    return this.client.call(contract: contract, function: allowance, params: [
      await this.credentials.extractAddress(),
      this.contract.address
    ]).then((v) {
      final allowance = v.first as BigInt;
      return allowance.compareTo(threshold ?? DEFAULT_THRESHOLD) >= 0;
    });
  }

  Future<bool> isOnChainAuthPubkeyHashSet(BigInt nonce) async {
    final auth = this.contract.function('authFacts');
    return this.client.call(
        contract: this.contract,
        function: auth,
        params: [await this.credentials.extractAddress(), nonce]).then((v) {
      final pubkeyhash = v.first as Uint8List;
      return pubkeyhash.map((v) {
        return v != 0;
      }).fold(false, (p, v) {
        return p || v;
      });
    });
  }

  Future<EtherAmount> getBalance() async {
    return this.client.getBalance(await this.credentials.extractAddress());
  }

  Future<int> getNonce() async {
    return this
        .client
        .getTransactionCount(await this.credentials.extractAddress());
  }

  EthereumAddress contractAddress() {
    return contract.address;
  }
}

extension ZkSyncMainContract on ChainId {
  EthereumAddress mainContract() {
    switch (this) {
      case ChainId.Mainnet:
        return EthereumAddress.fromHex(
            '0xabea9132b05a70803a4e85094fd0e1800777fbef');
      case ChainId.Ropsten:
        return EthereumAddress.fromHex(
            '0x17de8874259c59cd9f7e6ec86b6813bda661a57c');
      case ChainId.Rinkeby:
        return EthereumAddress.fromHex(
            '0x82f67958a5474e40e1485742d648c0b0686b6e5d');
      default:
        throw 'Cannot use predefined contract address with this chain id';
    }
  }
}

final ContractAbi _zkSyncAbi = ContractAbi('ZkSync', [
  ContractFunction('depositERC20', [
    FunctionParameter('_token', AddressType()),
    FunctionParameter('_amount', UintType(length: 104)),
    FunctionParameter('_zkSyncAddress', AddressType()),
  ]),
  ContractFunction('withdrawERC20', [
    FunctionParameter('_token', AddressType()),
    FunctionParameter('_amount', UintType(length: 128)),
  ]),
  ContractFunction(
      'depositETH',
      [
        FunctionParameter('_zkSyncAddress', AddressType()),
      ],
      mutability: StateMutability.payable),
  ContractFunction('withdrawETH', [
    FunctionParameter('_amount', UintType(length: 128)),
  ]),
  ContractFunction('requestFullExit', [
    FunctionParameter('_accountId', UintType(length: 32)),
    FunctionParameter('_token', AddressType()),
  ]),
  ContractFunction('setAuthPubkeyHash', [
    FunctionParameter('_pubkey_hash', DynamicBytes()),
    FunctionParameter('_nonce', UintType(length: 32)),
  ]),
  ContractFunction(
      'getBalanceToWithdraw',
      [
        FunctionParameter('_address', AddressType()),
        FunctionParameter('_tokenId', UintType(length: 16)),
      ],
      outputs: [FunctionParameter('', UintType(length: 128))],
      mutability: StateMutability.view),
  ContractFunction(
      'authFacts',
      [
        FunctionParameter('_address', AddressType()),
        FunctionParameter('_nonce', UintType(length: 32)),
      ],
      outputs: [FunctionParameter('', FixedBytes(32))],
      mutability: StateMutability.view)
], []);

final ContractAbi _erc20Abi = ContractAbi('ERC20', [
  ContractFunction('approve', [
    FunctionParameter('to', AddressType()),
    FunctionParameter('amount', UintType(length: 256)),
  ]),
  ContractFunction(
      'allowance',
      [
        FunctionParameter('owner', AddressType()),
        FunctionParameter('spender', AddressType()),
      ],
      outputs: [FunctionParameter('', UintType(length: 256))],
      mutability: StateMutability.view)
], []);
