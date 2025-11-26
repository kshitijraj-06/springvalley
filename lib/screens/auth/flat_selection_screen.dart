import 'package:flutter/material.dart';
import '../home/main_navigation.dart';

class FlatSelectionScreen extends StatefulWidget {
  const FlatSelectionScreen({super.key});

  @override
  State<FlatSelectionScreen> createState() => _FlatSelectionScreenState();
}

class _FlatSelectionScreenState extends State<FlatSelectionScreen> {
  String? _selectedTower;
  String? _selectedFlat;

  final List<String> _towers = ['Tower A', 'Tower B', 'Tower C', 'Tower D'];
  final List<String> _flats = List.generate(20, (index) => '${index + 1}01');

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Select Your Flat')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Almost there!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please select your tower and flat number to complete the setup.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 32),
            _buildDropdown(
              label: 'Tower / Block',
              value: _selectedTower,
              items: _towers,
              onChanged: (value) => setState(() => _selectedTower = value),
            ),
            const SizedBox(height: 16),
            _buildDropdown(
              label: 'Flat Number',
              value: _selectedFlat,
              items: _flats,
              onChanged: (value) => setState(() => _selectedFlat = value),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedTower != null && _selectedFlat != null
                    ? () => Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (context) => const MainNavigation()),
                        )
                    : null,
                child: const Text('Continue'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: value,
              hint: Text('Select $label'),
              isExpanded: true,
              items: items.map((item) {
                return DropdownMenuItem(
                  value: item,
                  child: Text(item),
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