import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/tax_calculator_models.dart';
import '../providers/tax_calculator_provider.dart';
import 'package:finance_app/core/theme/app_colors.dart';
import 'package:uuid/uuid.dart';

class TaxConfigEditPage extends StatefulWidget {
  final TaxConfiguration? config;
  const TaxConfigEditPage({super.key, this.config});

  @override
  State<TaxConfigEditPage> createState() => _TaxConfigEditPageState();
}

class _TaxConfigEditPageState extends State<TaxConfigEditPage> {
  late TextEditingController _nameController;
  late List<TaxSlab> _singleSlabs;
  late List<TaxSlab> _marriedSlabs;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.config?.name ?? '');
    _singleSlabs = widget.config?.singleSlabs
            .map((s) => TaxSlab(
                rate: s.rate,
                lowerLimit: s.lowerLimit,
                upperLimit: s.upperLimit))
            .toList() ??
        [TaxSlab(rate: 0.01, lowerLimit: 0, upperLimit: 500000)];
    _marriedSlabs = widget.config?.marriedSlabs
            .map((s) => TaxSlab(
                rate: s.rate,
                lowerLimit: s.lowerLimit,
                upperLimit: s.upperLimit))
            .toList() ??
        [TaxSlab(rate: 0.01, lowerLimit: 0, upperLimit: 600000)];
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _save(WidgetRef ref) {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Please enter a name')));
      return;
    }

    final newConfig = TaxConfiguration(
      id: widget.config?.id ?? const Uuid().v4(),
      name: _nameController.text,
      singleSlabs: _singleSlabs,
      marriedSlabs: _marriedSlabs,
      isDefault: widget.config?.isDefault ?? false,
    );

    ref.read(taxConfigurationsProvider.notifier).addConfig(newConfig);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            widget.config == null ? 'New Configuration' : 'Edit Configuration'),
        actions: [
          Consumer(builder: (context, ref, _) {
            return IconButton(
              icon: const Icon(Icons.check_rounded),
              onPressed: () => _save(ref),
            );
          }),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                labelText: 'Configuration Name',
                hintText: 'e.g. FY 2081/82',
              ),
            ),
            const SizedBox(height: 32),
            _buildSlabEditor('Single Slabs', _singleSlabs),
            const SizedBox(height: 32),
            _buildSlabEditor('Married Slabs', _marriedSlabs),
          ],
        ),
      ),
    );
  }

  Widget _buildSlabEditor(String title, List<TaxSlab> slabs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            IconButton(
              icon: const Icon(Icons.add_circle_outline,
                  color: AppColors.primary),
              onPressed: () {
                setState(() {
                  final lastUpper = slabs.last.upperLimit;
                  slabs.add(TaxSlab(
                      rate: 0.10,
                      lowerLimit: lastUpper,
                      upperLimit: lastUpper + 200000));
                });
              },
            ),
          ],
        ),
        const SizedBox(height: 8),
        ...slabs.asMap().entries.map((entry) {
          final idx = entry.key;
          final slab = entry.value;
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                Expanded(
                  flex: 2,
                  child: TextFormField(
                    initialValue: (slab.rate * 100).toStringAsFixed(0),
                    decoration: const InputDecoration(
                        labelText: 'Rate %', isDense: true),
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      final rate = (double.tryParse(val) ?? 0) / 100;
                      slabs[idx] = TaxSlab(
                          rate: rate,
                          lowerLimit: slab.lowerLimit,
                          upperLimit: slab.upperLimit);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    initialValue: slab.lowerLimit.toStringAsFixed(0),
                    decoration:
                        const InputDecoration(labelText: 'From', isDense: true),
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      final limit = double.tryParse(val) ?? 0;
                      slabs[idx] = TaxSlab(
                          rate: slab.rate,
                          lowerLimit: limit,
                          upperLimit: slab.upperLimit);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  flex: 3,
                  child: TextFormField(
                    initialValue: slab.upperLimit.toStringAsFixed(0),
                    decoration:
                        const InputDecoration(labelText: 'To', isDense: true),
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      final limit = double.tryParse(val) ?? 0;
                      slabs[idx] = TaxSlab(
                          rate: slab.rate,
                          lowerLimit: slab.lowerLimit,
                          upperLimit: limit);
                    },
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.remove_circle_outline,
                      color: Colors.redAccent, size: 20),
                  onPressed: slabs.length > 1
                      ? () {
                          setState(() {
                            slabs.removeAt(idx);
                          });
                        }
                      : null,
                ),
              ],
            ),
          );
        }),
      ],
    );
  }
}
