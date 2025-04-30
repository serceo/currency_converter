import 'package:currency_converter/models/currency_model.dart';
import 'package:equatable/equatable.dart';

class CurrencyState extends Equatable {
  final List<Currency> currencies;
  final String fromCurrency;
  final String toCurrency;
  final double amount;
  final double convertedAmount;
  final bool isLoading;
  final String? error;
  final DateTime selectedDate;
  final HistoricalRate? historicalRate;
  final bool isLoadingHistorical;
  final String? historicalError;
  final Map<String, dynamic>? chartData;
  final bool isLoadingChart;
  final String? chartError;

  CurrencyState({
    this.currencies = const [],
    this.fromCurrency = 'EUR',
    this.toCurrency = 'USD',
    this.amount = 1.0,
    this.convertedAmount = 0.0,
    this.isLoading = false,
    this.error,
    DateTime? selectedDate,
    this.historicalRate,
    this.isLoadingHistorical = false,
    this.historicalError,
    this.chartData,
    this.isLoadingChart = false,
    this.chartError,
  }) : selectedDate = selectedDate ?? DateTime.now();

  CurrencyState copyWith({
    List<Currency>? currencies,
    String? fromCurrency,
    String? toCurrency,
    double? amount,
    double? convertedAmount,
    bool? isLoading,
    String? error,
    DateTime? selectedDate,
    HistoricalRate? historicalRate,
    bool? isLoadingHistorical,
    String? historicalError,
    Map<String, dynamic>? chartData,
    bool? isLoadingChart,
    String? chartError,
  }) {
    return CurrencyState(
      currencies: currencies ?? this.currencies,
      fromCurrency: fromCurrency ?? this.fromCurrency,
      toCurrency: toCurrency ?? this.toCurrency,
      amount: amount ?? this.amount,
      convertedAmount: convertedAmount ?? this.convertedAmount,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      selectedDate: selectedDate ?? this.selectedDate,
      historicalRate: historicalRate ?? this.historicalRate,
      isLoadingHistorical: isLoadingHistorical ?? this.isLoadingHistorical,
      historicalError: historicalError ?? this.historicalError,
      chartData: chartData ?? this.chartData,
      isLoadingChart: isLoadingChart ?? this.isLoadingChart,
      chartError: chartError ?? this.chartError,
    );
  }

  @override
  List<Object?> get props => [
        currencies,
        fromCurrency,
        toCurrency,
        amount,
        convertedAmount,
        isLoading,
        error,
        selectedDate,
        historicalRate,
        isLoadingHistorical,
        historicalError,
        chartData,
        isLoadingChart,
        chartError,
      ];
}
