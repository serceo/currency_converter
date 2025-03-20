import 'package:currency_converter/blocs/currency/currency_bloc.dart';
import 'package:currency_converter/blocs/currency/currency_event.dart';
import 'package:currency_converter/screens/currency_converter_screen.dart';
import 'package:currency_converter/screens/historical_rates_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => CurrencyBloc()..add(InitializeCurrency()),
      child: MaterialApp(
        title: 'Safolio Currency Converter',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
          useMaterial3: true,
        ),
        home: const CurrencyConverterScreen(),
        routes: {
          '/historical': (context) => const HistoricalRatesScreen(),
        },
      ),
    );
  }
}
