import 'crypto.dart';

class CryptosList {
  CryptosList({
    required this.cryptos,
  });

  factory CryptosList.fromJson(List<dynamic> parsedJson) {
    List<Crypto> cryptos = <Crypto>[];
    cryptos = parsedJson.map((i) => Crypto.fromJson(i)).toList();

    return CryptosList(
      cryptos: cryptos,
    );
  }

  final List<Crypto> cryptos;
}
