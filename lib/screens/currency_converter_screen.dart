import 'package:currency_converter/blocs/currency/currency_bloc.dart';
import 'package:currency_converter/blocs/currency/currency_event.dart';
import 'package:currency_converter/blocs/currency/currency_state.dart';
import 'package:currency_converter/models/currency_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CurrencyConverterScreen extends StatefulWidget {
  const CurrencyConverterScreen({super.key});

  @override
  State<CurrencyConverterScreen> createState() =>
      _CurrencyConverterScreenState();
}

class _CurrencyConverterScreenState extends State<CurrencyConverterScreen> {
  final TextEditingController _amountController =
      TextEditingController(text: '1.0');

  @override
  void initState() {
    super.initState();
    _amountController.addListener(_updateAmount);
  }

  @override
  void dispose() {
    _amountController.removeListener(_updateAmount);
    _amountController.dispose();
    super.dispose();
  }

  void _updateAmount() {
    if (_amountController.text.isNotEmpty) {
      try {
        final amount = double.parse(_amountController.text);
        context.read<CurrencyBloc>().add(SetAmount(amount));
      } catch (e) {
        // Invalid number format, ignore
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Currency Converter'),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: () {
              Navigator.pushNamed(context, '/historical');
            },
          ),
        ],
      ),
      body: BlocBuilder<CurrencyBloc, CurrencyState>(
        builder: (context, state) {
          if (state.currencies.isEmpty && !state.isLoading) {
            // Initial load or error
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text('Failed to load currencies'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<CurrencyBloc>().add(InitializeCurrency());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }

          if (state.isLoading && state.currencies.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // From Currency Dropdown
                _buildCurrencyDropdown(
                  label: 'From',
                  value: state.fromCurrency,
                  currencies: state.currencies,
                  onChanged: (value) {
                    if (value != null) {
                      context.read<CurrencyBloc>().add(SetFromCurrency(value));
                    }
                  },
                ),

                // Swap Button
                Align(
                  alignment: Alignment.center,
                  child: IconButton(
                    icon: const Icon(Icons.swap_vert),
                    onPressed: () {
                      context.read<CurrencyBloc>().add(SwapCurrencies());
                    },
                  ),
                ),

                // To Currency Dropdown
                _buildCurrencyDropdown(
                  label: 'To',
                  value: state.toCurrency,
                  currencies: state.currencies,
                  onChanged: (value) {
                    if (value != null) {
                      context.read<CurrencyBloc>().add(SetToCurrency(value));
                    }
                  },
                ),

                const SizedBox(height: 24),

                // Amount Input
                TextField(
                  controller: _amountController,
                  decoration: const InputDecoration(
                    labelText: 'Amount',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType:
                      const TextInputType.numberWithOptions(decimal: true),
                ),

                const SizedBox(height: 24),

                // Convert Button
                ElevatedButton(
                  onPressed: () {
                    context.read<CurrencyBloc>().add(ConvertCurrency());
                  },
                  child: const Text('Convert'),
                ),

                const SizedBox(height: 24),

                // Result
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Converted Amount',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${state.amount} ${state.fromCurrency} = ${state.convertedAmount.toStringAsFixed(2)} ${state.toCurrency}',
                        style: const TextStyle(fontSize: 20),
                      ),
                    ],
                  ),
                ),

                if (state.error != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Text(
                      state.error!,
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.error,
                      ),
                    ),
                  ),

                const SizedBox(height: 24),

                // Historical Rates Button
                OutlinedButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/historical');
                  },
                  child: const Text('View Historical Rates'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildCurrencyDropdown({
    required String label,
    required String value,
    required List<Currency> currencies,
    required void Function(String?)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: const InputDecoration(
            border: OutlineInputBorder(),
          ),
          items: currencies
              .map((currency) => DropdownMenuItem(
                    value: currency.code,
                    child: Text('${currency.code} - ${currency.name}'),
                  ))
              .toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
