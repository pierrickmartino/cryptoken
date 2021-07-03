//User Model
import 'package:json_annotation/json_annotation.dart';

class WalletModel {
  WalletModel({required this.name});

  factory WalletModel.fromMap(Map data) {
    return WalletModel(
      name: data['name'] ?? '',
    );
  }

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(name: json['name'] as String);
  }

  final String name;

  @JsonKey(ignore: true)
  late String id;

  Map<String, dynamic> toJson() => {'name': name};
}
