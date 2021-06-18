class Variation24 {
  Variation24({
    required this.symbol,
    required this.priceChange,
    required this.priceChangePercent,
    this.weightedAvgPrice = 0,
    this.prevClosePrice = 0,
    this.lastPrice = 0,
    this.lastQty = 0,
    this.bidPrice = 0,
    this.askPrice = 0,
    this.openPrice = 0,
    this.highPrice = 0,
    this.lowPrice = 0,
    this.volume = 0,
    this.quoteVolume = 0,
    this.openTime = 0,
    this.closeTime = 0,
    this.firstId = 0,
    this.lastId = 0,
    this.count = 0,
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
  double weightedAvgPrice;
  double prevClosePrice;
  double lastPrice;
  double lastQty;
  double bidPrice;
  double askPrice;
  double openPrice;
  double highPrice;
  double lowPrice;
  double volume;
  double quoteVolume;
  int openTime; // TODO : Transform in DateTime
  int closeTime; // TODO : Transform in DateTime
  int firstId;
  int lastId;
  int count;
}
