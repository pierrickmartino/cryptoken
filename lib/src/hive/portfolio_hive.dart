import 'package:hive/hive.dart';

part 'portfolio_hive.g.dart';

@HiveType(typeId: 1)
class PortfolioHive extends HiveObject {
  @HiveField(0)
  late String id;
  @HiveField(1)
  late String name;
  @HiveField(2)
  late double valuation;
  @HiveField(3)
  late double variation24;
  @HiveField(4)
  late double realizedGain;
  @HiveField(5)
  late double unrealizedGain;
}
