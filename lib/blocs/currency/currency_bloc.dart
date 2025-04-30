import 'package:bloc/bloc.dart';
import 'package:intl/intl.dart';
import '../../services/currency_service.dart';
import 'currency_event.dart';
import 'currency_state.dart';

class CurrencyBloc extends Bloc<CurrencyEvent, CurrencyState> {
  final CurrencyService _currencyService = CurrencyService();

  CurrencyBloc() : super(CurrencyState()) {
    on<InitializeCurrency>(_onInitializeCurrency);
    on<SetFromCurrency>(_onSetFromCurrency);
    on<SetToCurrency>(_onSetToCurrency);
    on<SetAmount>(_onSetAmount);
    on<SwapCurrencies>(_onSwapCurrencies);
    on<ConvertCurrency>(_onConvertCurrency);
    on<FetchHistoricalRates>(_onFetchHistoricalRates);
    on<FetchHistoricalChart>(_onFetchHistoricalChart);
  }

  Future<void> _onInitializeCurrency(
    InitializeCurrency event,
    Emitter<CurrencyState> emit,
  ) async {
    try {
      emit(state.copyWith(isLoading: true, error: null));

      final currencies = await _currencyService.fetchCurrencies();

      emit(state.copyWith(
        currencies: currencies,
        isLoading: false,
      ));

      add(ConvertCurrency());
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Failed to initialize: ${e.toString()}',
      ));
    }
  }

  Future<void> _onSetFromCurrency(
    SetFromCurrency event,
    Emitter<CurrencyState> emit,
  ) async {
    if (state.fromCurrency != event.currency) {
      emit(state.copyWith(fromCurrency: event.currency));
      add(ConvertCurrency());
    }
  }

  Future<void> _onSetToCurrency(
    SetToCurrency event,
    Emitter<CurrencyState> emit,
  ) async {
    if (state.toCurrency != event.currency) {
      emit(state.copyWith(toCurrency: event.currency));
      add(ConvertCurrency());
    }
  }

  Future<void> _onSetAmount(
    SetAmount event,
    Emitter<CurrencyState> emit,
  ) async {
    if (state.amount != event.amount && event.amount > 0) {
      emit(state.copyWith(amount: event.amount));
      add(ConvertCurrency());
    }
  }

  Future<void> _onSwapCurrencies(
    SwapCurrencies event,
    Emitter<CurrencyState> emit,
  ) async {
    final fromCurrency = state.fromCurrency;
    final toCurrency = state.toCurrency;

    emit(state.copyWith(
      fromCurrency: toCurrency,
      toCurrency: fromCurrency,
    ));

    add(ConvertCurrency());
  }

  Future<void> _onConvertCurrency(
    ConvertCurrency event,
    Emitter<CurrencyState> emit,
  ) async {
    if (state.amount <= 0) {
      emit(state.copyWith(error: 'Amount must be greater than 0'));
      return;
    }

    try {
      emit(state.copyWith(isLoading: true, error: null));

      final result = await _currencyService.fetchLatestRates(
        state.fromCurrency,
        state.toCurrency,
        state.amount,
      );

      if (result.rates.containsKey(state.toCurrency)) {
        emit(state.copyWith(
          convertedAmount: result.rates[state.toCurrency]!,
          isLoading: false,
        ));
      } else {
        emit(state.copyWith(
          isLoading: false,
          error: 'Conversion rate not available for ${state.toCurrency}',
        ));
      }
    } catch (e) {
      emit(state.copyWith(
        isLoading: false,
        error: 'Conversion failed: ${e.toString()}',
      ));
    }
  }

  Future<void> _onFetchHistoricalRates(
    FetchHistoricalRates event,
    Emitter<CurrencyState> emit,
  ) async {
    try {
      emit(state.copyWith(
        selectedDate: event.date,
        isLoadingHistorical: true,
        historicalError: null,
      ));

      final dateString = DateFormat('yyyy-MM-dd').format(event.date);
      final result = await _currencyService.fetchHistoricalRates(
        dateString,
        state.fromCurrency,
        state.toCurrency,
      );

      emit(state.copyWith(
        historicalRate: result,
        isLoadingHistorical: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingHistorical: false,
        historicalError: 'Failed to fetch historical rates: ${e.toString()}',
      ));
    }
  }

  Future<void> _onFetchHistoricalChart(
    FetchHistoricalChart event,
    Emitter<CurrencyState> emit,
  ) async {
    try {
      emit(state.copyWith(
        isLoadingChart: true,
        chartError: null,
      ));

      final startDateString = DateFormat('yyyy-MM-dd').format(event.startDate);
      final endDateString = DateFormat('yyyy-MM-dd').format(event.endDate);

      final result = await _currencyService.fetchHistoricalRatesRange(
        startDateString,
        endDateString,
        state.fromCurrency,
        state.toCurrency,
      );

      emit(state.copyWith(
        chartData: result,
        isLoadingChart: false,
      ));
    } catch (e) {
      emit(state.copyWith(
        isLoadingChart: false,
        chartError: 'Failed to fetch chart data: ${e.toString()}',
      ));
    }
  }
}
