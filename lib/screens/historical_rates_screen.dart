import 'package:currency_converter/blocs/currency/currency_bloc.dart';
import 'package:currency_converter/blocs/currency/currency_event.dart';
import 'package:currency_converter/blocs/currency/currency_state.dart';
import 'package:currency_converter/widgets/historical_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

class HistoricalRatesScreen extends StatefulWidget {
  const HistoricalRatesScreen({super.key});

  @override
  State<HistoricalRatesScreen> createState() => _HistoricalRatesScreenState();
}

class _HistoricalRatesScreenState extends State<HistoricalRatesScreen> {
  DateTime _selectedDate = DateTime.now();
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();
  final DateFormat _dateFormat = DateFormat('yyyy-MM-dd');

  @override
  void initState() {
    super.initState();
    // Fetch historical rates for the current date
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CurrencyBloc>().add(FetchHistoricalRates(_selectedDate));
      context
          .read<CurrencyBloc>()
          .add(FetchHistoricalChart(_startDate, _endDate));
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      if (mounted) {
        context.read<CurrencyBloc>().add(FetchHistoricalRates(_selectedDate));
      }
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime(2000),
      lastDate: _endDate,
    );
    if (picked != null && picked != _startDate && mounted) {
      setState(() {
        _startDate = picked;
      });
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: _startDate,
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _endDate && mounted) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Historical Rates'),
      ),
      body: BlocBuilder<CurrencyBloc, CurrencyState>(
        builder: (context, state) {
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              // Historical rate for a specific date
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Historical Exchange Rate',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              'Date: ${_dateFormat.format(_selectedDate)}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () => _selectDate(context),
                            child: const Text('Select Date'),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      if (state.isLoadingHistorical)
                        const Center(child: CircularProgressIndicator())
                      else if (state.historicalError != null)
                        Text(
                          'Error: ${state.historicalError}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        )
                      else if (state.historicalRate != null)
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'From: ${state.fromCurrency}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'To: ${state.toCurrency}',
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Rate: ${state.historicalRate!.rates[state.toCurrency]?.toStringAsFixed(4) ?? "N/A"}',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Converted Amount: ${(state.amount * (state.historicalRate!.rates[state.toCurrency] ?? 0)).toStringAsFixed(2)} ${state.toCurrency}',
                              style: const TextStyle(fontSize: 16),
                            ),
                          ],
                        )
                      else
                        const Text('No historical data available'),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Historical chart
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Exchange Rate Trend',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Date selection row
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 1.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: Card(
                                elevation: 0,
                                margin: EdgeInsets.zero,
                                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'Start Date',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                            _dateFormat.format(_startDate),
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          const Spacer(),
                                          IconButton(
                                            onPressed: () => _selectStartDate(context),
                                            icon: const Icon(Icons.calendar_today, size: 20),
                                            tooltip: 'Select start date',
                                            style: IconButton.styleFrom(
                                              padding: const EdgeInsets.all(4),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Card(
                                elevation: 0,
                                margin: EdgeInsets.zero,
                                color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      const Text(
                                        'End Date',
                                        style: TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Text(
                                            _dateFormat.format(_endDate),
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                          const Spacer(),
                                          IconButton(
                                            onPressed: () => _selectEndDate(context),
                                            icon: const Icon(Icons.calendar_today, size: 20),
                                            tooltip: 'Select end date',
                                            style: IconButton.styleFrom(
                                              padding: const EdgeInsets.all(4),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 12),
                      Center(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            context.read<CurrencyBloc>().add(
                                FetchHistoricalChart(_startDate, _endDate));
                          },
                          icon: const Icon(Icons.refresh),
                          label: const Text('Update Chart'),
                        ),
                      ),
                      const SizedBox(height: 16),
                      if (state.isLoadingChart)
                        const Center(child: CircularProgressIndicator())
                      else if (state.chartError != null)
                        Text(
                          'Error: ${state.chartError}',
                          style: TextStyle(
                            color: Theme.of(context).colorScheme.error,
                          ),
                        )
                      else if (state.chartData != null)
                        Container(
                          constraints: BoxConstraints(
                            minHeight: MediaQuery.of(context).size.height * 0.4,
                          ),
                          child: HistoricalChart(
                            chartData: state.chartData!,
                            fromCurrency: state.fromCurrency,
                            toCurrency: state.toCurrency,
                          ),
                        )
                      else
                        const Center(
                          child: Text('No chart data available'),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
