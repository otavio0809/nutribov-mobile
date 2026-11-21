import 'package:flutter/material.dart';
import 'theme.dart';

String decimal(double value, {int digits = 2}) =>
    value.toStringAsFixed(digits).replaceAll('.', ',');
String money(double value) => 'R\$ ${decimal(value)}';

double? parseNumber(String? value) {
  final number = double.tryParse((value ?? '').trim().replaceAll(',', '.'));
  return number != null && number.isFinite ? number : null;
}

String? validateNumber(
    String? raw, {
      double min = 0,
      double? max,
      bool optional = false,
      bool positive = false,
    }) {
  if (optional && (raw ?? '').trim().isEmpty) return null;
  final number = parseNumber(raw);
  if (number == null) return 'Informe um número válido';
  if (positive && number <= 0) return 'Informe um valor maior que zero';
  if (number < min) return 'Mínimo de ${decimal(min)}';
  if (max != null && number > max) return 'Máximo de ${decimal(max)}';
  return null;
}

class FarmPage extends StatelessWidget {
  const FarmPage({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => SafeArea(
    top: false,
    bottom: false,
    child: SingleChildScrollView(
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: FarmSpace.medium,
            children: children,
          ),
        ),
      ),
    ),
  );
}

class PageHeading extends StatelessWidget {
  const PageHeading(this.title, this.description, {super.key});
  final String title, description;
  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    spacing: FarmSpace.small,
    children: [
      Text(title, style: Theme.of(context).textTheme.headlineMedium),
      Text(description, style: Theme.of(context).textTheme.bodyLarge),
    ],
  );
}

class FarmPanel extends StatelessWidget {
  const FarmPanel({super.key, required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Card(
    child: DefaultTextStyle.merge(
      style: const TextStyle(color: FarmColors.ink),
      child: IconTheme.merge(
        data: const IconThemeData(color: FarmColors.forest),
        child: Padding(
          padding: const EdgeInsets.all(FarmSpace.medium),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            spacing: FarmSpace.medium,
            children: children,
          ),
        ),
      ),
    ),
  );
}

class FarmNotice extends StatelessWidget {
  const FarmNotice(this.message, {super.key, this.error = false});
  final String message;
  final bool error;
  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Semantics(
      liveRegion: true,
      child: Container(
        padding: const EdgeInsets.all(FarmSpace.medium),
        decoration: BoxDecoration(
          color: error ? colors.errorContainer : FarmColors.mist,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 10,
          children: [
            Icon(
              error ? Icons.error_outline : Icons.info_outline,
              color: error ? colors.onErrorContainer : FarmColors.forest,
            ),
            Expanded(
              child: Text(
                message,
                style: TextStyle(
                  color: error ? colors.onErrorContainer : FarmColors.forest,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class FarmDropdown<T> extends StatelessWidget {
  const FarmDropdown({
    super.key,
    required this.label,
    required this.values,
    required this.selected,
    required this.display,
    required this.onChanged,
  });
  final String label;
  final List<T> values;
  final T selected;
  final String Function(T) display;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) => DropdownButtonFormField<T>(
    key: ValueKey(selected),
    initialValue: selected,
    isExpanded: true,
    dropdownColor: Colors.white,
    style: const TextStyle(color: FarmColors.ink, fontSize: 16),
    iconEnabledColor: FarmColors.forest,
    decoration: InputDecoration(labelText: label),
    items: [
      for (final value in values)
        DropdownMenuItem(
          value: value,
          child: Text(display(value), overflow: TextOverflow.ellipsis),
        ),
    ],
    onChanged: (value) {
      if (value != null) onChanged(value);
    },
  );
}

class FarmNumberField extends StatelessWidget {
  const FarmNumberField({
    super.key,
    required this.controller,
    required this.label,
    this.unit,
    this.onChanged,
    this.optional = false,
    this.positive = false,
    this.max,
  });

  final TextEditingController controller;
  final String label;
  final String? unit;
  final bool optional, positive;
  final double? max;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) => TextFormField(
    controller: controller,
    style: const TextStyle(color: FarmColors.ink, fontSize: 16),
    decoration: InputDecoration(labelText: label, suffixText: unit),
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    validator: (value) =>
        validateNumber(value, max: max, optional: optional, positive: positive),
    onChanged: onChanged,
  );
}

void revealAfterLayout(GlobalKey key) {
  WidgetsBinding.instance.addPostFrameCallback((_) {
    final context = key.currentContext;
    if (context == null) return;
    Scrollable.ensureVisible(
      context,
      duration: const Duration(milliseconds: 220),
    );
  });
}
