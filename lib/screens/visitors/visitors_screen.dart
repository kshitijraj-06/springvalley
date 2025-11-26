import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/animations.dart';

class VisitorsScreen extends StatefulWidget {
  const VisitorsScreen({super.key});

  @override
  State<VisitorsScreen> createState() => _VisitorsScreenState();
}

class _VisitorsScreenState extends State<VisitorsScreen> {
  int _selectedTab = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              FadeSlideTransition(
                delay: const Duration(milliseconds: 100),
                offset: const Offset(0, -0.2),
                child: _buildHeader(context),
              ),
              FadeSlideTransition(
                delay: const Duration(milliseconds: 200),
                child: _buildOverviewCard(context),
              ),
              FadeSlideTransition(
                delay: const Duration(milliseconds: 300),
                child: _buildCreatePassCard(context),
              ),
              FadeSlideTransition(
                delay: const Duration(milliseconds: 400),
                child: _buildQuickActions(context),
              ),
              FadeSlideTransition(
                delay: const Duration(milliseconds: 500),
                child: _buildTabSection(context),
              ),
              FadeSlideTransition(
                delay: const Duration(milliseconds: 600),
                child: _buildTodaysVisitors(context),
              ),
              FadeSlideTransition(
                delay: const Duration(milliseconds: 700),
                child: _buildSecuritySection(context),
              ),
              FadeSlideTransition(
                delay: const Duration(milliseconds: 800),
                child: _buildRecentPasses(context),
              ),
              const SizedBox(height: 100),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.arrow_back, size: 24),
          ),
          const SizedBox(width: 8),
          Text(
            'Visitors',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.history, size: 24),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.tune, size: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildOverviewCard(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Gate & visitor overview',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            'Tower B • Flat 803',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textLight,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today • 3 expected',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.textLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCreatePassCard(BuildContext context) {
    return ScaleOnTap(
      child: GestureDetector(
        onTap: () => _showCreatePassModal(context),
        child: Container(
          margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.lightGreen,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Create gate pass',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.darkGreen,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Generate a QR or code to share with guests and delivery partners.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.darkGreen,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: AppTheme.darkGreen,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  'New pass',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        children: [
          _buildActionRow(
            Icons.person_add_outlined,
            'Add visitor',
            'Friends, family, helpers',
            Icons.inventory_2_outlined,
            'Delivery',
            'Food, parcels, groceries',
          ),
          const SizedBox(height: 12),
          _buildActionRow(
            Icons.local_taxi_outlined,
            'Cab / Taxi',
            'One-time gate entry',
            null,
            null,
            null,
          ),
        ],
      ),
    );
  }

  Widget _buildActionRow(IconData icon1, String title1, String subtitle1, 
                         IconData? icon2, String? title2, String? subtitle2) {
    return Row(
      children: [
        Expanded(
          child: ScaleOnTap(
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: AppTheme.cardDecoration,
              child: Row(
                children: [
                  Icon(icon1, size: 24, color: AppTheme.textDark),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title1,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Text(
                          subtitle1,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textLight,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        if (icon2 != null) ...[
          const SizedBox(width: 12),
          Expanded(
            child: ScaleOnTap(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: AppTheme.cardDecoration,
                child: Row(
                  children: [
                    Icon(icon2, size: 24, color: AppTheme.textDark),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            title2!,
                            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            subtitle2!,
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.textLight,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTabSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(5, 24, 9, 0),
      child: Row(
        children: [
          _buildTab('Today', 0),
          //const SizedBox(width: 5),
          _buildTab('Upcoming', 1),
          //const SizedBox(width: 5),
          _buildTab('History', 2),
          const Spacer(),
          Text(
            '2 inside • 1 expected',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTab(String title, int index) {
    final isSelected = _selectedTab == index;
    return ScaleOnTap(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? AppTheme.darkGreen : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            title,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: isSelected ? Colors.white : AppTheme.textLight,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTodaysVisitors(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Today\'s visitors',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                'Last updated 2 min ago',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textLight,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildVisitorCard('AK', 'Akash Kumar', 'Friend', 'Visiting: Flat 803 • Entered at 04:10 pm', 'Auto approved via pass', 'Inside', AppTheme.primaryGreen),
          const SizedBox(height: 12),
          _buildVisitorCard('SW', 'Swati (Swiggy)', 'Delivery', 'Order: SV-23411 • At main gate', 'Requested at 03:58 pm', 'Waiting', AppTheme.orange),
          const SizedBox(height: 12),
          _buildVisitorCard('RK', 'Rakesh', 'House help', 'Exit recorded at 01:35 pm', 'In 09:10 am • Out 01:35 pm', 'Completed', AppTheme.textLight),
        ],
      ),
    );
  }

  Widget _buildVisitorCard(String initials, String name, String type, String details, String time, String status, Color statusColor) {
    return ScaleOnTap(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.cardDecoration,
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Text(
                  initials,
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        name,
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          type,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    details,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textLight,
                    ),
                  ),
                  Text(
                    time,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textLight,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                status,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: statusColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSecuritySection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      padding: const EdgeInsets.all(16),
      decoration: AppTheme.cardDecoration,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Security alerts & notes',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(Icons.shield_outlined, size: 20, color: AppTheme.textDark),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Gate approvals in your control',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Security will call you only if a visitor does not have an active pass or if details do not match. You can tap a visitor above to approve, deny or share directions.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentPasses(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent passes',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildPassCard('Family dinner pass', 'Shared with 3 guests • Valid today, 06:00 pm – 11:00 pm', 'Code: SV-GP492', 'Active', AppTheme.primaryGreen),
          const SizedBox(height: 12),
          _buildPassCard('Daily help', 'Rakesh • Repeating all days • 09:00 am – 02:00 pm', 'Last used 01:10 pm', 'Ongoing', AppTheme.orange),
          const SizedBox(height: 12),
          _buildPassCard('Courier pickup', 'BlueDart • Used yesterday at 05:40 pm', 'Code: SV-GP412', 'Expired', AppTheme.red),
          const SizedBox(height: 16),
          Center(
            child: Text(
              'Need to check an older pass or visitor? Open History above.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textLight,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              'Loading older logs',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textLight,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPassCard(String title, String details, String code, String status, Color statusColor) {
    return ScaleOnTap(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: AppTheme.cardDecoration,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    status,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              details,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textLight,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              code,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: AppTheme.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showCreatePassModal(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => const CreatePassModal(),
    );
  }
}

class CreatePassModal extends StatefulWidget {
  const CreatePassModal({super.key});

  @override
  State<CreatePassModal> createState() => _CreatePassModalState();
}

class _CreatePassModalState extends State<CreatePassModal> {
  final _nameController = TextEditingController();
  final _vehicleController = TextEditingController();
  final _phoneController = TextEditingController();
  String _selectedType = 'Guest';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  bool _isRecurring = false;
  int _currentStep = 0;

  final List<Map<String, dynamic>> _visitorTypes = [
    {'name': 'Guest', 'icon': Icons.person, 'color': AppTheme.blue},
    {'name': 'Delivery', 'icon': Icons.local_shipping, 'color': AppTheme.orange},
    {'name': 'Service', 'icon': Icons.build, 'color': AppTheme.primaryGreen},
    {'name': 'Cab/Taxi', 'icon': Icons.local_taxi, 'color': Colors.purple},
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.9,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _buildHeader(),
          _buildProgressIndicator(),
          Expanded(
            child: IndexedStack(
              index: _currentStep,
              children: [
                _buildTypeSelection(),
                _buildDetailsForm(),
                _buildDateTimeSelection(),
              ],
            ),
          ),
          _buildBottomActions(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppTheme.primaryGreen, AppTheme.darkGreen],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(
              Icons.qr_code_2,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create New Pass',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Step ${_currentStep + 1} of 3',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: List.generate(3, (index) {
          final isActive = index <= _currentStep;
          return Expanded(
            child: Container(
              height: 4,
              margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
              decoration: BoxDecoration(
                color: isActive ? AppTheme.primaryGreen : Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildTypeSelection() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Select Visitor Type',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Choose the type of visitor you want to create a pass for',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textLight,
            ),
          ),
          const SizedBox(height: 32),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 1.2,
              ),
              itemCount: _visitorTypes.length,
              itemBuilder: (context, index) {
                final type = _visitorTypes[index];
                final isSelected = _selectedType == type['name'];
                return GestureDetector(
                  onTap: () => setState(() => _selectedType = type['name']),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: isSelected ? type['color'].withOpacity(0.1) : Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: isSelected ? type['color'] : Colors.grey[300]!,
                        width: isSelected ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: isSelected ? type['color'] : Colors.grey[400],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Icon(
                            type['icon'],
                            color: Colors.white,
                            size: 24,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          type['name'],
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.w600,
                            color: isSelected ? type['color'] : AppTheme.textDark,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsForm() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Visitor Details',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Enter the visitor information',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textLight,
            ),
          ),
          const SizedBox(height: 32),
          _buildFormField(
            controller: _nameController,
            label: 'Visitor Name',
            icon: Icons.person,
            required: true,
          ),
          const SizedBox(height: 20),
          _buildFormField(
            controller: _phoneController,
            label: 'Phone Number',
            icon: Icons.phone,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 20),
          _buildFormField(
            controller: _vehicleController,
            label: 'Vehicle Number (Optional)',
            icon: Icons.directions_car,
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.lightGreen,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(Icons.info_outline, color: AppTheme.darkGreen, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Vehicle number helps security identify your visitor quickly',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.darkGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool required = false,
    TextInputType? keyboardType,
  }) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label + (required ? ' *' : ''),
          prefixIcon: Icon(icon, color: AppTheme.primaryGreen),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }

  Widget _buildDateTimeSelection() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Schedule Visit',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Set the date and time for the visit',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textLight,
            ),
          ),
          const SizedBox(height: 32),
          Row(
            children: [
              Expanded(
                child: _buildDateTimeCard(
                  'Date',
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  Icons.calendar_today,
                  () => _selectDate(),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDateTimeCard(
                  'Time',
                  _selectedTime.format(context),
                  Icons.access_time,
                  () => _selectTime(),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey[300]!),
            ),
            child: Row(
              children: [
                Checkbox(
                  value: _isRecurring,
                  onChanged: (value) => setState(() => _isRecurring = value ?? false),
                  activeColor: AppTheme.primaryGreen,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Recurring pass',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        'Create a daily recurring pass for regular visitors',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textLight,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeCard(String label, String value, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey[300]!),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: AppTheme.primaryGreen),
                const SizedBox(width: 8),
                Text(
                  label,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.textLight,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              value,
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActions() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep--),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Back'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: () {
                if (_currentStep < 2) {
                  setState(() {
                    _currentStep++;
                  });
                } else {
                  _createPass();
                }
              },
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(_currentStep < 2 ? 'Next' : 'Generate Pass'),
            ),
          ),
        ],
      ),
    );
  }

  void _selectDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date != null) {
      setState(() => _selectedDate = date);
    }
  }

  void _selectTime() async {
    final time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null) {
      setState(() => _selectedTime = time);
    }
  }

  void _createPass() {
    if (_nameController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please enter visitor name'),
          backgroundColor: AppTheme.red,
        ),
      );
      return;
    }

    final passId = 'SV-GP${DateTime.now().millisecondsSinceEpoch.toString().substring(8)}';
    
    Navigator.pop(context);
    _showPassGenerated(passId);
  }

  void _showPassGenerated(String passId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => PassGeneratedModal(
        passId: passId,
        visitorName: _nameController.text,
        visitorType: _selectedType,
        date: _selectedDate,
        time: _selectedTime,
      ),
    );
  }
}

class PassGeneratedModal extends StatelessWidget {
  final String passId;
  final String visitorName;
  final String visitorType;
  final DateTime date;
  final TimeOfDay time;

  const PassGeneratedModal({
    super.key,
    required this.passId,
    required this.visitorName,
    required this.visitorType,
    required this.date,
    required this.time,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      maxChildSize: 0.9,
      minChildSize: 0.5,
      expand: false,
      builder: (context, scrollController) => SingleChildScrollView(
        controller: scrollController,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    'Pass Generated!',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.primaryGreen,
                    ),
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: AppTheme.cardDecoration,
              child: Column(
                children: [
                  QrImageView(
                    data: passId,
                    version: QrVersions.auto,
                    size: 200.0,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    visitorName,
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      visitorType,
                      style: TextStyle(
                        color: AppTheme.primaryGreen,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Pass ID: $passId',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textLight,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${date.day}/${date.month}/${date.year} at ${time.format(context)}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.textLight,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.share),
                    label: const Text('Share'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.download, color: Colors.white),
                    label: const Text('Save', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}