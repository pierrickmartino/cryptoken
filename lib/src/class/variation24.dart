class Variation24 {
  Variation24({
    required this.symbol,
    required this.priceChange,
    required this.priceChangePercent,
    required this.weightedAvgPrice,
    required this.prevClosePrice,
    required this.lastPrice,
    required this.lastQty,
    required this.bidPrice,
    required this.askPrice,
    required this.openPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.volume,
    required this.quoteVolume,
    required this.openTime,
    required this.closeTime,
    required this.firstId,
    required this.lastId,
    required this.count,
  });

  factory Variation24.fromJson(Map<String, dynamic> json) {
    return Variation24(
      symbol: json['symbol'],
      priceChange: double.parse(json['priceChange']),
      priceChangePercent: double.parse(json['priceChangePercent']),
      weightedAvgPrice: double.parse(json['weightedAvgPrice']),
      prevClosePrice: double.parse(json['prevClosePrice']),
      lastPrice: double.parse(json['lastPrice']),
      lastQty: double.parse(json['lastQty']),
      bidPrice: double.parse(json['bidPrice']),
      askPrice: double.parse(json['askPrice']),
      openPrice: double.parse(json['openPrice']),
      highPrice: double.parse(json['highPrice']),
      lowPrice: double.parse(json['lowPrice']),
      volume: double.parse(json['volume']),
      quoteVolume: double.parse(json['quoteVolume']),
      openTime: json['openTime'], // already an int
      closeTime: json['closeTime'], // already an int
      firstId: json['firstId'], // already an int
      lastId: json['lastId'], // already an int
      count: json['count'], // already an int
    );
  }

  final String symbol;
  final double priceChange;
  final double priceChangePercent;
  final double weightedAvgPrice;
  final double prevClosePrice;
  final double lastPrice;
  final double lastQty;
  final double bidPrice;
  final double askPrice;
  final double openPrice;
  final double highPrice;
  final double lowPrice;
  final double volume;
  final double quoteVolume;
  final int openTime; // TODO : Transform in DateTime
  final int closeTime; // TODO : Transform in DateTime
  final int firstId;
  final int lastId;
  final int count;
}
