import 'dart:ffi';
import 'dart:typed_data';
import 'dart:convert';

import 'package:ffi/ffi.dart';
import 'package:test/test.dart';
import 'package:zksync/src/native/zks_crypto.dart';
import 'package:zksync/src/native/zks_crypto_bindings.dart';

void main() {
  ZksCrypto zksCrypto = ZksCrypto();

  test('private key generation from seed', () {
    var seed = Uint8List(32);
    final expected = [
      1,
      31,
      91,
      153,
      8,
      76,
      92,
      46,
      45,
      94,
      99,
      72,
      142,
      15,
      113,
      104,
      213,
      153,
      165,
      192,
      31,
      233,
      254,
      196,
      201,
      150,
      5,
      116,
      61,
      165,
      232,
      92
    ];
    final result = zksCrypto.generatePrivateKeyFromSeed(seed);
    ZksPrivateKey pk = result.ref;
    final data = pk.data;
    for (int i = 0; i < 32; i++) {
      expect(data[i], equals(expected[i]));
    }
  });

  test('public key generation from private key', () {
    final pk = [
      1,
      31,
      91,
      153,
      8,
      76,
      92,
      46,
      45,
      94,
      99,
      72,
      142,
      15,
      113,
      104,
      213,
      153,
      165,
      192,
      31,
      233,
      254,
      196,
      201,
      150,
      5,
      116,
      61,
      165,
      232,
      92
    ];
    var privateKey = allocate<ZksPrivateKey>();
    var privateKeyRef = privateKey.ref;
    var data = privateKeyRef.data;
    for (int i = 0; i < 32; i++) {
      data[i] = pk[i];
    }
    final result = zksCrypto.getPublicKey(privateKey);
    final expected = [
      23,
      156,
      58,
      89,
      20,
      125,
      48,
      49,
      108,
      136,
      102,
      40,
      133,
      35,
      72,
      201,
      180,
      42,
      24,
      184,
      33,
      8,
      74,
      201,
      239,
      121,
      189,
      115,
      233,
      185,
      78,
      141
    ];
    var rdata = result.ref.data;
    for (int i = 0; i < 32; i++) {
      expect(rdata[i], equals(expected[i]));
    }
  });

  test('public key hash generation from publick key', () {
    final pk = [
      23,
      156,
      58,
      89,
      20,
      125,
      48,
      49,
      108,
      136,
      102,
      40,
      133,
      35,
      72,
      201,
      180,
      42,
      24,
      184,
      33,
      8,
      74,
      201,
      239,
      121,
      189,
      115,
      233,
      185,
      78,
      141
    ];
    var publicKey = allocate<ZksPackedPublicKey>();
    var publicKeyRef = publicKey.ref;
    var data = publicKeyRef.data;
    for (int i = 0; i < 32; i++) {
      data[i] = pk[i];
    }
    final result = zksCrypto.getPublicKeyHash(publicKey);
    final expected = [
      199,
      113,
      39,
      22,
      185,
      239,
      107,
      210,
      23,
      83,
      196,
      233,
      29,
      236,
      195,
      81,
      177,
      17,
      192,
      109
    ];
    var rdata = result.ref.data;
    for (int i = 0; i < 20; i++) {
      expect(rdata[i], equals(expected[i]));
    }
  });

  test('sign message', () {
    final pk = [
      1,
      31,
      91,
      153,
      8,
      76,
      92,
      46,
      45,
      94,
      99,
      72,
      142,
      15,
      113,
      104,
      213,
      153,
      165,
      192,
      31,
      233,
      254,
      196,
      201,
      150,
      5,
      116,
      61,
      165,
      232,
      92
    ];
    var privateKey = allocate<ZksPrivateKey>();
    var privateKeyRef = privateKey.ref;
    var data = privateKeyRef.data;
    for (int i = 0; i < 32; i++) {
      data[i] = pk[i];
    }
    final message = Utf8Encoder().convert("hello");
    final result = zksCrypto.sign(privateKey, message);
    final expected = [
      200,
      120,
      96,
      33,
      53,
      162,
      157,
      64,
      138,
      0,
      128,
      235,
      84,
      106,
      21,
      29,
      244,
      141,
      137,
      185,
      154,
      90,
      77,
      35,
      162,
      196,
      69,
      139,
      208,
      156,
      120,
      4,
      5,
      244,
      149,
      211,
      234,
      83,
      90,
      67,
      70,
      178,
      95,
      179,
      225,
      245,
      198,
      116,
      237,
      224,
      193,
      56,
      216,
      35,
      155,
      61,
      4,
      175,
      35,
      236,
      101,
      132,
      176,
      3
    ];
    var rdata = result.ref.data;
    for (int i = 0; i < 64; i++) {
      expect(rdata[i], equals(expected[i]));
    }
  });

  test('verify signed message', () {
    final pk = [
      23,
      156,
      58,
      89,
      20,
      125,
      48,
      49,
      108,
      136,
      102,
      40,
      133,
      35,
      72,
      201,
      180,
      42,
      24,
      184,
      33,
      8,
      74,
      201,
      239,
      121,
      189,
      115,
      233,
      185,
      78,
      141
    ];
    var publicKey = allocate<ZksPackedPublicKey>();
    var publicKeyRef = publicKey.ref;
    var data = publicKeyRef.data;
    for (int i = 0; i < 32; i++) {
      data[i] = pk[i];
    }

    final sig = [
      200,
      120,
      96,
      33,
      53,
      162,
      157,
      64,
      138,
      0,
      128,
      235,
      84,
      106,
      21,
      29,
      244,
      141,
      137,
      185,
      154,
      90,
      77,
      35,
      162,
      196,
      69,
      139,
      208,
      156,
      120,
      4,
      5,
      244,
      149,
      211,
      234,
      83,
      90,
      67,
      70,
      178,
      95,
      179,
      225,
      245,
      198,
      116,
      237,
      224,
      193,
      56,
      216,
      35,
      155,
      61,
      4,
      175,
      35,
      236,
      101,
      132,
      176,
      3
    ];
    var signature = allocate<ZksSignature>();
    var signatureRef = signature.ref;
    var sigData = signatureRef.data;
    for (int i = 0; i < 64; i++) {
      sigData[i] = sig[i];
    }
    final message = Utf8Encoder().convert("hello");
    final result = zksCrypto.verify(publicKey, signature, message);

    expect(result, isTrue);
  });
}
