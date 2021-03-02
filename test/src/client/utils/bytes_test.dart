import 'package:test/test.dart';
import 'package:zksync/client.dart';

void main() {
  test('convert amount to float packed', () {
    final amount = BigInt.from(0xDEADBEAF);
    final result = packTokenAmount(amount);
    expect(result, equals([27, 213, 183, 213, 224]));
  });

  test('test formatting string number to decimals', () {
    expect(formatUnit("1000000000000000100000", 0),
        equals("1000000000000000100000.0"));
    expect(formatUnit("0", 1), equals("0.0"));
    expect(
        formatUnit("11000000000000000000", 1), equals("1100000000000000000.0"));
    expect(formatUnit("0", 2), equals("0.0"));
    expect(formatUnit("1000000000000000100000", 2),
        equals("10000000000000001000.0"));
    expect(formatUnit("10001000000", 4), equals("1000100.0"));
    expect(formatUnit("10100000000000000000000", 4),
        equals("1010000000000000000.0"));
    expect(formatUnit("110", 4), equals("0.011"));
    expect(
        formatUnit("1000000000000000100000", 6), equals("1000000000000000.1"));
    expect(formatUnit("0", 8), equals("0.0"));
    expect(
        formatUnit("10100000000000000000000", 8), equals("101000000000000.0"));
    expect(formatUnit("110", 8), equals("0.0000011"));
    expect(
        formatUnit("10000000000000000001", 9), equals("10000000000.000000001"));
    expect(formatUnit("11000000", 9), equals("0.011"));
    expect(formatUnit("11000000000000000000", 9), equals("11000000000.0"));
    expect(formatUnit("10001000000", 10), equals("1.0001"));
    expect(
        formatUnit("20000000000000000000000", 10), equals("2000000000000.0"));
    expect(formatUnit("0", 11), equals("0.0"));
    expect(formatUnit("10100000000000000000000", 11), equals("101000000000.0"));
    expect(
        formatUnit("1000000000000000100000", 12), equals("1000000000.0000001"));
    expect(formatUnit("10001000000", 12), equals("0.010001"));
    expect(formatUnit("10010000000", 12), equals("0.01001"));
    expect(formatUnit("110", 12), equals("0.00000000011"));
    expect(formatUnit("10010000000", 13), equals("0.001001"));
    expect(formatUnit("10010000000", 14), equals("0.0001001"));
    expect(formatUnit("110", 14), equals("0.0000000000011"));
    expect(formatUnit("0", 15), equals("0.0"));
    expect(
        formatUnit("1000000000000000100000", 17), equals("10000.000000000001"));
    expect(formatUnit("10001000000", 17), equals("0.00000010001"));
    expect(
        formatUnit("1000000000000000100000", 18), equals("1000.0000000000001"));
  });
}
