import 'package:equatable/equatable.dart';

abstract class CurrencyEvent extends Equatable {
  const CurrencyEvent();

  @override
  List<Object?> get props => [];
}

class InitializeCurrency extends CurrencyEvent {}

class SetFromCurrency extends CurrencyEvent {
  final String currency;

  const SetFromCurrency(this.currency);

  @override
  List<Object?> get props => [currency];
}

class SetToCurrency extends CurrencyEvent {
  final String currency;

  const SetToCurrency(this.currency);

  @override
  List<Object?> get props => [currency];
}

class SetAmount extends CurrencyEvent {
  final double amount;

  const SetAmount(this.amount);

  @override
  List<Object?> get props => [amount];
}

class SwapCurrencies extends CurrencyEvent {}

class ConvertCurrency extends CurrencyEvent {}

class FetchHistoricalRates extends CurrencyEvent {
  final DateTime date;

  const FetchHistoricalRates(this.date);

  @override
  List<Object?> get props => [date];
}

class FetchHistoricalChart extends CurrencyEvent {
  final DateTime startDate;
  final DateTime endDate;

  const FetchHistoricalChart(this.startDate, this.endDate);

  @override
  List<Object?> get props => [startDate, endDate];
}
