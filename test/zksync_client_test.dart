import 'package:http/http.dart';
import 'package:mockito/mockito.dart';
import 'package:test/test.dart';
import 'package:web3dart/credentials.dart';
import 'package:zksync/client.dart';

class MockClient extends Mock implements Client {}

void main() {
  final client = new MockClient();
  final zksync = new ZkSyncClient('url', client);

  test('get account state if not exists', () async {
    when(client.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
        .thenAnswer((i) {
      return Future.value(Response(
        '{"jsonrpc":"2.0","result":{"address":"0x7ccc10129cebc6a5d64c63989c66f7dcc2f25926","id":null,"depositing":{"balances":{}},"committed":{"balances":{},"nonce":0,"pubKeyHash":"sync:0000000000000000000000000000000000000000"},"verified":{"balances":{},"nonce":0,"pubKeyHash":"sync:0000000000000000000000000000000000000000"}},"id":0}',
        200,
      ));
    });

    final info = await zksync.getState(
        EthereumAddress.fromHex('0x7ccc10129cebc6a5d64c63989c66f7dcc2f25926'));

    expect(info.address, equals('0x7ccc10129cebc6a5d64c63989c66f7dcc2f25926'));
  });

  test('get account state if exists', () async {
    when(client.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
        .thenAnswer((i) {
      return Future.value(Response(
        '{"jsonrpc":"2.0","result":{"address":"0x6f4cd4b7ae1b6d9704d7854f254aa80a352d83b1","id":6925,"depositing":{"balances":{}},"committed":{"balances":{"ETH":"1101369440000000000"},"nonce":19,"pubKeyHash":"sync:1b076406d898583752abb4dc4b98d8f921a41a4f"},"verified":{"balances":{"ETH":"1101369440000000000"},"nonce":19,"pubKeyHash":"sync:1b076406d898583752abb4dc4b98d8f921a41a4f"}},"id":0}',
        200,
      ));
    });

    final info = await zksync.getState(
        EthereumAddress.fromHex('0x6f4cd4b7ae1b6d9704d7854f254aa80a352d83b1'));

    expect(info.address, equals('0x6f4cd4b7ae1b6d9704d7854f254aa80a352d83b1'));
    expect(info.id, equals(6925));
  });

  group('transaction fee', () {
    test('get transfer fee', () async {
      when(client.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((i) {
        return Future.value(Response(
          '{"jsonrpc":"2.0","result":{"feeType":"Transfer","gasTxAmount":"650","gasPriceWei":"1000000000","gasFee":"845000000000","zkpFee":"1094841600216","totalFee":"1939000000000"},"id":0}',
          200,
        ));
      });

      final payload =
          '{"jsonrpc":"2.0","method":"get_tx_fee","params":["Transfer","0x0000000000000000000000000000000000000000","ETH"],"id":';

      final fee = await zksync.getTransactionFee(
          TransactionType.TRANSFER,
          EthereumAddress.fromHex('0x0000000000000000000000000000000000000000'),
          TokenLike.symbol("ETH"));

      verify(client.post(any,
          headers: anyNamed('headers'), body: startsWith(payload)));

      expect(fee.totalFee, equals('1939000000000'));
      expect(fee.gasTxAmount, equals('650'));
      expect(fee.gasPriceWei, equals('1000000000'));
      expect(fee.gasFee, equals('845000000000'));
      expect(fee.zkpFee, equals('1094841600216'));
    });

    test('get withdraw fee', () async {
      when(client.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((i) {
        return Future.value(Response(
          '{"jsonrpc":"2.0","result":{"feeType":"Withdraw","gasTxAmount":"52700","gasPriceWei":"1000000000","gasFee":"68510000000000","zkpFee":"3284524800648","totalFee":"71700000000000"},"id":0}',
          200,
        ));
      });

      final payload =
          '{"jsonrpc":"2.0","method":"get_tx_fee","params":["Withdraw","0x0000000000000000000000000000000000000000","ETH"],"id":';

      final fee = await zksync.getTransactionFee(
          TransactionType.WITHDRAW,
          EthereumAddress.fromHex('0x0000000000000000000000000000000000000000'),
          TokenLike.symbol("ETH"));

      verify(client.post(any,
          headers: anyNamed('headers'), body: startsWith(payload)));

      expect(fee.totalFee, equals('71700000000000'));
      expect(fee.gasTxAmount, equals('52700'));
      expect(fee.gasPriceWei, equals('1000000000'));
      expect(fee.gasFee, equals('68510000000000'));
      expect(fee.zkpFee, equals('3284524800648'));
    });

    test('get fast withdraw fee', () async {
      when(client.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((i) {
        return Future.value(Response(
          '{"jsonrpc":"2.0","result":{"feeType":"FastWithdraw","gasTxAmount":"527000","gasPriceWei":"1000000000","gasFee":"685100000000000","zkpFee":"3284524800648","totalFee":"688000000000000"},"id":0}',
          200,
        ));
      });

      final payload =
          '{"jsonrpc":"2.0","method":"get_tx_fee","params":["FastWithdraw","0x0000000000000000000000000000000000000000","ETH"],"id":';

      final fee = await zksync.getTransactionFee(
          TransactionType.FAST_WITHDRAW,
          EthereumAddress.fromHex('0x0000000000000000000000000000000000000000'),
          TokenLike.symbol("ETH"));

      verify(client.post(any,
          headers: anyNamed('headers'), body: startsWith(payload)));

      expect(fee.totalFee, equals('688000000000000'));
      expect(fee.gasTxAmount, equals('527000'));
      expect(fee.gasPriceWei, equals('1000000000'));
      expect(fee.gasFee, equals('685100000000000'));
      expect(fee.zkpFee, equals('3284524800648'));
    });

    test('get change pub key fee', () async {
      when(client.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((i) {
        return Future.value(Response(
          '{"jsonrpc":"2.0","result":{"feeType":{"ChangePubKey":{"onchainPubkeyAuth":false}},"gasTxAmount":"12250","gasPriceWei":"1000000000","gasFee":"15925000000000","zkpFee":"3284524800298","totalFee":"19200000000000"},"id":0}',
          200,
        ));
      });

      final payload =
          '{"jsonrpc":"2.0","method":"get_tx_fee","params":[{"ChangePubKey":{"onchainPubkeyAuth":false}},"0x0000000000000000000000000000000000000000","ETH"],"id":';

      final fee = await zksync.getTransactionFee(
          TransactionType.CHANGE_PUB_KEY,
          EthereumAddress.fromHex('0x0000000000000000000000000000000000000000'),
          TokenLike.symbol("ETH"));

      verify(client.post(any,
          headers: anyNamed('headers'), body: startsWith(payload)));

      expect(fee.totalFee, equals('19200000000000'));
      expect(fee.gasTxAmount, equals('12250'));
      expect(fee.gasPriceWei, equals('1000000000'));
      expect(fee.gasFee, equals('15925000000000'));
      expect(fee.zkpFee, equals('3284524800298'));
    });

    test('get change pub key fee with onchain auth', () async {
      when(client.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((i) {
        return Future.value(Response(
          '{"jsonrpc":"2.0","result":{"feeType":{"ChangePubKey":{"onchainPubkeyAuth":true}},"gasTxAmount":"5200","gasPriceWei":"1000000000","gasFee":"6760000000000","zkpFee":"3284524800648","totalFee":"10040000000000"},"id":0}',
          200,
        ));
      });

      final payload =
          '{"jsonrpc":"2.0","method":"get_tx_fee","params":[{"ChangePubKey":{"onchainPubkeyAuth":true}},"0x0000000000000000000000000000000000000000","ETH"],"id":';

      final fee = await zksync.getTransactionFee(
          TransactionType.CHANGE_PUB_KEY_ONCHAIN_AUTH,
          EthereumAddress.fromHex('0x0000000000000000000000000000000000000000'),
          TokenLike.symbol("ETH"));

      verify(client.post(any,
          headers: anyNamed('headers'), body: startsWith(payload)));

      expect(fee.totalFee, equals('10040000000000'));
      expect(fee.gasTxAmount, equals('5200'));
      expect(fee.gasPriceWei, equals('1000000000'));
      expect(fee.gasFee, equals('6760000000000'));
      expect(fee.zkpFee, equals('3284524800648'));
    });
  });

  test('get supported tokens', () async {
    when(client.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
        .thenAnswer((i) {
      return Future.value(Response(
        '{"jsonrpc":"2.0","result":{"ETH":{"id":0,"address":"0x0000000000000000000000000000000000000000","symbol":"ETH","decimals":18},"USDT":{"id":1,"address":"0x3b00ef435fa4fcff5c209a37d1f3dcff37c705ad","symbol":"USDT","decimals":6}},"id":0}',
        200,
      ));
    });

    final tokens = await zksync.getTokens();

    expect(tokens, contains('ETH'));
    expect(tokens, contains('USDT'));

    expect(tokens['ETH'], equals(Token.eth));
    expect(
        tokens['USDT'],
        equals(Token(
            1,
            EthereumAddress.fromHex(
                '0x3b00ef435fa4fcff5c209a37d1f3dcff37c705ad'),
            'USDT',
            6)));
  });

  group('token price', () {
    test('get token price by id', () async {
      when(client.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((i) {
        return Future.value(Response(
          '{"jsonrpc":"2.0","result":"1826.748271","id":0}',
          200,
        ));
      });

      final payload =
          '{"jsonrpc":"2.0","method":"get_token_price","params":[0],"id":';

      final price = await zksync.getTokenPrice(TokenLike.id(0));

      verify(client.post(any,
          headers: anyNamed('headers'), body: startsWith(payload)));

      expect(price, equals(1826.748271));
    });

    test('get token price by id high precition', () async {
      when(client.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((i) {
        return Future.value(Response(
          '{"jsonrpc":"2.0","result":"1826.7482710000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000","id":0}',
          200,
        ));
      });

      final payload =
          '{"jsonrpc":"2.0","method":"get_token_price","params":[0],"id":';

      final price = await zksync.getTokenPrice(TokenLike.id(0));

      verify(client.post(any,
          headers: anyNamed('headers'), body: startsWith(payload)));

      expect(price, equals(1826.748271));
    });

    test('get token price by token address', () async {
      when(client.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((i) {
        return Future.value(Response(
          '{"jsonrpc":"2.0","result":"1826.748271","id":0}',
          200,
        ));
      });

      final payload =
          '{"jsonrpc":"2.0","method":"get_token_price","params":["0x0000000000000000000000000000000000000000"],"id":';

      final price = await zksync.getTokenPrice(TokenLike.address(
          EthereumAddress.fromHex(
              "0x0000000000000000000000000000000000000000")));

      verify(client.post(any,
          headers: anyNamed('headers'), body: startsWith(payload)));

      expect(price, equals(1826.748271));
    });

    test('get token price by token address', () async {
      when(client.post(any,
              headers: anyNamed('headers'), body: anyNamed('body')))
          .thenAnswer((i) {
        return Future.value(Response(
          '{"jsonrpc":"2.0","result":"1826.748271","id":0}',
          200,
        ));
      });

      final payload =
          '{"jsonrpc":"2.0","method":"get_token_price","params":["ETH"],"id":';

      final price = await zksync.getTokenPrice(TokenLike.symbol("ETH"));

      verify(client.post(any,
          headers: anyNamed('headers'), body: startsWith(payload)));

      expect(price, equals(1826.748271));
    });
  });

  test('get contract addresses', () async {
    when(client.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
        .thenAnswer((i) {
      return Future.value(Response(
        '{"jsonrpc":"2.0","result":{"mainContract":"0x82f67958a5474e40e1485742d648c0b0686b6e5d","govContract":"0xc8568f373484cd51fdc1fe3675e46d8c0dc7d246"},"id":0}',
        200,
      ));
    });

    final contracts = await zksync.getContractAddress();

    expect(contracts.mainContract.hex,
        equals('0x82f67958a5474e40e1485742d648c0b0686b6e5d'));
    expect(contracts.govContract.hex,
        equals('0xc8568f373484cd51fdc1fe3675e46d8c0dc7d246'));
  });

  test('get transaction execution status', () async {
    when(client.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
        .thenAnswer((i) {
      return Future.value(Response(
        '{"jsonrpc":"2.0","result":{"executed":true,"success":true,"failReason":null,"block":{"blockNumber":6052,"committed":true,"verified":true}},"id":0}',
        200,
      ));
    });

    final payload =
        '{"jsonrpc":"2.0","method":"tx_info","params":["sync-tx:a5884908c610bf0b86905dbdf23dc58a099fe8eb60ab34ac107c6c8836e7e60a"],"id":';

    final status = await zksync.getTransactionStatus(
        'sync-tx:a5884908c610bf0b86905dbdf23dc58a099fe8eb60ab34ac107c6c8836e7e60a');

    verify(client.post(any,
        headers: anyNamed('headers'), body: startsWith(payload)));

    expect(status.success, isTrue);
    expect(status.executed, isTrue);
    expect(status.block.blockNumber, equals(6052));
  });

  test('get priority operation status', () async {
    when(client.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
        .thenAnswer((i) {
      return Future.value(Response(
        '{"jsonrpc":"2.0","result":{"executed":true,"block":{"blockNumber":1269,"committed":true,"verified":true}},"id":0}',
        200,
      ));
    });

    final payload =
        '{"jsonrpc":"2.0","method":"ethop_info","params":[10],"id":';

    final status = await zksync.getEthOpInfo(10);

    verify(client.post(any,
        headers: anyNamed('headers'), body: startsWith(payload)));

    expect(status.executed, isTrue);
    expect(status.block.blockNumber, equals(1269));
    expect(status.block.committed, isTrue);
    expect(status.block.verified, isTrue);
  });

  test('get confirmations for priority operation', () async {
    when(client.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
        .thenAnswer((i) {
      return Future.value(Response(
        '{"jsonrpc":"2.0","result":10,"id":0}',
        200,
      ));
    });

    final result = await zksync.getConfirmationsForEthOpAmount();

    expect(result, equals(10));
  });

  test('get transaction hash for withdrawal on L1', () async {
    when(client.post(any, headers: anyNamed('headers'), body: anyNamed('body')))
        .thenAnswer((i) {
      return Future.value(Response(
        '{"jsonrpc":"2.0","result":"0x3e48e25a51ed738a97011f2fec10e3826828904f80defefbd434de4f856f3153","id":0}',
        200,
      ));
    });

    final result = await zksync.getEthTransactionForWithdrawal(
        "sync-tx:3e48e25a51ed738a97011f2fec10e3826828904f80defefbd434de4f856f3153");

    expect(
        result,
        equals(
            "0x3e48e25a51ed738a97011f2fec10e3826828904f80defefbd434de4f856f3153"));
  });
}
