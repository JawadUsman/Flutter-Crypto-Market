class Currency {
  final String id;
  final String symbol;
  final String name;
  final String image;
  final double currentPrice;
  final double marketCap;
  final double priceChange24h;
  final int marketCapRank;
  final double totalVolume; // Added totalVolume

  Currency({
    required this.id,
    required this.symbol,
    required this.name,
    required this.image,
    required this.currentPrice,
    required this.marketCap,
    required this.priceChange24h,
    required this.marketCapRank,
    required this.totalVolume, // Added totalVolume
  });

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      id: json['id'],
      symbol: json['symbol'],
      name: json['name'],
      image: json['image'],
      currentPrice: (json['current_price'] as num).toDouble(),
      marketCap: (json['market_cap'] as num).toDouble(),
      priceChange24h: (json['price_change_24h'] as num).toDouble(),
      marketCapRank: (json['market_cap_rank'] as num).toInt(),
      totalVolume: (json['total_volume'] as num).toDouble(), // Added totalVolume parsing
    );
  }
}
