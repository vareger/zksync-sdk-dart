part of 'package:zksync/client.dart';

class AccountState {
  String address;
  int id;
  DepositingState depositing;
  State commited;
  State verified;

  AccountState.fromJson(Map<String, dynamic> json)
      : address = json["address"],
        id = json["id"],
        depositing = DepositingState.fromJson(json["depositing"]["balances"]),
        commited = State.fromJson(json["committed"]),
        verified = State.fromJson(json["verified"]);
}
