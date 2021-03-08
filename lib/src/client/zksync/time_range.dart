part of 'package:zksync/client.dart';

class TimeRange {
  final DateTime _from, _until;

  const TimeRange(this._from, this._until);
  TimeRange.raw(int from, int until)
      : this._from = DateTime.fromMillisecondsSinceEpoch(from * 1000),
        this._until = DateTime.fromMillisecondsSinceEpoch(until * 1000);

  TimeRange.def() : this.raw(0, 4294967295);

  DateTime get validFrom => _from;
  DateTime get validUntil => _until;

  int get validFromSeconds => _from.millisecondsSinceEpoch ~/ 1000;
  int get validUntilSeconds => _until.millisecondsSinceEpoch ~/ 1000;
}
