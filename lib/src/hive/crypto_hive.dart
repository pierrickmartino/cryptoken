import 'package:hive/hive.dart';

part 'crypto_hive.g.dart';

@HiveType(typeId: 0)
class CryptoHive extends HiveObject {
  @HiveField(0)
  late String symbol;
  @HiveField(1)
  late String id;
  @HiveField(2)
  late String name;
  @HiveField(3)
  late String category;
  @HiveField(4)
  late String slug;
  @HiveField(5)
  late String logo;
}
