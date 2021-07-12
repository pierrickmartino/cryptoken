import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:intl/intl.dart' as intl;

class TokenController extends GetxController {
  static TokenController get to => Get.find();
  final box = GetStorage();

  String tokenUpdatedDate(String token) => box.read('date_$token') ?? '';
  double tokenPrice(String token) => box.read('price_$token') ?? 0;
  double tokenVar24(String token) => box.read('var24_$token') ?? 0;
  double tokenVar24Percent(String token) => box.read('var24%_$token') ?? 0;

  void setTokenUpdatedDate(String token) => box.write('date_$token',
      intl.DateFormat('dd.MM.yyyy HH:mm').format(DateTime.now()));
  void setTokenPrice(String token, double price) =>
      box.write('price_$token', price);
  void setTokenVar24(String token, double priceChange) =>
      box.write('var24_$token', priceChange);
  void setTokenVar24Percent(String token, double priceChangePercent) =>
      box.write('var24%_$token', priceChangePercent);
}
