import 'package:currency_converter/models/currency_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CurrencyService {
  static const String baseUrl = 'https://api.frankfurter.app';

  Future<List<Currency>> fetchCurrencies() async {
    final response = await http.get(Uri.parse('$baseUrl/currencies'));

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      List<Currency> currencies = [];

      data.forEach((code, name) {
        currencies.add(Currency(code: code, name: name));
      });

      return currencies;
    } else {
      throw Exception('Failed to load currencies');
    }
  }

  Future<ExchangeRate> fetchLatestRates(
      String fromCurrency, String toCurrency, double amount) async {
    final response = await http.get(
      Uri.parse(
          '$baseUrl/latest?from=$fromCurrency&to=$toCurrency&amount=$amount'),
    );

    if (response.statusCode == 200) {
      return ExchangeRate.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load exchange rates');
    }
  }

  Future<HistoricalRate> fetchHistoricalRates(
      String date, String fromCurrency, String toCurrency) async {
    final response = await http.get(
      Uri.parse('$baseUrl/$date?from=$fromCurrency&to=$toCurrency'),
    );

    if (response.statusCode == 200) {
      return HistoricalRate.fromJson(json.decode(response.body));
    } else {
      throw Exception('Failed to load historical rates');
    }
  }

  Future<Map<String, dynamic>> fetchHistoricalRatesRange(String startDate,
      String endDate, String fromCurrency, String toCurrency) async {
    final response = await http.get(
      Uri.parse(
          '$baseUrl/$startDate..$endDate?from=$fromCurrency&to=$toCurrency'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load historical rates range');
    }
  }
}
