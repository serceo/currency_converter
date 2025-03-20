class Currency {
  final String code;
  final String name;

  Currency({required this.code, required this.name});
}

class ExchangeRate {
  final String base;
  final String date;
  final Map<String, double> rates;

  ExchangeRate({
    required this.base,
    required this.date,
    required this.rates,
  });

  factory ExchangeRate.fromJson(Map<String, dynamic> json) {
    Map<String, double> ratesMap = {};
    json['rates'].forEach((key, value) {
      ratesMap[key] = value.toDouble();
    });

    return ExchangeRate(
      base: json['base'],
      date: json['date'],
      rates: ratesMap,
    );
  }
}

class HistoricalRate {
  final String base;
  final String date;
  final Map<String, double> rates;

  HistoricalRate({
    required this.base,
    required this.date,
    required this.rates,
  });

  factory HistoricalRate.fromJson(Map<String, dynamic> json) {
    Map<String, double> ratesMap = {};
    json['rates'].forEach((key, value) {
      ratesMap[key] = value.toDouble();
    });

    return HistoricalRate(
      base: json['base'],
      date: json['date'],
      rates: ratesMap,
    );
  }
}
