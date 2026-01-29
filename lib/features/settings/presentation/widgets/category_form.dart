import 'package:finance_app/core/theme/app_colors.dart';
import 'package:finance_app/features/transactions/data/models/category_model.dart';
import 'package:finance_app/features/settings/presentation/providers/settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CategoryForm extends ConsumerStatefulWidget {
  final CategoryModel? category;
  final String initialType;
  final Function(String name, String icon, int color, String type, double budget) onSave;

  const CategoryForm({
    super.key,
    this.category,
    required this.initialType,
    required this.onSave,
  });

  @override
  ConsumerState<CategoryForm> createState() => _CategoryFormState();
}

class _CategoryFormState extends ConsumerState<CategoryForm> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _budgetController;
  late String _selectedIcon;
  late int _selectedColor;
  late String _type;

  final List<Map<String, dynamic>> _availableIcons = [
    {'name': 'fastfood_rounded', 'icon': Icons.fastfood_rounded},
    {'name': 'directions_bus_rounded', 'icon': Icons.directions_bus_rounded},
    {'name': 'shopping_bag_rounded', 'icon': Icons.shopping_bag_rounded},
    {'name': 'receipt_long_rounded', 'icon': Icons.receipt_long_rounded},
    {'name': 'movie_rounded', 'icon': Icons.movie_rounded},
    {'name': 'work_rounded', 'icon': Icons.work_rounded},
    {'name': 'savings_rounded', 'icon': Icons.savings_rounded},
    {'name': 'trending_up_rounded', 'icon': Icons.trending_up_rounded},
    {'name': 'medical_services_rounded', 'icon': Icons.medical_services_rounded},
    {'name': 'fitness_center_rounded', 'icon': Icons.fitness_center_rounded},
    {'name': 'home_rounded', 'icon': Icons.home_rounded},
    {'name': 'school_rounded', 'icon': Icons.school_rounded},
  ];

  final List<int> _availableColors = [
    AppColors.primary.value,
    AppColors.secondary.value,
    AppColors.tertiary.value,
    AppColors.savings.value,
    AppColors.investment.value,
    Colors.red.value,
    Colors.pink.value,
    Colors.purple.value,
    Colors.deepPurple.value,
    Colors.indigo.value,
    Colors.blue.value,
    Colors.cyan.value,
    Colors.teal.value,
    Colors.green.value,
    Colors.lightGreen.value,
    Colors.lime.value,
    Colors.yellow.value,
    Colors.amber.value,
    Colors.orange.value,
    Colors.deepOrange.value,
    Colors.brown.value,
    Colors.grey.value,
    Colors.blueGrey.value,
  ];

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.category?.name ?? '');
    _budgetController = TextEditingController(text: widget.category?.budgetLimit.toString() ?? '0');
    _selectedIcon = widget.category?.iconParams ?? _availableIcons[0]['name'];
    _selectedColor = widget.category?.colorValue ?? _availableColors[0];
    _type = widget.category?.type ?? widget.initialType;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _budgetController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(settingsProvider);
    final currencySymbol = settingsAsync.when(
      data: (s) => s.currencySymbol,
      loading: () => r'$',
      error: (_, __) => r'$',
    );
    return Container(
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.category == null ? 'New Category' : 'Edit Category',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: 'Name',
                  hintText: 'e.g. Groceries',
                ),
                validator: (value) => (value == null || value.isEmpty) ? 'Please enter a name' : null,
              ),
              const SizedBox(height: 20),
              if (_type != 'income') ...[
                TextFormField(
                  controller: _budgetController,
                  decoration: InputDecoration(
                    labelText: 'Monthly Budget Limit (Optional)',
                    prefixText: '$currencySymbol ',
                  ),
                  keyboardType: TextInputType.number,
                ),
                const SizedBox(height: 20),
              ],
              Text('Type', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 8),
              _buildTypeSelector(),
              const SizedBox(height: 24),
              Text('Icon', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 12),
              SizedBox(
                height: 50,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _availableIcons.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final iconInfo = _availableIcons[index];
                    final isSelected = _selectedIcon == iconInfo['name'];
                    return GestureDetector(
                      onTap: () => setState(() => _selectedIcon = iconInfo['name']),
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isSelected ? AppColors.primary : Theme.of(context).cardTheme.color,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected ? AppColors.primary : Theme.of(context).dividerColor.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Icon(
                          iconInfo['icon'],
                          color: isSelected ? Colors.white : Theme.of(context).iconTheme.color,
                          size: 24,
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
              Text('Color', style: Theme.of(context).textTheme.titleSmall),
              const SizedBox(height: 12),
              SizedBox(
                height: 40,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _availableColors.length,
                  separatorBuilder: (_, __) => const SizedBox(width: 12),
                  itemBuilder: (context, index) {
                    final colorValue = _availableColors[index];
                    final isSelected = _selectedColor == colorValue;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedColor = colorValue),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Color(colorValue),
                          shape: BoxShape.circle,
                          border: isSelected ? Border.all(color: Colors.white, width: 3) : null,
                          boxShadow: isSelected ? [
                            BoxShadow(
                              color: Color(colorValue).withValues(alpha: 0.4),
                              blurRadius: 8,
                              spreadRadius: 2,
                            )
                          ] : null,
                        ),
                        child: isSelected ? const Icon(Icons.check, color: Colors.white, size: 20) : null,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      widget.onSave(
                        _nameController.text,
                        _selectedIcon,
                        _selectedColor,
                        _type,
                        double.tryParse(_budgetController.text) ?? 0,
                      );
                    }
                  },
                  child: Text(widget.category == null ? 'Create Category' : 'Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTypeSelector() {
    final types = ['expense', 'income', 'savings', 'investment'];
    return Wrap(
      spacing: 8,
      children: types.map((type) {
        final isSelected = _type == type;
        return ChoiceChip(
          label: Text(type[0].toUpperCase() + type.substring(1)),
          selected: isSelected,
          onSelected: (selected) {
            if (selected) setState(() => _type = type);
          },
        );
      }).toList(),
    );
  }
}
