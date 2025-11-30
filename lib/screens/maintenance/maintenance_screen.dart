import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_theme.dart';
import '../../core/widgets/animations.dart';
import '../../core/services/firestore_service.dart';
import '../../core/services/invoice_service.dart';
import '../../core/widgets/styled_dialog.dart';

class MaintenanceScreen extends StatefulWidget {
  const MaintenanceScreen({super.key});

  @override
  State<MaintenanceScreen> createState() => _MaintenanceScreenState();
}

class _MaintenanceScreenState extends State<MaintenanceScreen> {
  final FirestoreService _firestoreService = FirestoreService();
  final InvoiceService _invoiceService = InvoiceService();
  final User? _currentUser = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(),
          SliverToBoxAdapter(
            child: FadeSlideTransition(
              delay: const Duration(milliseconds: 100),
              child: _buildTotalDueCard(),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(24),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                FadeSlideTransition(
                  delay: const Duration(milliseconds: 200),
                  child: Text(
                    'Bill History',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                const SizedBox(height: 16),
                _buildBillsList(),
              ]),
            ),
          ),
        ],
      ),
      floatingActionButton: _currentUser != null ? _buildDevFab() : null,
    );
  }

  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120.0,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.offWhite,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 24, bottom: 16),
        title: Text(
          'Maintenance',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppTheme.textDark),
        onPressed: () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildTotalDueCard() {
    return StreamBuilder<QuerySnapshot>(
      stream: _currentUser != null ? _firestoreService.getMaintenanceBills(_currentUser!.uid) : null,
      builder: (context, snapshot) {
        double totalDue = 0;
        if (snapshot.hasData) {
          for (var doc in snapshot.data!.docs) {
            final data = doc.data() as Map<String, dynamic>;
            if (data['status'] == 'pending') {
              totalDue += (data['amount'] ?? 0).toDouble();
            }
          }
        }

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 24),
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppTheme.primaryGreen, AppTheme.darkGreen],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: AppTheme.primaryGreen.withOpacity(0.3),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Total Outstanding',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 20),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '₹${NumberFormat('#,##,###').format(totalDue)}',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              if (totalDue > 0)
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => _showPayAllDialog(totalDue),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primaryGreen,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Pay All Bills',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )
              else
                Row(
                  children: [
                    const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'All caught up!',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBillsList() {
    if (_currentUser == null) return const SizedBox.shrink();

    return StreamBuilder<QuerySnapshot>(
      stream: _firestoreService.getMaintenanceBills(_currentUser!.uid),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const Text('Error loading bills');
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(32),
            alignment: Alignment.center,
            child: Column(
              children: [
                Icon(Icons.receipt_outlined, size: 48, color: Colors.grey[300]),
                const SizedBox(height: 16),
                Text(
                  'No bills found',
                  style: TextStyle(color: Colors.grey[500]),
                ),
              ],
            ),
          );
        }

        // Client-side sorting
        docs.sort((a, b) {
          final dataA = a.data() as Map<String, dynamic>;
          final dataB = b.data() as Map<String, dynamic>;
          final dateA = (dataA['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now();
          final dateB = (dataB['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now();
          return dateB.compareTo(dateA); // Descending
        });

        return Column(
          children: docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildBillCard(doc.id, data),
            );
          }).toList(),
        );
      },
    );
  }

  Widget _buildBillCard(String id, Map<String, dynamic> data) {
    final amount = (data['amount'] ?? 0).toDouble();
    final month = data['month'] ?? 'Unknown';
    final dueDate = (data['dueDate'] as Timestamp?)?.toDate() ?? DateTime.now();
    final status = data['status'] ?? 'pending';
    final isPaid = status == 'paid';

    return Container(
      decoration: AppTheme.cardDecoration,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      month,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Due ${DateFormat('dd MMM yyyy').format(dueDate)}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
                Text(
                  '₹${NumberFormat('#,##,###').format(amount)}',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 16),
              Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isPaid ? AppTheme.primaryGreen.withOpacity(0.1) : AppTheme.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isPaid ? Icons.check_circle_rounded : Icons.pending_rounded,
                        size: 16,
                        color: isPaid ? AppTheme.primaryGreen : AppTheme.orange,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        isPaid ? 'Paid' : 'Pending',
                        style: TextStyle(
                          color: isPaid ? AppTheme.primaryGreen : AppTheme.orange,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isPaid)
                  ScaleOnTap(
                    child: TextButton.icon(
                      onPressed: () => _invoiceService.generateInvoice(data, id),
                      icon: const Icon(Icons.download_rounded, size: 18),
                      label: const Text('Invoice'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.textDark,
                      ),
                    ),
                  )
                else
                  ScaleOnTap(
                    child: ElevatedButton(
                      onPressed: () => _showPayDialog(id, amount, month),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.textDark,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      ),
                      child: const Text('Pay Now'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showPayDialog(String id, double amount, String month) {
    showDialog(
      context: context,
      builder: (context) => StyledDialog(
        title: 'Confirm Payment',
        icon: Icons.payment,
        content: Text(
          'Pay ₹$amount for $month maintenance?',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
        actions: [
          StyledButton(
            text: 'Cancel',
            isPrimary: false,
            onPressed: () => Navigator.pop(context),
          ),
          StyledButton(
            text: 'Pay',
            onPressed: () async {
              Navigator.pop(context);
              _simulatePayment(id);
            },
          ),
        ],
      ),
    );
  }

  void _showPayAllDialog(double amount) {
    showDialog(
      context: context,
      builder: (context) => StyledDialog(
        title: 'Pay All Bills',
        icon: Icons.payment,
        content: Text(
          'Pay total outstanding amount of ₹$amount?',
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
        actions: [
          StyledButton(
            text: 'Cancel',
            isPrimary: false,
            onPressed: () => Navigator.pop(context),
          ),
          StyledButton(
            text: 'Pay',
            onPressed: () async {
              Navigator.pop(context);
              // In a real app, we'd loop through pending bills.
              // For now, just show success as this is a mock.
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Processing payment...')),
              );
              await Future.delayed(const Duration(seconds: 2));
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Payment Successful!'),
                    backgroundColor: AppTheme.primaryGreen,
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Future<void> _simulatePayment(String id) async {
    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(child: CircularProgressIndicator()),
    );

    await Future.delayed(const Duration(seconds: 2)); // Simulate network

    await _firestoreService.payMaintenanceBill(id);

    if (mounted) {
      Navigator.pop(context); // Hide loading
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Payment Successful!'),
          backgroundColor: AppTheme.primaryGreen,
        ),
      );
    }
  }

  // --- Dev Tool to Generate Bills ---
  Widget _buildDevFab() {
    return FloatingActionButton.small(
      onPressed: () async {
        final now = DateTime.now();
        
        // 1. Current Month (Pending)
        await _firestoreService.createMaintenanceBill({
          'userId': _currentUser!.uid,
          'amount': 3500,
          'month': DateFormat('MMMM yyyy').format(now),
          'dueDate': now.add(const Duration(days: 7)),
          'status': 'pending',
        });

        // 2. Last Month (Paid)
        final lastMonth = DateTime(now.year, now.month - 1, now.day);
        await _firestoreService.createMaintenanceBill({
          'userId': _currentUser!.uid,
          'amount': 3500,
          'month': DateFormat('MMMM yyyy').format(lastMonth),
          'dueDate': lastMonth.add(const Duration(days: 7)),
          'status': 'paid',
          'paidAt': FieldValue.serverTimestamp(),
        });

        // 3. Two Months Ago (Paid)
        final twoMonthsAgo = DateTime(now.year, now.month - 2, now.day);
        await _firestoreService.createMaintenanceBill({
          'userId': _currentUser!.uid,
          'amount': 3500,
          'month': DateFormat('MMMM yyyy').format(twoMonthsAgo),
          'dueDate': twoMonthsAgo.add(const Duration(days: 7)),
          'status': 'paid',
          'paidAt': FieldValue.serverTimestamp(),
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Added 3 months of test data!')),
          );
        }
      },
      backgroundColor: Colors.grey,
      child: const Icon(Icons.playlist_add_rounded),
    );
  }
}
