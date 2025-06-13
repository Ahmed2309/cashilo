import 'package:cashilo/l10n/app_localizations.dart';
import 'package:flutter/material.dart';

class CurrencySelector extends StatelessWidget {
  final String selectedCurrency;
  final List<String> currencies;
  final ValueChanged<String> onChanged;

  const CurrencySelector({
    super.key,
    required this.selectedCurrency,
    required this.currencies,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: const Icon(Icons.attach_money),
      title: Text(AppLocalizations.of(context)!.currency),
      trailing: DropdownButton<String>(
        value: selectedCurrency,
        items: currencies
            .map((cur) => DropdownMenuItem(
                  value: cur,
                  child: Text(cur),
                ))
            .toList(),
        onChanged: (val) {
          if (val != null) onChanged(val);
        },
      ),
    );
  }
}
