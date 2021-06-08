class Price {
  Price({
    required this.symbol,
    required this.price,
  });

  factory Price.fromJson(Map<String, dynamic> json) {
    return Price(
      symbol: json['symbol'],
      price: double.parse(json['price']),
    );
  }

  final String symbol;
  final double price;
}
