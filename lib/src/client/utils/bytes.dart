part of 'package:zksync/client.dart';

const AMOUNT_EXPONENT_BIT_WIDTH = 5;
const AMOUNT_MANTISSA_BIT_WIDTH = 35;

const FEE_EXPONENT_BIT_WIDTH = 5;
const FEE_MANTISSA_BIT_WIDTH = 11;

extension ToBytesBigEndian on int {
  Uint8List uint64BigEndianBytes() =>
      Uint8List(8)..buffer.asByteData().setUint64(0, this, Endian.big);

  Uint8List uint32BigEndianBytes() =>
      Uint8List(4)..buffer.asByteData().setUint32(0, this, Endian.big);

  Uint8List uint16BigEndianBytes() =>
      Uint8List(2)..buffer.asByteData().setUint16(0, this, Endian.big);
}

BitArray toFloat(
    BigInt value, int exponentLength, int mantissaLength, BigInt exponentBase) {
  var maxExponent = BigInt.one;
  final maxPower = (1 << exponentLength) - 1;
  for (var i = 0; i < maxPower; i++) {
    maxExponent = maxExponent * exponentBase;
  }

  final maxMantissa = (BigInt.one << mantissaLength) - BigInt.one;

  if (value > (maxMantissa * maxExponent)) {
    throw "Integer is too big";
  }

  var exponent = 0;
  var mantissa = value;

  if (value > maxMantissa) {
    var exponentTemp = BigInt.from(value / maxMantissa);

    for (; exponentTemp >= exponentBase;) {
      exponentTemp = BigInt.from(exponentTemp / exponentBase);
      exponent += 1;
    }

    exponentTemp = BigInt.one;

    for (var i = 0; i < exponent; i++) {
      exponentTemp = exponentTemp * exponentBase;
    }

    if (exponentTemp * maxMantissa < value) {
      exponent += 1;
      exponentTemp = exponentTemp * exponentBase;
    }

    mantissa = BigInt.from(value / exponentTemp);
  }

  final result = BitArray(exponentLength + mantissaLength);
  for (int i = 0; i < exponentLength; i++) {
    result[i] = (exponent & (1 << i)) != 0;
  }
  for (int i = 0; i < mantissaLength; i++) {
    result[i + exponentLength] =
        (mantissa & (BigInt.one << i)).compareTo(BigInt.zero) != 0;
  }

  return result;
}

Uint8List pack(BigInt value, int exponentLength, int mantissaLength) {
  final size = (exponentLength + mantissaLength) ~/ 8;
  var binary = toFloat(value, exponentLength, mantissaLength, BigInt.from(10));
  var result = binary.byteBuffer.asUint8List().sublist(0, size).reversed;
  return Uint8List.fromList(result.toList());
}

Uint8List packTokenAmount(BigInt value) {
  return pack(value, AMOUNT_EXPONENT_BIT_WIDTH, AMOUNT_MANTISSA_BIT_WIDTH);
}

Uint8List packFeeAmount(BigInt value) {
  return pack(value, FEE_EXPONENT_BIT_WIDTH, FEE_MANTISSA_BIT_WIDTH);
}

/**
 * The regular BigInteger.toByteArray() method isn't quite what we often need:
 * it appends a leading zero to indicate that the number is positive and may
 * need padding.
 */
Uint8List bigIntegerToBytes(BigInt b, int numBytes) {
  if (b == null) {
    return null;
  }
  Uint8List bytes = new Uint8List(numBytes);
  Uint8List biBytes = encodeBigIntAsUnsigned(b);
  int start = (biBytes.length == numBytes + 1) ? 1 : 0;
  int length = min(biBytes.length, numBytes);
  bytes.setRange(
      numBytes - length, numBytes, biBytes.sublist(start, start + length));
  return bytes;
}

String formatUnit(String wei, int units) {
  wei = wei.padLeft(units, '0');
  final index = wei.length - units;
  wei = wei.substring(0, index) + '.' + wei.substring(index);
  if (wei[0] == '.') {
    wei = '0' + wei;
  }
  var pos = wei.length;
  while (wei[pos - 1] == '0') {
    pos--;
  }
  wei = wei.substring(0, pos);
  if (wei[wei.length - 1] == '.') {
    wei = wei + '0';
  }
  return wei;
}
