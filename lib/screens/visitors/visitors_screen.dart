import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/theme/app_theme.dart';

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
              _buildHeader(context),
              _buildOverviewCard(context),
              _buildCreatePassCard(context),
              _buildQuickActions(context),
              _buildTabSection(context),
              _buildTodaysVisitors(context),
              _buildSecuritySection(context),
              _buildRecentPasses(context),
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
    return Container(
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
        if (icon2 != null) ...[
          const SizedBox(width: 12),
          Expanded(
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
    return GestureDetector(
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
    return Container(
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
    return Container(
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
    );
  }
}