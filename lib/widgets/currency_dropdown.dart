import 'package:flutter/material.dart';
import '../models/currency_model.dart';

class CurrencyDropdown extends StatelessWidget {
  final String label;
  final List<Currency> currencies;
  final String selectedCurrency;
  final Function(String?) onChanged;

  const CurrencyDropdown({
    super.key,
    required this.label,
    required this.currencies,
    required this.selectedCurrency,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey.shade300),
            borderRadius: BorderRadius.circular(8),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedCurrency,
              isExpanded: true,
              icon: const Icon(Icons.keyboard_arrow_down),
              items: currencies.map((Currency currency) {
                return DropdownMenuItem<String>(
                  value: currency.code,
                  child: Text('${currency.code} - ${currency.name}'),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        ),
      ],
    );
  }
}
