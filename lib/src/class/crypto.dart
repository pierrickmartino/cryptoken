class Crypto {
  Crypto(
      {required this.id,
      required this.name,
      required this.symbol,
      required this.category,
      required this.slug,
      required this.logo});

  factory Crypto.fromJson(Map<String, dynamic> json) {
    return Crypto(
      id: json['id'].toString(),
      name: json['name'],
      symbol: json['symbol'],
      category: json['category'],
      slug: json['slug'],
      logo: json['logo'],
    );
  }

  final String id;
  final String name;
  final String symbol;
  final String category;
  final String slug;
  final String logo;

  static List<Crypto> fromJsonList(List<dynamic> list) {
    return list.map((item) => Crypto.fromJson(item)).toList();
  }

  ///this method will prevent the override of toString
  String cryptoAsString() {
    return '#$symbol $name';
  }

  ///custom comparing function to check if two users are equal
  bool isEqual(Crypto crypto) {
    return id == crypto.id;
  }

  @override
  String toString() => symbol;
}
